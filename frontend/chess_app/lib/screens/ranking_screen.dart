import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ranking_provider.dart';

class RankingScreen extends ConsumerStatefulWidget {
  final int tournamentId;

  const RankingScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  Map<String, dynamic>? _podiumData;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(rankingProvider.notifier).loadRankings(widget.tournamentId);
      final data = await ref.read(rankingProvider.notifier).getPodium(widget.tournamentId);
      if (mounted) {
        setState(() => _podiumData = data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rankingsAsync = ref.watch(rankingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rankings')),
      body: rankingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rankings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_podiumData != null) ...[
                const Text('Podium', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _PodiumWidget(podiumData: _podiumData!),
                const SizedBox(height: 24),
              ],
              const Text('All Rankings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...rankings.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final r = entry.value;
                IconData icon;
                Color color;
                if (rank == 1) {
                  icon = Icons.emoji_events;
                  color = Colors.amber;
                } else if (rank == 2) {
                  icon = Icons.emoji_events;
                  color = Colors.grey;
                } else if (rank == 3) {
                  icon = Icons.emoji_events;
                  color = Colors.brown;
                } else {
                  icon = Icons.circle;
                  color = Colors.grey.shade300;
                }
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(icon, color: color),
                    ),
                    title: Text('$rank. ${r.name}'),
                    subtitle: Text('Wins: ${r.wins} | Matches: ${r.matchesPlayed}'),
                    trailing: rank <= 3
                        ? Chip(
                            label: Text(
                              rank == 1 ? '1st' : rank == 2 ? '2nd' : '3rd',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            backgroundColor: color,
                          )
                        : null,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _PodiumWidget extends StatelessWidget {
  final Map<String, dynamic> podiumData;

  const _PodiumWidget({required this.podiumData});

  @override
  Widget build(BuildContext context) {
    final podium = (podiumData['podium'] as List?)
        ?.map((e) => PodiumEntry(
              id: e['id'] as int,
              name: e['name'] as String,
              wins: e['wins'] as int? ?? 0,
              rank: e['rank'] as int,
              label: e['label'] as String,
            ))
        .toList() ?? [];

    if (podium.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No rankings yet')));
    }

    final sorted = [...podium]..sort((a, b) => a.rank.compareTo(b.rank));
    final first = sorted.isNotEmpty ? sorted[0] : null;
    final second = sorted.length > 1 ? sorted[1] : null;
    final third = sorted.length > 2 ? sorted[2] : null;

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (second != null)
            _PodiumBar(
              label: second.name,
              place: '2nd',
              height: 120,
              color: Colors.grey,
              wins: second.wins,
            ),
          if (first != null)
            _PodiumBar(
              label: first.name,
              place: '1st',
              height: 180,
              color: Colors.amber,
              wins: first.wins,
            ),
          if (third != null)
            _PodiumBar(
              label: third.name,
              place: '3rd',
              height: 90,
              color: Colors.brown,
              wins: third.wins,
            ),
        ],
      ),
    );
  }
}

class PodiumEntry {
  final int id;
  final String name;
  final int wins;
  final int rank;
  final String label;

  PodiumEntry({
    required this.id,
    required this.name,
    required this.wins,
    required this.rank,
    required this.label,
  });
}

class _PodiumBar extends StatelessWidget {
  final String label;
  final String place;
  final double height;
  final Color color;
  final int wins;

  const _PodiumBar({
    required this.label,
    required this.place,
    required this.height,
    required this.color,
    required this.wins,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: color, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: color, size: 28),
                Text(place, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                Text('${wins}W', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
