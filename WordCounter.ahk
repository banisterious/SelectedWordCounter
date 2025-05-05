#Requires AutoHotkey v2.0
#SingleInstance Force

; Script Version and Update Info
global VERSION := "1.0.0"
global LAST_UPDATED := "2024-03-21"

; Initialize global variables
global g_History := []
global g_MaxHistory := 50
global g_ConfigFile := A_ScriptDir . "\config.ini"
global g_LogFile := A_ScriptDir . "\wordcounter.log"
global g_OriginalClipboard := ""

; Include dependencies
#Include Logger.ahk
#Include Config.ahk
#Include WordCountUI.ahk

; Function to check if debug is enabled
IsDebugEnabled() {
    try {
        debugValue := IniRead(g_ConfigFile, "Debug", "ShowDebugOutput", "0")
        return (SubStr(Trim(debugValue), 1, 1) = "1")
    } catch {
        return false
    }
}

; Initialize components
InitializeComponents()

; Set up tray menu
InitializeTrayMenu()

; Register default hotkey
^#w::
{
    debugEnabled := IsDebugEnabled()
    if debugEnabled {
        Log("DEBUG", "Hotkey triggered - Ctrl+Win+W")
    }
    CountSelectedWords()
}

; ==================== Main Functions ====================

InitializeComponents() {
    InitializeLogger()
    LoadConfiguration()
    Log("INFO", "Application started. Version " . VERSION)
    
    ; Load debug setting from Debug section
    try {
        Log("INFO", "Reading debug setting from: " . g_ConfigFile)
        if !FileExist(g_ConfigFile) {
            Log("WARN", "Config file does not exist: " . g_ConfigFile)
            return
        }
        
        debugValue := IniRead(g_ConfigFile, "Debug", "ShowDebugOutput", "0")
        Log("INFO", "Raw debug value read from config: `"" . debugValue . "`"")
        
        ; Clean the value - take only the first character
        debugValue := SubStr(Trim(debugValue), 1, 1)
        Log("INFO", "Cleaned debug value: `"" . debugValue . "`"")
        
        return (debugValue = "1")
    } catch as err {
        Log("WARN", "Failed to read debug setting, defaulting to disabled: " . err.Message)
        return false
    }
}

InitializeTrayMenu() {
    A_TrayMenu.Delete  ; Clear default menu
    A_TrayMenu.Add("Count Selected Words", CountSelectedWords)
    A_TrayMenu.Add("Show History", ShowHistory)
    A_TrayMenu.Add()  ; Separator
    A_TrayMenu.Add("Exit", (*) => ExitApp())
    
    A_IconTip := "Word Counter v" . VERSION
}

CountSelectedWords(*) {
    debugEnabled := IsDebugEnabled()
    
    if debugEnabled {
        Log("DEBUG", "Starting word count operation")
    }
    
    ; Store original clipboard content
    originalClip := ClipboardAll()
    A_Clipboard := ""

    try {
        Send "^c"
        if !ClipWait(0.2) {
            if debugEnabled {
                Log("DEBUG", "No text selected or clipboard operation timed out")
            }
            A_Clipboard := originalClip
            ShowNoSelectionError()
            return
        }
        
        selectedText := GetCleanTextFromClipboard()
        
        if debugEnabled {
            Log("DEBUG", "Processing text for word count. Length: " . StrLen(selectedText))
        }
        
        if StrLen(selectedText) > 100000 {
            ShowLargeTextWarning()
        }
        
        wordCount := ComputeWordCount(selectedText)
        
        if debugEnabled {
            Log("DEBUG", "Word count result: " . wordCount)
        }
        
        AddToHistory(wordCount)
        ShowResultPopup(wordCount)
        
        A_Clipboard := originalClip
        
    } catch as err {
        HandleError(err)
        A_Clipboard := originalClip
    }
}

GetCleanTextFromClipboard() {
    debugEnabled := IsDebugEnabled()
    
    ; Try to get plain text format first (CF_UNICODETEXT = 13)
    if DllCall("IsClipboardFormatAvailable", "uint", 13) {
        if debugEnabled {
            Log("DEBUG", "Unicode text format available in clipboard")
        }
        
        ; Temporarily store current clipboard
        tempClip := A_Clipboard
        ; Clear clipboard and only get text
        A_Clipboard := ""
        A_Clipboard := tempClip
        if ClipWait(0.1, 1) { ; Wait for text (1 means waiting for unicode text)
            text := A_Clipboard
            
            if debugEnabled {
                Log("DEBUG", "Original text length: " . StrLen(text))
            }
            
            ; Remove file paths and names
            text := RegExReplace(text, "[a-zA-Z]:\\[^\s]+", "")  ; Remove full paths
            text := RegExReplace(text, "\S+\.(jpg|jpeg|png|gif|bmp|webp|md|txt|pdf|doc|docx)", "")  ; Remove filenames
            text := RegExReplace(text, "\s+", " ")  ; Clean up extra spaces
            
            if debugEnabled {
                Log("DEBUG", "Cleaned text length: " . StrLen(text))
            }
            
            return Trim(text)
        }
    }
    
    ; Try regular text format (CF_TEXT = 1)
    if DllCall("IsClipboardFormatAvailable", "uint", 1) {
        if debugEnabled {
            Log("DEBUG", "Plain text format available in clipboard")
        }
        
        text := A_Clipboard
        ; Remove file paths and names
        text := RegExReplace(text, "[a-zA-Z]:\\[^\s]+", "")  ; Remove full paths
        text := RegExReplace(text, "\S+\.(jpg|jpeg|png|gif|bmp|webp|md|txt|pdf|doc|docx)", "")  ; Remove filenames
        text := RegExReplace(text, "\s+", " ")  ; Clean up extra spaces
        
        if debugEnabled {
            Log("DEBUG", "Cleaned text length: " . StrLen(text))
        }
        
        return Trim(text)
    }
    
    ; If HTML format available, try to clean it thoroughly
    if DllCall("IsClipboardFormatAvailable", "uint", DllCall("RegisterClipboardFormat", "str", "HTML Format")) {
        if debugEnabled {
            Log("DEBUG", "HTML format available in clipboard")
        }
        
        htmlText := A_Clipboard
        
        if debugEnabled {
            Log("DEBUG", "Original HTML length: " . StrLen(htmlText))
        }
        
        ; Remove HTML comments
        htmlText := RegExReplace(htmlText, "<!--[\s\S]*?-->", " ")
        
        ; Remove scripts and style blocks
        htmlText := RegExReplace(htmlText, "<script[\s\S]*?</script>", " ")
        htmlText := RegExReplace(htmlText, "<style[\s\S]*?</style>", " ")
        
        ; Remove image tags and their contents (including src attributes)
        htmlText := RegExReplace(htmlText, "<img\s+[^>]*>", " ")
        
        ; Remove all other HTML tags
        htmlText := RegExReplace(htmlText, "<[^>]+>", " ")
        
        ; Remove HTML entities
        htmlText := RegExReplace(htmlText, "&[^;]+;", " ")
        
        ; Remove file paths and names
        htmlText := RegExReplace(htmlText, "[a-zA-Z]:\\[^\s]+", "")  ; Remove full paths
        htmlText := RegExReplace(htmlText, "\S+\.(jpg|jpeg|png|gif|bmp|webp|md|txt|pdf|doc|docx)", "")  ; Remove filenames
        
        ; Clean up whitespace
        htmlText := RegExReplace(htmlText, "[\r\n\t]+", " ")
        htmlText := RegExReplace(htmlText, "\s+", " ")
        htmlText := Trim(htmlText)
        
        if debugEnabled {
            Log("DEBUG", "Cleaned HTML text length: " . StrLen(htmlText))
        }
        
        return htmlText
    }
    
    ; If no usable format found, return empty string
    if debugEnabled {
        Log("DEBUG", "No supported text format found in clipboard")
    }
    return ""
}

ComputeWordCount(text) {
    ; Pattern explanation:
    ; (?:[A-Za-z]+(?:'[A-Za-z]+)?|[0-9]+(?:\.[0-9]+)?|[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*)
    ; 
    ; This matches:
    ; 1. Words with contractions: [A-Za-z]+(?:'[A-Za-z]+)?
    ;    e.g., "I'm", "don't", "won't"
    ; 
    ; 2. Numbers with decimals: [0-9]+(?:\.[0-9]+)?
    ;    e.g., "3.5", "42.0", "1.234"
    ; 
    ; 3. Hyphenated/underscore words: [A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*
    ;    e.g., "self-hosted", "foo_bar"
    
    ; First clean any remaining special characters or extra whitespace
    text := RegExReplace(text, "[\r\n\t]", " ")  ; Convert line breaks and tabs to spaces
    text := RegExReplace(text, "\s+", " ")       ; Normalize multiple spaces to single space
    text := Trim(text)                           ; Remove leading/trailing spaces
    
    pattern := "(?:[A-Za-z]+(?:'[A-Za-z]+)?|[0-9]+(?:\.[0-9]+)?|[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*)"
    count := 0
    pos := 1
    
    while (pos := RegExMatch(text, pattern, &match, pos)) {
        count++
        pos += match.Len
    }
    
    return count
}

AddToHistory(count) {
    entry := {
        timestamp: FormatTime(A_Now, "yyyyMMddTHHmmss"),
        count: count
    }
    
    g_History.InsertAt(1, entry)
    if g_History.Length > g_MaxHistory {
        g_History.Pop()
    }
}

ShowNoSelectionError() {
    MsgBox("No text selected.", "Word Counter", "Icon!")
}

ShowLargeTextWarning() {
    Log("WARN", "Large text selection detected")
    MsgBox("Large text selection detected. Processing may take longer.", "Word Counter", "Icon!")
}

HandleError(err) {
    Log("ERROR", "Error in word counting: " . err.Message)
    MsgBox("An error occurred while counting words.`n`nError: " . err.Message, "Word Counter Error", "IconX")
} 