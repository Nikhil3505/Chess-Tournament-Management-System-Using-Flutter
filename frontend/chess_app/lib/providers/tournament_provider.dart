import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tournament.dart';
import 'api_provider.dart';

class TournamentNotifier extends StateNotifier<List<Tournament>> {
  final ApiService _api;

  TournamentNotifier(this._api) : super([]);

  Future<void> loadTournaments() async {
    try {
      final response = await _api.get('/tournaments');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        state = data.map((e) => Tournament.fromJson(e)).toList();
      }
    } catch (e) {
      state = [];
    }
  }

  Future<Tournament?> getTournament(int id) async {
    try {
      final response = await _api.get('/tournaments/$id');
      if (response.statusCode == 200) {
        return Tournament.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> addTournament(Tournament tournament) async {
    try {
      final response = await _api.post('/tournaments', tournament.toJson());
      if (response.statusCode == 201) {
        await loadTournaments();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTournament(int id, Tournament tournament) async {
    try {
      final response = await _api.put('/tournaments/$id', tournament.toJson());
      if (response.statusCode == 200) {
        await loadTournaments();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTournament(int id) async {
    try {
      final response = await _api.delete('/tournaments/$id');
      if (response.statusCode == 200) {
        await loadTournaments();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addPlayerToTournament(int tournamentId, int playerId) async {
    try {
      final response = await _api.post('/tournaments/$tournamentId/players', {
        'player_id': playerId,
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removePlayerFromTournament(int tournamentId, int playerId) async {
    try {
      final response = await _api.delete('/tournaments/$tournamentId/players/$playerId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final tournamentProvider = StateNotifierProvider<TournamentNotifier, List<Tournament>>((ref) {
  return TournamentNotifier(ref.watch(apiServiceProvider));
});

final selectedTournamentProvider = StateProvider<Tournament?>((ref) => null);
