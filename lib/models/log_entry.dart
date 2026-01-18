/// Represents a single log entry from logcat
class LogEntry {
  final DateTime timestamp;
  final String level;
  final String tag;
  final String pid;
  final String tid;
  final String message;
  final String rawLine;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.pid,
    required this.tid,
    required this.message,
    required this.rawLine,
  });

  /// Parse a logcat line into a LogEntry
  /// Format: MM-DD HH:MM:SS.mmm PID TID LEVEL TAG: message
  factory LogEntry.parse(String line) {
    try {
      // Standard logcat format with threadtime
      final regex = RegExp(
        r'^(\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d{3})\s+(\d+)\s+(\d+)\s+([VDIWEF])\s+([^:]+):\s*(.*)$',
      );
      
      final match = regex.firstMatch(line);
      
      if (match != null) {
        final dateStr = match.group(1)!;
        final now = DateTime.now();
        final dateParts = dateStr.split(' ');
        final monthDay = dateParts[0].split('-');
        final timeParts = dateParts[1].split(':');
        final secondMillis = timeParts[2].split('.');
        
        final timestamp = DateTime(
          now.year,
          int.parse(monthDay[0]),
          int.parse(monthDay[1]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          int.parse(secondMillis[0]),
          int.parse(secondMillis[1]),
        );

        return LogEntry(
          timestamp: timestamp,
          level: match.group(4)!,
          tag: match.group(5)!.trim(),
          pid: match.group(2)!,
          tid: match.group(3)!,
          message: match.group(6)!,
          rawLine: line,
        );
      }
    } catch (e) {
      // If parsing fails, return a raw entry
    }

    // Fallback for unparseable lines
    return LogEntry(
      timestamp: DateTime.now(),
      level: 'I',
      tag: 'Unknown',
      pid: '0',
      tid: '0',
      message: line,
      rawLine: line,
    );
  }

  /// Get color for log level
  String getLevelColor() {
    switch (level) {
      case 'V':
        return 'gray';
      case 'D':
        return 'blue';
      case 'I':
        return 'green';
      case 'W':
        return 'orange';
      case 'E':
        return 'red';
      case 'F':
        return 'darkred';
      default:
        return 'black';
    }
  }

  /// Get full level name
  String getLevelName() {
    switch (level) {
      case 'V':
        return 'VERBOSE';
      case 'D':
        return 'DEBUG';
      case 'I':
        return 'INFO';
      case 'W':
        return 'WARNING';
      case 'E':
        return 'ERROR';
      case 'F':
        return 'FATAL';
      default:
        return 'UNKNOWN';
    }
  }

  @override
  String toString() => rawLine;
}
