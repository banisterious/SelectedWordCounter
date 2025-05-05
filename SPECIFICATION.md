# # SelectedWordCounter Utility Specification

## Overview
A Windows utility built with AutoHotkey v2 that allows users to count words in currently selected text across any Windows application via a global hotkey or tray-icon menu.

## Version Information
- Version: 1.0.0
- Last Updated: 2025-05-05

## Core Features

### Word Counting
1. **Activation Method**
   - Default Global Hotkey: Ctrl+Win+W
   - Configurable through INI file
   - Accessible via system tray menu

2. **Text Selection and Extraction**
   - Works across any application
   - Preserves original clipboard content in all formats
   - Handles selections up to 100,000 characters (with warning for large selections)
   - Clear clipboard and send Ctrl+C to copy selection
   - 200ms timeout for clipboard operations
   - Immediate feedback if no text is selected
   - Intelligent handling of mixed content:
     * Excludes image file paths and names
     * Removes full file paths (e.g., C:\path\to\file.ext)
     * Filters out filenames with common extensions (.jpg, .png, .md, etc.)
     * Preserves actual text content around removed elements

3. **Word Recognition Algorithm**
   Sophisticated regex pattern handling multiple cases:
   - Base Pattern: `[A-Za-z0-9]+(?>[-_][A-Za-z0-9]+)*`
   - Matches:
     * Standard words
     * Contractions (e.g., "I'm", "don't")
     * Decimal numbers (e.g., "3.5")
     * Hyphenated words (e.g., "Sun-Kissed")
     * Underscore-separated words (e.g., "foo_bar")
   - Strips all other characters (punctuation, symbols)
   - Each match counts as one word

### User Interface
1. **Results Window**
   - Always-on-top, resizable window
   - Centered over active window
   - Displays current word count
   - Shows version and last updated information
   - Copy to Clipboard button
   - Clear History button
   - OK button to close popup

2. **History Feature**
   - Maintains last 50 word counts
   - Displays timestamp (format: yyyyMMddTHHmmss)
   - Each entry shows:
     * Timestamp
     * Count
     * Copy button
   - Double-click to copy historical counts
   - Clear history functionality
   - Scrollable list view
   - Persistent across sessions

### System Integration
1. **System Tray**
   - Custom icon with version tooltip
   - Quick access menu items:
     * Count selected words
     * Show history
     * Exit
   - Options for counting words and viewing history

2. **Configuration System**
   - INI-based configuration
   - Customizable hotkey support
   - Error handling for invalid configurations
   - Localization-ready with UI text in variables
   - Debug output configuration:
     * Controlled via config.ini
     * Shows cleaned text before counting
     * Helps diagnose content handling issues

### Logging System
- Comprehensive logging system
- Tracks application events
- Records errors and warnings
- Maintains operation history

## Technical Requirements
- AutoHotkey v2.0 or higher
- Windows 10/11 compatible
- No external DLLs required
- Performance: ≤100ms end-to-end on typical hardware

## Architecture
1. **Main Flow**
   - Auto-exec section for hotkey and tray menu setup
   - CountSelectedWords label/function calls DoCountWords()
   - Processing chain:
     * DoCountWords() → GetSelectedText() → ComputeWordCount() → AddToHistory() → ShowResultPopup()

2. **Core Components**
   - Clipboard management system
   - Word counting engine using RegExMatch()
   - History buffer using dynamic array
   - GUI management system
   - Content cleaning system:
     * Handles multiple clipboard formats (Unicode, plain text, HTML)
     * Removes file paths and names before counting
     * Strips HTML tags and entities
     * Normalizes whitespace

## File Structure
- `WordCounter.ahk` - Main script
- `WordCountUI.ahk` - UI components
- `Logger.ahk` - Logging functionality
- `Config.ahk` - Configuration management
- `config.ini` - User settings
- `wordcounter.log` - Application logs

## Error Handling
1. **Clipboard Operations**
   - Preserves original clipboard content
   - Handles clipboard access failures
   - Optional retry up to 2 times before error
   - Timeout handling (200ms limit)
   - Graceful handling of mixed content formats

2. **User Feedback**
   - No selection warning
   - Large text warnings
   - Configuration error notifications
   - General error messages with details
   - Clipboard timeout/empty handling

## Security Considerations
- No elevated privileges required
- Safe clipboard handling
- Non-destructive operation

## Implementation Notes
- Extensive code comments for documentation
- Modular design for maintainability
- Localization-ready architecture
- Performance optimization for speed
- Robust content cleaning for accurate counting

## Configuration

### config.ini Structure

```ini
[Hotkeys]
WordCount=^#w  ; Default: Ctrl+Win+W

[Settings]
MaxHistory=50  ; Maximum history entries
LogLevel=INFO  ; Log level (DEBUG, INFO, WARN, ERROR)
PreserveClipboard=1  ; Keep original clipboard
MaxTextSize=100000  ; Size warning threshold

[Debug]
ShowDebugOutput=0  ; Enable detailed debug logging
```

### Debug System

The debug system provides detailed logging of word counter operations:

1. Configuration:
   - Set `LogLevel=DEBUG` in [Settings] for debug message logging
   - Set `ShowDebugOutput=1` in [Debug] for detailed operation logging

2. Debug Information:
   - Hotkey activation
   - Text format detection (Unicode, plain text, HTML)
   - Text processing steps:
     * Original text length
     * Cleaning operations
     * Final text length
   - Word counting results

3. Log File:
   - Location: `wordcounter.log` in application directory
   - Format: `[TIMESTAMP] [LEVEL] Message`
   - Levels: DEBUG, INFO, WARN, ERROR

## Text Processing

### Text Format Detection

1. Unicode Text (CF_UNICODETEXT)
   - Primary format
   - Full Unicode support
   - Debug logs format detection and text lengths

2. Plain Text (CF_TEXT)
   - Fallback format
   - ASCII text support
   - Debug logs format usage

3. HTML Format
   - Special handling for web content
   - Removes HTML tags and entities
   - Debug logs cleaning steps

### Text Cleaning

1. Path Removal:
   - Removes file paths
   - Removes file names with extensions
   - Debug logs text length changes

2. HTML Cleaning:
   - Removes HTML comments
   - Removes script and style blocks
   - Removes image tags
   - Removes HTML entities
   - Debug logs each cleaning step

3. Whitespace Handling:
   - Normalizes line breaks and tabs
   - Consolidates multiple spaces
   - Trims leading/trailing whitespace
   - Debug logs final cleaned length

## Word Counting

### Word Detection

- Matches standard words
- Handles contractions
- Supports hyphenated words
- Handles underscore-joined words
- Debug logs final word count

### Special Cases

1. Numbers:
   - Counts as words
   - Handles decimal numbers
   - Debug logs number detection

2. Compound Words:
   - Hyphenated words count as one
   - Underscore-joined words count as one
   - Debug logs compound word detection

## Error Handling

1. Clipboard Operations:
   - Timeout handling
   - Format conversion errors
   - Debug logs operation failures

2. Large Text:
   - Warning for text > MaxTextSize
   - Continues processing
   - Debug logs size warnings

3. Configuration:
   - Default fallbacks
   - Invalid setting handling
   - Debug logs configuration issues 