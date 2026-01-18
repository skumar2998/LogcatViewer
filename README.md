# LogcatViewer

A cross-platform **desktop** Flutter application for viewing Android application logs (logcat output) in real-time.

## Features

### Core Functionality
- **Real-time Log Streaming**: Connect to Android devices or emulators via ADB and stream logs in real-time
- **Multi-device Support**: Detect and select from multiple connected devices
- **Cross-platform Desktop**: Works on Windows, macOS, and Linux

### User Interface
- **Material 3 Design**: Modern, clean interface with Material Design 3
- **Dark/Light Theme**: Toggle between dark and light modes with persistent preferences
- **Responsive Toolbar**: All controls conveniently accessible
- **Auto-scroll**: Automatically scroll to show latest logs (can be toggled)
- **Status Bar**: Real-time connection status with visual indicators

### Log Management
- **Advanced Filtering**: Filter logs by:
  - Keyword search (searches entire log line)
  - Tag name
  - Log level (Verbose, Debug, Info, Warning, Error, Fatal)
- **Color-coded Levels**: Each log level has distinct color for easy identification
- **Clear Logs**: Clear displayed logs or device logcat buffer
- **Save to File**: Export filtered logs to text file
- **Log Counter**: Display count of currently visible logs

### Interaction
- **Copy Log Entry**: Long-press any log entry to copy to clipboard
- **Device Refresh**: Manually refresh the list of connected devices
- **Graceful Error Handling**: Clear messages when ADB is not installed or devices not connected

## Requirements

- **Flutter SDK**: Version 3.10.4 or higher
- **Android SDK Platform Tools**: ADB must be installed and in PATH
- **Operating System**: Windows, macOS, or Linux (desktop platforms only)
- **Windows Users**: Developer Mode must be enabled for plugin support

## Installation

1. Clone this repository
2. Ensure Flutter is installed and configured for desktop development
3. **Windows users**: Enable Developer Mode
   ```bash
   start ms-settings:developers
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```

## Running the Application

### Windows
```bash
flutter run -d windows
```

### macOS
```bash
flutter run -d macos
```

### Linux
```bash
flutter run -d linux
```

> **Note**: This is a desktop-only application. Android, iOS, and web platforms are not supported.

## Usage

1. **Connect Device**: Connect your Android device or start an emulator
2. **Refresh Devices**: Click the refresh button to detect connected devices
3. **Select Device**: If multiple devices are connected, select one from the dropdown
4. **Start Streaming**: Click the "Start" button to begin streaming logs
5. **Filter Logs**: Click the filter icon to configure log filters
6. **Save Logs**: Click the save icon to export current logs to a file
7. **Stop Streaming**: Click the "Stop" button to stop log streaming

## Architecture

### Project Structure
```
lib/
├── main.dart                   # App entry point and configuration
├── models/
│   ├── log_entry.dart         # Log entry data model
│   ├── filter_options.dart    # Filter configuration model
│   └── connection_state.dart  # Device connection state enum
├── services/
│   └── logcat_service.dart    # ADB interaction service
├── providers/
│   ├── logcat_provider.dart   # State management for logs
│   └── theme_provider.dart    # Theme management
├── screens/
│   └── home_screen.dart       # Main application screen
└── widgets/
    ├── log_list_view.dart     # Log display widgets
    └── filter_dialog.dart     # Filter configuration dialog
```

### Key Components

**LogcatService** (`services/logcat_service.dart`)
- Manages ADB process lifecycle
- Streams stdout/stderr from `adb logcat`
- Checks ADB availability and device connectivity
- Provides methods to start, stop, and clear logcat

**LogcatProvider** (`providers/logcat_provider.dart`)
- Manages application state using Provider pattern
- Handles log buffering (max 10,000 lines)
- Applies filters to incoming logs
- Manages device selection and connection state
- Provides save functionality

**ThemeProvider** (`providers/theme_provider.dart`)
- Manages theme mode (light/dark)
- Persists theme preference using SharedPreferences

**LogEntry** (`models/log_entry.dart`)
- Parses logcat output (threadtime format)
- Extracts timestamp, PID, TID, level, tag, and message
- Provides utility methods for display

## Dependencies

- **provider**: State management
- **file_picker**: Save logs to file
- **shared_preferences**: Persist theme preferences
- **path**: Path manipulation utilities

## Troubleshooting

### Windows: Developer Mode Required
If you see "Building with plugins requires symlink support" error:
1. Run `start ms-settings:developers` to open Windows Settings
2. Toggle "Developer Mode" to ON
3. Restart your terminal and try again

### ADB Not Found
If you see "ADB not found" error:
1. Install Android SDK Platform Tools
2. Add the platform-tools directory to your system PATH
3. Restart the application

### No Devices Connected
If no devices appear:
1. Ensure your device is connected via USB
2. Enable USB debugging on your Android device
3. Click the refresh button in the toolbar
4. Run `adb devices` in terminal to verify connection

### Logs Not Appearing
If logs don't appear after starting:
1. Check the status bar for error messages
2. Verify your filter settings (click filter icon)
3. Ensure the device is generating logs
4. Try stopping and restarting the stream

## Building for Production

### Windows
```bash
flutter build windows --release
```

### macOS
```bash
flutter build macos --release
```

### Linux
```bash
flutter build linux --release
```

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
