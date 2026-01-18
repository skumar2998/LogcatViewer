import 'package:flutter/material.dart';
import '../models/filter_options.dart';

/// Dialog for configuring log filters
class FilterDialog extends StatefulWidget {
  final FilterOptions currentFilter;

  const FilterDialog({
    super.key,
    required this.currentFilter,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _keywordController;
  late TextEditingController _tagController;
  late Set<String> _selectedLevels;

  final Map<String, String> _levelNames = {
    'V': 'Verbose',
    'D': 'Debug',
    'I': 'Info',
    'W': 'Warning',
    'E': 'Error',
    'F': 'Fatal',
  };

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController(text: widget.currentFilter.keyword);
    _tagController = TextEditingController(text: widget.currentFilter.tag);
    _selectedLevels = Set.from(widget.currentFilter.levels);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Logs'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Keyword filter
              TextField(
                controller: _keywordController,
                decoration: const InputDecoration(
                  labelText: 'Keyword',
                  hintText: 'Filter by keyword in message',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tag filter
              TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  hintText: 'Filter by tag name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),
              
              // Log level filter
              const Text(
                'Log Levels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _levelNames.entries.map((entry) {
                  final level = entry.key;
                  final name = entry.value;
                  final isSelected = _selectedLevels.contains(level);
                  
                  return FilterChip(
                    label: Text(name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedLevels.add(level);
                        } else {
                          _selectedLevels.remove(level);
                        }
                      });
                    },
                    avatar: CircleAvatar(
                      backgroundColor: _getLevelColor(level),
                      child: Text(
                        level,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Reset to default
            setState(() {
              _keywordController.clear();
              _tagController.clear();
              _selectedLevels = {'V', 'D', 'I', 'W', 'E', 'F'};
            });
          },
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final filter = FilterOptions(
              keyword: _keywordController.text,
              tag: _tagController.text,
              levels: _selectedLevels,
            );
            Navigator.pop(context, filter);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
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
        return Colors.red.shade900;
      default:
        return Colors.black;
    }
  }
}
