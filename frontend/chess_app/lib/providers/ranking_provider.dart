import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ranking.dart';
import 'api_provider.dart';

class RankingNotifier extends StateNotifier<AsyncValue<List<RankingEntry>>> {
  final ApiService _api;

  RankingNotifier(this._api) : super(const AsyncLoading());

  Future<void> loadRankings(int tournamentId) async {
    state = const AsyncLoading();
    try {
      final response = await _api.get('/rankings/$tournamentId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rankings = (data['rankings'] as List)
            .map((e) => RankingEntry.fromJson(e))
            .toList();
        state = AsyncData(rankings);
      } else {
        state = AsyncError('Failed to load rankings', StackTrace.current);
      }
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }

  Future<Map<String, dynamic>?> getPodium(int tournamentId) async {
    try {
      final response = await _api.get('/rankings/$tournamentId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final rankingProvider =
    StateNotifierProvider<RankingNotifier, AsyncValue<List<RankingEntry>>>((ref) {
  return RankingNotifier(ref.watch(apiServiceProvider));
});
