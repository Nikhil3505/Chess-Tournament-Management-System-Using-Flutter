import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import 'api_provider.dart';

class PlayerNotifier extends StateNotifier<List<Player>> {
  final ApiService _api;

  PlayerNotifier(this._api) : super([]);

  Future<void> loadPlayers() async {
    try {
      final response = await _api.get('/players');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        state = data.map((e) => Player.fromJson(e)).toList();
      }
    } catch (e) {
      state = [];
    }
  }

  Future<String?> addPlayer(Player player) async {
    try {
      final response = await _api.post('/players', player.toJson());
      if (response.statusCode == 201) {
        await loadPlayers();
        return null;
      }
      final body = jsonDecode(response.body);
      return body['error'] ?? 'Failed to add player';
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  Future<String?> updatePlayer(int id, Player player) async {
    try {
      final response = await _api.put('/players/$id', player.toJson());
      if (response.statusCode == 200) {
        await loadPlayers();
        return null;
      }
      final body = jsonDecode(response.body);
      return body['error'] ?? 'Failed to update player';
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  Future<String?> deletePlayer(int id) async {
    try {
      final response = await _api.delete('/players/$id');
      if (response.statusCode == 200) {
        await loadPlayers();
        return null;
      }
      final body = jsonDecode(response.body);
      return body['error'] ?? 'Failed to delete player';
    } catch (e) {
      return 'Connection error: $e';
    }
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, List<Player>>((ref) {
  return PlayerNotifier(ref.watch(apiServiceProvider));
});
