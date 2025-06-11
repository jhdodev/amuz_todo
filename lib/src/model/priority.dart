enum Priority {
  low('낮음', 1),
  medium('보통', 2),
  high('높음', 3);

  const Priority(this.displayName, this.value);

  final String displayName;
  final int value;

  static Priority fromValue(int value) {
    switch (value) {
      case 1:
        return Priority.low;
      case 2:
        return Priority.medium;
      case 3:
        return Priority.high;
      default:
        return Priority.medium; // 기본값
    }
  }

  static Priority fromString(String name) {
    switch (name) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        return Priority.medium; // 기본값
    }
  }
}
