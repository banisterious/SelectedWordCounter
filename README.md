# SelectedWordCounter

A Windows utility to count words in selected text across any application.

## Features

- Global hotkey (Ctrl+Win+W) to count words in selected text
- Works with any application that supports text selection
- Handles multiple text formats (plain text, Unicode, HTML)
- Intelligent text cleaning (removes file paths, HTML tags, etc.)
- History tracking of word counts
- Configurable debug logging

## Installation

1. Ensure you have AutoHotkey v2 installed
2. Download all files to a directory
3. Run WordCounter.ahk

## Configuration

The application can be configured through the `config.ini` file:

```ini
[Hotkeys]
WordCount=^#w  ; Default hotkey is Ctrl+Win+W

[Settings]
MaxHistory=50  ; Number of word counts to keep in history
LogLevel=INFO  ; Logging level (DEBUG, INFO, WARN, ERROR)
PreserveClipboard=1  ; Keep original clipboard content
MaxTextSize=100000  ; Maximum text size before warning

[Debug]
ShowDebugOutput=0  ; Set to 1 to enable detailed debug logging
```

### Debug Logging

To enable detailed debug logging:

1. Set `LogLevel=DEBUG` in the [Settings] section
2. Set `ShowDebugOutput=1` in the [Debug] section

Debug logs will show:
- Text format detection
- Text processing steps
- Original and cleaned text lengths
- Word counting results

Debug logs are written to `wordcounter.log` in the application directory.

## Usage

1. Select text in any application
2. Press Ctrl+Win+W (or your configured hotkey)
3. The word count will be displayed in a popup
4. View history through the tray menu

## Support

For issues or feature requests, please file an issue in the repository. 