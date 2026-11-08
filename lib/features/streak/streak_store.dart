import 'package:flutter/foundation.dart';

// Ofensiva (streak) de leitura: o usuário ganha o dia ao começar a ler um
// livro ou avançar o progresso. Um dia inteiro sem atividade zera a contagem.
class StreakStore extends ChangeNotifier {
  StreakStore({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static final StreakStore instance = StreakStore();

  final DateTime Function() _clock;

  // Dias com atividade, sempre normalizados para meia-noite (horário local)
  final Set<DateTime> _activeDays = {};

  DateTime get _today => _dateOnly(_clock());

  void registerActivity() {
    if (_activeDays.add(_today)) notifyListeners();
  }

  // Dias seguidos até hoje. Se ainda não houve atividade hoje, a ofensiva
  // de ontem continua valendo até o dia acabar.
  int get currentStreak {
    var day = _today;
    if (!_activeDays.contains(day)) day = _previousDay(day);

    var streak = 0;
    while (_activeDays.contains(day)) {
      streak++;
      day = _previousDay(day);
    }
    return streak;
  }

  // Dias da semana atual (seg → dom) em que houve atividade
  List<bool> get weekActivity {
    final today = _today;
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );

    return List.generate(7, (index) {
      return _activeDays.contains(
        DateTime(monday.year, monday.month, monday.day + index),
      );
    });
  }

  // Usa o construtor de DateTime em vez de subtract(Duration(days: 1)) para
  // não errar o dia em trocas de horário de verão
  static DateTime _previousDay(DateTime day) =>
      DateTime(day.year, day.month, day.day - 1);

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
