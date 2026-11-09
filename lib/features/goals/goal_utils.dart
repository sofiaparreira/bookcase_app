import 'package:bookcase/models/book.dart';

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String cleanError(Object e) => e.toString().replaceFirst('Exception: ', '');

int currentPageForGoal({required Book book, required int targetPages}) {
  if (book.status == EnumBookStatus.finished) return targetPages;
  return book.currentPage.clamp(0, targetPages);
}

DateTime firstSelectableGoalDate({required bool isStart, DateTime? now}) {
  if (isStart) return DateTime(1900);
  final date = now ?? DateTime.now();
  return DateTime(date.year, date.month, date.day);
}

DateTime initialGoalPickerDate({
  required DateTime selectedDate,
  required bool isStart,
  DateTime? now,
}) {
  final firstDate = firstSelectableGoalDate(isStart: isStart, now: now);
  final selected = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  return selected.isBefore(firstDate) ? firstDate : selected;
}

bool isSelectableGoalEndDate(DateTime date, {DateTime? now}) {
  final today = firstSelectableGoalDate(isStart: false, now: now);
  final candidate = DateTime(date.year, date.month, date.day);
  return !candidate.isBefore(today);
}

String? allBookPagesOptionLabel(int totalPages) =>
    totalPages > 0 ? 'Todas as páginas do livro ($totalPages)' : null;

bool isUsingAllBookPages(bool? value) => value ?? false;

int resolveBookTotalPages({
  required int savedTotal,
  required int metadataTotal,
}) => savedTotal > 0 ? savedTotal : metadataTotal;

bool isEligibleGoalBookStatus(EnumBookStatus status) =>
    status == EnumBookStatus.reading || status == EnumBookStatus.want;

int? goalTargetPages({
  required String typedValue,
  required bool useAllBookPages,
  required int bookTotalPages,
}) {
  if (useAllBookPages && bookTotalPages > 0) return bookTotalPages;
  return int.tryParse(typedValue.trim());
}
