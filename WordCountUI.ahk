; WordCountUI.ahk - User interface components for Word Counter

ShowResultPopup(wordCount) {
    static MyGui := 0
    
    ; Destroy previous GUI if it exists
    if MyGui {
        try MyGui.Destroy()
    }
    
    ; Create new GUI
    MyGui := Gui()
    MyGui.Opt("+AlwaysOnTop +Resize")
    MyGui.SetFont("s10", "Segoe UI")
    
    ; Add controls
    MyGui.Add("Text",, "Selected Words:")
    MyGui.Add("Edit", "ReadOnly w100", wordCount)
    MyGui.Add("Button", "Default", "Copy to Clipboard").OnEvent("Click", CopyCount)
    MyGui.Add("Button", "x+10", "Clear History").OnEvent("Click", ClearHistory)
    MyGui.Add("Button", "x+10", "OK").OnEvent("Click", GuiClose)
    
    ; Add history section
    MyGui.Add("Text", "xm y+20", "History:")
    LV := MyGui.Add("ListView", "xm r10 w400", ["Timestamp", "Count", "Action"])
    
    ; Populate history
    for entry in g_History {
        ; Convert stored timestamp (yyyyMMddTHHmmss) to display format
        ts := entry.timestamp
        displayTime := SubStr(ts, 1, 4) . "-" . SubStr(ts, 5, 2) . "-" . SubStr(ts, 7, 2) . " " .
                      SubStr(ts, 10, 2) . ":" . SubStr(ts, 12, 2) . ":" . SubStr(ts, 14)
        LV.Add(, displayTime, entry.count, "Copy")
    }
    
    ; Auto-size columns
    LV.ModifyCol()
    LV.ModifyCol(3, 60)  ; Set width for the Action column
    
    ; Add version and last updated info at the bottom
    MyGui.SetFont("s8", "Segoe UI")  ; Smaller font for version
    MyGui.Add("Text", "xm y+10 cGray", "Version " . VERSION . " • Last updated: " . LAST_UPDATED)
    
    ; Center the GUI on the active window
    activeWin := WinExist("A")
    if activeWin {
        WinGetPos(&x, &y, &w, &h, activeWin)
        guiW := 420
        guiH := 400
        guiX := x + (w - guiW) // 2
        guiY := y + (h - guiH) // 2
        MyGui.Show(Format("x{1} y{2} w{3} h{4}", guiX, guiY, guiW, guiH))
    } else {
        MyGui.Show()
    }
    
    CopyCount(*) {
        A_Clipboard := wordCount
        ToolTip("Count copied to clipboard")
        SetTimer () => ToolTip(), -1000
    }
    
    ClearHistory(*) {
        g_History := []
        LV.Delete()
        Log("INFO", "History cleared")
    }
    
    GuiClose(*) {
        MyGui.Hide()
    }
    
    ; Handle ListView events
    LV.OnEvent("DoubleClick", LVDoubleClick)
    
    LVDoubleClick(LV, RowNumber) {
        if RowNumber {
            count := LV.GetText(RowNumber, 2)
            A_Clipboard := count
            ToolTip("Count copied to clipboard")
            SetTimer () => ToolTip(), -1000
        }
    }
}

ShowHistory(*) {
    ShowResultPopup(g_History.Length ? g_History[1].count : 0)
}

ShowWordDetails(text) {
    static DetailsGui := 0
    
    if DetailsGui {
        try DetailsGui.Destroy()
    }
    
    DetailsGui := Gui()
    DetailsGui.Opt("+AlwaysOnTop")
    DetailsGui.SetFont("s10", "Segoe UI")
    
    ; Add ListView for word breakdown
    LV := DetailsGui.Add("ListView", "r10 w400", ["Word", "Type"])
    
    ; Find all words and categorize them
    pattern := "[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*"
    pos := 1
    
    while (pos := RegExMatch(text, pattern, &match, pos)) {
        word := match[]
        type := InStr(word, "-") ? "Hyphenated" :
                InStr(word, "_") ? "Underscore" : "Simple"
        LV.Add(, word, type)
        pos += match.Len
    }
    
    ; Auto-size columns
    LV.ModifyCol()
    
    ; Add close button
    DetailsGui.Add("Button", "Default", "Close").OnEvent("Click", DetailsGuiClose)
    
    ; Show GUI
    DetailsGui.Show("AutoSize")
    
    DetailsGuiClose(*) {
        DetailsGui.Hide()
    }
} 