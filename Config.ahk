; Config.ahk - Configuration management for Word Counter

LoadConfiguration() {
    if !FileExist(g_ConfigFile) {
        CreateDefaultConfig()
    }
    
    try {
        ; Load settings
        g_MaxHistory := IniRead(g_ConfigFile, "Settings", "MaxHistory", 50)
        
        ; Validate settings
        if g_MaxHistory < 1 {
            g_MaxHistory := 50  ; Reset to default if invalid
            Log("WARN", "Invalid MaxHistory value in config, reset to default")
        }
        
    } catch as err {
        Log("ERROR", "Failed to load configuration: " . err.Message)
        CreateDefaultConfig()
    }
}

CreateDefaultConfig() {
    try {
        Log("INFO", "Creating default configuration file: " . g_ConfigFile)
        
        defaultConfig := "
        (
[Hotkeys]
WordCount=^#w

[Settings]
MaxHistory=50
LogLevel=INFO
PreserveClipboard=1
MaxTextSize=100000
        )"
        
        if FileExist(g_ConfigFile) {
            Log("INFO", "Deleting existing config file")
            FileDelete(g_ConfigFile)
        }
        
        Log("INFO", "Writing new config file")
        FileAppend(defaultConfig, g_ConfigFile)
        Log("INFO", "Created default configuration file")
        
    } catch as err {
        Log("ERROR", "Failed to create default configuration. Error: " . err.Message . " Type: " . Type(err))
        MsgBox("Failed to create configuration file.`n`nError: " . err.Message, "Configuration Error", "IconX")
    }
}

SaveConfiguration() {
    try {
        IniWrite(g_MaxHistory, g_ConfigFile, "Settings", "MaxHistory")
        Log("INFO", "Configuration saved successfully")
    } catch as err {
        Log("ERROR", "Failed to save configuration: " . err.Message)
        MsgBox("Failed to save configuration.", "Configuration Error", "IconX")
    }
} 