import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/log_entry.dart';
import '../models/filter_options.dart';
import '../models/connection_state.dart';
import '../services/logcat_service.dart';

/// Provider for managing logcat state
class LogcatProvider extends ChangeNotifier {
  final LogcatService _service = LogcatService();
  
  final List<LogEntry> _allLogs = [];
  final List<LogEntry> _filteredLogs = [];
  
  FilterOptions _filterOptions = FilterOptions();
  ConnectionState _connectionState = ConnectionState.disconnected;
  String _statusMessage = 'Ready';
  List<String> _devices = [];
  String? _selectedDevice;
  StreamSubscription<String>? _logSubscription;
  StreamSubscription<String>? _errorSubscription;
  
  bool _autoScroll = true;
  final int _maxLogLines = 10000; // Limit to prevent memory issues

  // Getters
  List<LogEntry> get logs => _filteredLogs;
  FilterOptions get filterOptions => _filterOptions;
  ConnectionState get connectionState => _connectionState;
  String get statusMessage => _statusMessage;
  List<String> get devices => _devices;
  String? get selectedDevice => _selectedDevice;
  bool get isRunning => _service.isRunning;
  bool get autoScroll => _autoScroll;

  /// Initialize provider - check ADB availability
  Future<void> initialize() async {
    final adbAvailable = await _service.isAdbAvailable();
    if (!adbAvailable) {
      _connectionState = ConnectionState.error;
      _statusMessage = 'ADB not found. Please install Android SDK Platform Tools.';
    } else {
      _statusMessage = 'ADB available. Ready to connect.';
      await refreshDevices();
    }
    notifyListeners();
  }

  /// Refresh list of connected devices
  Future<void> refreshDevices() async {
    _devices = await _service.getDevices();
    if (_devices.isEmpty) {
      _statusMessage = 'No devices connected';
      _connectionState = ConnectionState.disconnected;
    } else if (_devices.length == 1) {
      _selectedDevice = _devices.first;
      _statusMessage = 'Device found: $_selectedDevice';
    } else {
      _statusMessage = '${_devices.length} devices connected';
    }
    notifyListeners();
  }

  /// Select a specific device
  void selectDevice(String? deviceId) {
    _selectedDevice = deviceId;
    notifyListeners();
  }

  /// Start logcat streaming
  Future<void> start() async {
    if (_service.isRunning) {
      return;
    }

    _connectionState = ConnectionState.connecting;
    _statusMessage = 'Starting logcat...';
    notifyListeners();

    final success = await _service.start(deviceId: _selectedDevice);
    
    if (success) {
      _connectionState = ConnectionState.connected;
      _statusMessage = 'Streaming logs from ${_selectedDevice ?? "default device"}';
      
      // Subscribe to log stream
      _logSubscription = _service.logStream.listen(
        _onLogReceived,
        onError: (error) {
          _statusMessage = 'Error: $error';
          notifyListeners();
        },
        onDone: () {
          _connectionState = ConnectionState.disconnected;
          _statusMessage = 'Log streaming stopped';
          notifyListeners();
        },
      );

      // Subscribe to error stream
      _errorSubscription = _service.errorStream.listen(
        (error) {
          _statusMessage = 'Error: $error';
          _connectionState = ConnectionState.error;
          notifyListeners();
        },
      );
    } else {
      _connectionState = ConnectionState.error;
      _statusMessage = 'Failed to start logcat. Check device connection.';
    }
    
    notifyListeners();
  }

  /// Handle incoming log line
  void _onLogReceived(String line) {
    if (line.trim().isEmpty) {
      return;
    }

    // Parse log entry
    final entry = LogEntry.parse(line);
    
    // Add to all logs
    _allLogs.add(entry);
    
    // Limit log size
    if (_allLogs.length > _maxLogLines) {
      _allLogs.removeAt(0);
    }

    // Check if entry matches filter
    if (_filterOptions.matches(entry.rawLine, entry.level, entry.tag)) {
      _filteredLogs.add(entry);
      
      // Limit filtered logs size
      if (_filteredLogs.length > _maxLogLines) {
        _filteredLogs.removeAt(0);
      }
      
      notifyListeners();
    }
  }

  /// Stop logcat streaming
  Future<void> stop() async {
    await _logSubscription?.cancel();
    await _errorSubscription?.cancel();
    _logSubscription = null;
    _errorSubscription = null;
    
    await _service.stop();
    
    _connectionState = ConnectionState.disconnected;
    _statusMessage = 'Stopped';
    notifyListeners();
  }

  /// Clear all logs
  void clearLogs() {
    _allLogs.clear();
    _filteredLogs.clear();
    notifyListeners();
  }

  /// Clear device logcat buffer and local logs
  Future<void> clearAll() async {
    await _service.clearLogcat();
    clearLogs();
    _statusMessage = 'Logs cleared';
    notifyListeners();
  }

  /// Update filter options
  void updateFilter(FilterOptions options) {
    _filterOptions = options;
    _applyFilter();
    notifyListeners();
  }

  /// Apply current filter to all logs
  void _applyFilter() {
    _filteredLogs.clear();
    for (final entry in _allLogs) {
      if (_filterOptions.matches(entry.rawLine, entry.level, entry.tag)) {
        _filteredLogs.add(entry);
      }
    }
  }

  /// Toggle auto-scroll
  void toggleAutoScroll() {
    _autoScroll = !_autoScroll;
    notifyListeners();
  }

  /// Save logs to file
  Future<bool> saveLogs() async {
    try {
      // Pick save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Logs',
        fileName: 'logcat_${DateTime.now().millisecondsSinceEpoch}.txt',
        type: FileType.custom,
        allowedExtensions: ['txt', 'log'],
      );

      if (result == null) {
        return false;
      }

      // Write logs to file
      final file = File(result);
      final buffer = StringBuffer();
      
      for (final entry in _filteredLogs) {
        buffer.writeln(entry.rawLine);
      }
      
      await file.writeAsString(buffer.toString());
      _statusMessage = 'Logs saved to ${file.path}';
      notifyListeners();
      
      return true;
    } catch (e) {
      _statusMessage = 'Failed to save logs: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _errorSubscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
