import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Service for interacting with ADB logcat
class LogcatService {
  Process? _process;
  StreamController<String>? _logController;
  StreamController<String>? _errorController;
  bool _isRunning = false;

  /// Get whether logcat is currently running
  bool get isRunning => _isRunning;

  /// Stream of log lines
  Stream<String> get logStream => _logController?.stream ?? const Stream.empty();

  /// Stream of error messages
  Stream<String> get errorStream => _errorController?.stream ?? const Stream.empty();

  /// Check if ADB is installed and available
  Future<bool> isAdbAvailable() async {
    try {
      final result = await Process.run('adb', ['version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get list of connected devices
  Future<List<String>> getDevices() async {
    try {
      final result = await Process.run('adb', ['devices']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n').skip(1); // Skip "List of devices attached"
        final devices = <String>[];
        
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && trimmed.contains('\t')) {
            final parts = trimmed.split('\t');
            if (parts.length >= 2 && parts[1].contains('device')) {
              devices.add(parts[0]);
            }
          }
        }
        
        return devices;
      }
    } catch (e) {
      // ADB not available
    }
    return [];
  }

  /// Start logcat streaming
  Future<bool> start({String? deviceId}) async {
    if (_isRunning) {
      return false;
    }

    try {
      // Initialize controllers
      _logController = StreamController<String>.broadcast();
      _errorController = StreamController<String>.broadcast();

      // Build command
      final args = <String>[];
      if (deviceId != null) {
        args.addAll(['-s', deviceId]);
      }
      args.addAll(['logcat', '-v', 'threadtime']);

      // Start process
      _process = await Process.start('adb', args);
      _isRunning = true;

      // Listen to stdout
      _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!_logController!.isClosed) {
                _logController!.add(line);
              }
            },
            onError: (error) {
              if (!_errorController!.isClosed) {
                _errorController!.add('Stream error: $error');
              }
            },
            onDone: () {
              _isRunning = false;
            },
          );

      // Listen to stderr
      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!_errorController!.isClosed) {
                _errorController!.add(line);
              }
            },
          );

      // Monitor process exit
      _process!.exitCode.then((exitCode) {
        _isRunning = false;
        if (exitCode != 0) {
          if (!_errorController!.isClosed) {
            _errorController!.add('ADB process exited with code $exitCode');
          }
        }
      });

      return true;
    } catch (e) {
      _isRunning = false;
      if (_errorController != null && !_errorController!.isClosed) {
        _errorController!.add('Failed to start logcat: $e');
      }
      return false;
    }
  }

  /// Stop logcat streaming
  Future<void> stop() async {
    if (_process != null) {
      _process!.kill();
      _process = null;
    }
    
    _isRunning = false;
    
    await _logController?.close();
    await _errorController?.close();
    _logController = null;
    _errorController = null;
  }

  /// Clear logcat buffer
  Future<bool> clearLogcat() async {
    try {
      final result = await Process.run('adb', ['logcat', '-c']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    stop();
  }
}
