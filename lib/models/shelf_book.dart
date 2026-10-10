// Feito por: Maria Luiza Bertolino Matos
import 'package:bookcase/models/book.dart';

class ShelfBook {
  final Book book;
  final EnumBookStatus status;

  final double progress;

  final int totalPages;

  final int? rating;
  final DateTime? finishedAt;

  const ShelfBook({
    required this.book,
    required this.status,
    required this.progress,
    required this.totalPages,
    this.rating,
    this.finishedAt,
  });

  int get progressPercent => (progress * 100).round();

  int get currentPage => (progress * totalPages).round();

  ShelfBook copyWith({
    EnumBookStatus? status,
    double? progress,
    int? totalPages,
    int? Function()? rating,
    DateTime? Function()? finishedAt,
  }) {
    return ShelfBook(
      book: book,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalPages: totalPages ?? this.totalPages,
      rating: rating != null ? rating() : this.rating,
      finishedAt: finishedAt != null ? finishedAt() : this.finishedAt,
    );
  }
}

extension EnumBookStatusLabel on EnumBookStatus {
  String get label => switch (this) {
    EnumBookStatus.want => 'Quero ler',
    EnumBookStatus.reading => 'Lendo',
    EnumBookStatus.finished => 'Lido',
  };
}
