import 'package:bookcase/features/auth/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakStore extends ChangeNotifier {
  StreakStore({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static final StreakStore instance = StreakStore();

  final DateTime Function() _clock;

  final Set<DateTime> _activeDays = {};

  DateTime get _today => _dateOnly(_clock());

  Future<void> load() async {
    final preferencesKey = _preferencesKey;
    if (preferencesKey == null) return;

    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getStringList(preferencesKey) ?? [];
      final hadUnsavedDays = _activeDays.isNotEmpty;

      for (final value in saved) {
        final day = DateTime.tryParse(value);
        if (day != null) _activeDays.add(_dateOnly(day));
      }

      if (hadUnsavedDays) await _persist();
      notifyListeners();
    } catch (error) {
      debugPrint('[StreakStore] Não foi possível ler a ofensiva: $error');
    }
  }

  void registerActivity() {
    if (!_activeDays.add(_today)) return;

    notifyListeners();
    _persist();
  }

  void clear() {
    _activeDays.clear();
    notifyListeners();
  }

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

  List<bool> get weekActivity {
    final monday = _currentMonday;

    return List.generate(7, (index) {
      return _activeDays.contains(
        DateTime(monday.year, monday.month, monday.day + index),
      );
    });
  }

  DateTime get _currentMonday {
    final today = _today;
    return DateTime(today.year, today.month, today.day - (today.weekday - 1));
  }

  Future<void> _persist() async {
    final preferencesKey = _preferencesKey;
    if (preferencesKey == null) return;

    _removeUnusedDays();

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        preferencesKey,
        _activeDays.map(_formatDay).toList()..sort(),
      );
    } catch (error) {
      debugPrint('[StreakStore] Não foi possível salvar a ofensiva: $error');
    }
  }

  // Mantém só a ofensiva atual e a semana atual para a lista salva não crescer
  void _removeUnusedDays() {
    var oldestNeeded = _currentMonday;
    var day = _today;
    if (!_activeDays.contains(day)) day = _previousDay(day);
    while (_activeDays.contains(day)) {
      if (day.isBefore(oldestNeeded)) oldestNeeded = day;
      day = _previousDay(day);
    }

    _activeDays.removeWhere((day) => day.isBefore(oldestNeeded));
  }

  // E-mail em vez de id: o id só chega depois que a sessão é validada na API
  String? get _preferencesKey {
    final email = AuthService().currentUser?.email.trim().toLowerCase();
    if (email == null || email.isEmpty) return null;
    return 'bookcase_streak_$email';
  }

  static String _formatDay(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  static DateTime _previousDay(DateTime day) =>
      DateTime(day.year, day.month, day.day - 1);

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
