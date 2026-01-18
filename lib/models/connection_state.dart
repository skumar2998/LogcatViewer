/// Connection state for ADB device
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

extension ConnectionStateExtension on ConnectionState {
  String get displayName {
    switch (this) {
      case ConnectionState.disconnected:
        return 'Disconnected';
      case ConnectionState.connecting:
        return 'Connecting...';
      case ConnectionState.connected:
        return 'Connected';
      case ConnectionState.error:
        return 'Error';
    }
  }

  String get description {
    switch (this) {
      case ConnectionState.disconnected:
        return 'No device connected';
      case ConnectionState.connecting:
        return 'Connecting to device...';
      case ConnectionState.connected:
        return 'Device connected and streaming logs';
      case ConnectionState.error:
        return 'ADB error or device not found';
    }
  }
}
