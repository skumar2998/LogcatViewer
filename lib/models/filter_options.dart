/// Filter options for logcat entries
class FilterOptions {
  final String keyword;
  final Set<String> levels;
  final String tag;

  FilterOptions({
    this.keyword = '',
    Set<String>? levels,
    this.tag = '',
  }) : levels = levels ?? {'V', 'D', 'I', 'W', 'E', 'F'};

  /// Check if a log entry matches the filter
  bool matches(String rawLine, String level, String tag) {
    // Check level
    if (!levels.contains(level)) {
      return false;
    }

    // Check tag
    if (this.tag.isNotEmpty && !tag.toLowerCase().contains(this.tag.toLowerCase())) {
      return false;
    }

    // Check keyword
    if (keyword.isNotEmpty && !rawLine.toLowerCase().contains(keyword.toLowerCase())) {
      return false;
    }

    return true;
  }

  FilterOptions copyWith({
    String? keyword,
    Set<String>? levels,
    String? tag,
  }) {
    return FilterOptions(
      keyword: keyword ?? this.keyword,
      levels: levels ?? this.levels,
      tag: tag ?? this.tag,
    );
  }
}
