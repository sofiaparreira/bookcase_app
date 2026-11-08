// Feito por: João e Sofia Parreira Passos
// Modelo de meta de leitura (uma meta pertence a um livro da estante)
class ReadingGoal {
  final int? id;
  final String title;
  final int bookId;
  final String? bookTitle;
  final String? bookAuthor;
  final int targetPages;
  final int currentPage;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? completedAt;

  const ReadingGoal({
    this.id,
    required this.title,
    required this.bookId,
    this.bookTitle,
    this.bookAuthor,
    required this.targetPages,
    this.currentPage = 0,
    required this.startDate,
    required this.endDate,
    this.completedAt,
  });

  double get progress =>
      targetPages <= 0 ? 0 : (currentPage / targetPages).clamp(0.0, 1.0);

  int get progressPercent => (progress * 100).round();

  bool get isCompleted => completedAt != null || progress >= 1;

  static int _asInt(Object? value) => switch (value) {
    int v => v,
    num v => v.toInt(),
    String v => int.tryParse(v) ?? 0,
    _ => 0,
  };

  factory ReadingGoal.fromJson(Map<String, dynamic> json) {
    final book = json['book'];
    final completedAt = json['completedAt'];

    return ReadingGoal(
      id: json['id'] == null ? null : _asInt(json['id']),
      title: json['title'] as String? ?? '',
      bookId: _asInt(json['bookId']),
      bookTitle: book is Map<String, dynamic> ? book['title'] as String? : null,
      bookAuthor: book is Map<String, dynamic>
          ? book['author'] as String?
          : null,
      targetPages: _asInt(json['targetPages']),
      currentPage: _asInt(json['currentPage']),
      startDate: DateTime.parse(json['startDate'] as String).toLocal(),
      endDate: DateTime.parse(json['endDate'] as String).toLocal(),
      completedAt: completedAt is String
          ? DateTime.parse(completedAt).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'title': title,
    'bookId': bookId,
    'targetPages': targetPages,
    'currentPage': currentPage,
    'startDate': startDate.toUtc().toIso8601String(),
    'endDate': endDate.toUtc().toIso8601String(),
  };

  ReadingGoal copyWith({int? currentPage, DateTime? Function()? completedAt}) {
    return ReadingGoal(
      id: id,
      title: title,
      bookId: bookId,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      targetPages: targetPages,
      currentPage: currentPage ?? this.currentPage,
      startDate: startDate,
      endDate: endDate,
      completedAt: completedAt != null ? completedAt() : this.completedAt,
    );
  }
}