import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chess_match.dart';
import 'api_provider.dart';

class MatchNotifier extends StateNotifier<List<ChessMatch>> {
  final ApiService _api;

  MatchNotifier(this._api) : super([]);

  Future<void> loadMatches(int tournamentId) async {
    try {
      final response = await _api.get('/matches/tournament/$tournamentId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        state = data.map((e) => ChessMatch.fromJson(e)).toList();
      }
    } catch (e) {
      state = [];
    }
  }

  Future<List<ChessMatch>?> generateRound(int tournamentId) async {
    try {
      final response = await _api.post('/matches/generate/$tournamentId', {});
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final matches = (data['matches'] as List)
            .map((e) => ChessMatch.fromJson(e))
            .toList();
        await loadMatches(tournamentId);
        return matches;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final matchProvider = StateNotifierProvider<MatchNotifier, List<ChessMatch>>((ref) {
  return MatchNotifier(ref.watch(apiServiceProvider));
});
