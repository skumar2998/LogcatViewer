import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/logcat_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/log_list_view.dart';
import '../widgets/filter_dialog.dart';
import '../models/connection_state.dart' as app_state;

/// Main home screen for LogcatViewer
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LogcatViewer'),
        actions: [
          // Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: 'Toggle theme',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          const _Toolbar(),
          
          // Status bar
          const _StatusBar(),
          
          // Log view
          Expanded(
            child: Consumer<LogcatProvider>(
              builder: (context, provider, _) {
                return LogListView(
                  logs: provider.logs,
                  autoScroll: provider.autoScroll,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Toolbar with control buttons
class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    return Consumer<LogcatProvider>(
      builder: (context, provider, _) {
        final isRunning = provider.isRunning;
        
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Device selector
              if (provider.devices.isNotEmpty) ...[
                const Icon(Icons.phone_android, size: 20),
                DropdownButton<String>(
                  value: provider.selectedDevice,
                  hint: const Text('Select device'),
                  items: provider.devices.map((device) {
                    return DropdownMenuItem(
                      value: device,
                      child: Text(device),
                    );
                  }).toList(),
                  onChanged: isRunning ? null : provider.selectDevice,
                ),
                const VerticalDivider(),
              ],
              
              // Refresh devices
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: isRunning ? null : provider.refreshDevices,
                tooltip: 'Refresh devices',
              ),
              
              const VerticalDivider(),
              
              // Start button
              ElevatedButton.icon(
                onPressed: isRunning ? null : provider.start,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              
              // Stop button
              ElevatedButton.icon(
                onPressed: isRunning ? provider.stop : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              
              // Clear button
              ElevatedButton.icon(
                onPressed: provider.clearLogs,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
              ),
              
              const VerticalDivider(),
              
              // Filter button
              IconButton.filledTonal(
                icon: const Icon(Icons.filter_alt),
                onPressed: () => _showFilterDialog(context, provider),
                tooltip: 'Filter logs',
              ),
              
              // Auto-scroll toggle
              IconButton.filledTonal(
                icon: Icon(
                  provider.autoScroll
                      ? Icons.vertical_align_bottom
                      : Icons.vertical_align_center,
                ),
                onPressed: provider.toggleAutoScroll,
                tooltip: provider.autoScroll
                    ? 'Auto-scroll enabled'
                    : 'Auto-scroll disabled',
              ),
              
              // Save button
              IconButton.filledTonal(
                icon: const Icon(Icons.save),
                onPressed: provider.logs.isEmpty ? null : provider.saveLogs,
                tooltip: 'Save logs to file',
              ),
              
              // Log count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${provider.logs.length} logs',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFilterDialog(BuildContext context, LogcatProvider provider) async {
    final result = await showDialog(
      context: context,
      builder: (context) => FilterDialog(
        currentFilter: provider.filterOptions,
      ),
    );
    
    if (result != null) {
      provider.updateFilter(result);
    }
  }
}

/// Status bar showing connection state
class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<LogcatProvider>(
      builder: (context, provider, _) {
        final state = provider.connectionState;
        final color = _getStateColor(state);
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              
              // Status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      provider.statusMessage,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStateColor(app_state.ConnectionState state) {
    switch (state) {
      case app_state.ConnectionState.disconnected:
        return Colors.grey;
      case app_state.ConnectionState.connecting:
        return Colors.orange;
      case app_state.ConnectionState.connected:
        return Colors.green;
      case app_state.ConnectionState.error:
        return Colors.red;
    }
  }
}
