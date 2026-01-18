import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/log_entry.dart';

/// Widget to display a single log entry
class LogEntryWidget extends StatelessWidget {
  final LogEntry entry;

  const LogEntryWidget({
    super.key,
    required this.entry,
  });

  Color _getLevelColor(String level, bool isDark) {
    switch (level) {
      case 'V':
        return Colors.grey;
      case 'D':
        return Colors.blue;
      case 'I':
        return Colors.green;
      case 'W':
        return Colors.orange;
      case 'E':
        return Colors.red;
      case 'F':
        return isDark ? Colors.red.shade900 : Colors.red.shade700;
      default:
        return isDark ? Colors.white : Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final levelColor = _getLevelColor(entry.level, isDark);
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return InkWell(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: entry.rawLine));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log entry copied to clipboard'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level indicator
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                color: levelColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  entry.level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Timestamp
            Text(
              '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
              '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
              '${entry.timestamp.second.toString().padLeft(2, '0')}.'
              '${entry.timestamp.millisecond.toString().padLeft(3, '0')}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            // Tag
            Container(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                entry.tag,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: levelColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Message
            Expanded(
              child: Text(
                entry.message,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display log list
class LogListView extends StatefulWidget {
  final List<LogEntry> logs;
  final bool autoScroll;

  const LogListView({
    super.key,
    required this.logs,
    required this.autoScroll,
  });

  @override
  State<LogListView> createState() => _LogListViewState();
}

class _LogListViewState extends State<LogListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(LogListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.autoScroll && widget.logs.isNotEmpty) {
      // Scroll to bottom when new logs arrive
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No logs to display',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click Start to begin streaming logs',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.logs.length,
      itemBuilder: (context, index) {
        return LogEntryWidget(entry: widget.logs[index]);
      },
    );
  }
}
