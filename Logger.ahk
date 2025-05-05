#Requires AutoHotkey v2.0

class Logger {
    static __New() {
        this.logFile := ""
        this.logLevel := "INFO"  ; Default log level
        this.levels := Map(
            "DEBUG", 0,
            "INFO", 1,
            "WARN", 2,
            "ERROR", 3
        )
    }

    static Initialize(logFile) {
        this.logFile := logFile
        ; Try to read log level from config
        try {
            configLevel := IniRead(g_ConfigFile, "Settings", "LogLevel", "INFO")
            this.logLevel := configLevel
            this.Log("INFO", "Logger initialized with level: " . this.logLevel)
        } catch as err {
            this.logLevel := "INFO"
            this.Log("WARN", "Failed to read log level, defaulting to INFO: " . err.Message)
        }
    }

    static Log(level, message) {
        if (this.ShouldLog(level)) {
            timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
            logMessage := "[" . timestamp . "] [" . level . "] " . message . "`n"
            try {
                FileAppend(logMessage, this.logFile)
            } catch as err {
                MsgBox("Failed to write to log file: " . err.Message)
            }
        }
    }

    static ShouldLog(messageLevel) {
        messageLevelValue := this.levels.Get(messageLevel, 99)  ; Default to high value if unknown
        currentLevelValue := this.levels.Get(this.logLevel, 1)  ; Default to INFO if unknown
        return messageLevelValue >= currentLevelValue
    }
}

InitializeLogger() {
    Logger.Initialize(g_LogFile)
}

Log(level, message) {
    Logger.Log(level, message)
}

ClearLog() {
    try {
        FileDelete(g_LogFile)
    } catch {
        ; Ignore errors when clearing log
    }
} 