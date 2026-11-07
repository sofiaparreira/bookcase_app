class ReadingGoal {
  final int? id;
  final String title;
  final int targetBooks;
  final int currentBooks;
  final DateTime startDate;
  final DateTime endDate;

  const ReadingGoal({
    this.id,
    required this.title,
    required this.targetBooks,
    this.currentBooks = 0,
    required this.startDate,
    required this.endDate,
  });

  double get progress =>
      targetBooks <= 0 ? 0 : (currentBooks / targetBooks).clamp(0.0, 1.0);

  int get progressPercent => (progress * 100).round();

  factory ReadingGoal.fromJson(Map<String, dynamic> json) {
    return ReadingGoal(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      targetBooks: json['targetBooks'] as int? ?? 0,
      currentBooks: json['currentBooks'] as int? ?? 0,
      startDate: DateTime.parse(json['startDate'] as String).toLocal(),
      endDate: DateTime.parse(json['endDate'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'targetBooks': targetBooks,
        'currentBooks': currentBooks,
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
      };
}