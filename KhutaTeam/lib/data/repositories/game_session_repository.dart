import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/game_session.dart';

/// يحفظ جلسات اللعبة محلياً — لا يحتاج Firebase
class GameSessionRepository {
  static const String _prefix = 'game_sessions_';
  static const _uuid = Uuid();

  static Future<String> saveSession(
      String childId, GameSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final id = _uuid.v4();
    final sessions = await getSessionHistory(childId);

    final newSession = GameSession(
      id: id,
      childId: childId,
      date: session.date,
      durationSeconds: session.durationSeconds,
      taskResults: session.taskResults,
      finalDifficulty: session.finalDifficulty,
    );

    sessions.insert(0, newSession);
    final trimmed = sessions.take(50).toList();
    final encoded = trimmed.map((s) => jsonEncode(s.toMap())).toList();
    await prefs.setStringList('$_prefix$childId', encoded);

    if (kDebugMode) debugPrint('Game session saved: $id');
    return id;
  }

  static Future<List<GameSession>> getSessionHistory(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_prefix$childId') ?? [];
    return raw.map((s) {
      try {
        return GameSession.fromMap(jsonDecode(s));
      } catch (e) {
        return null;
      }
    }).whereType<GameSession>().toList();
  }

  static Future<int> getLastDifficulty(String childId) async {
    final sessions = await getSessionHistory(childId);
    if (sessions.isEmpty) return 1;
    return sessions.first.finalDifficulty;
  }
}
