import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_provider.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final int tournamentId;

  const MatchScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(matchProvider.notifier).loadMatches(widget.tournamentId));
  }

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(matchProvider);
    final rounds = matches.map((m) => m.round).toSet().toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: matches.isEmpty
          ? const Center(child: Text('No matches yet. Generate rounds from tournament details.'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: rounds.map((round) {
                final roundMatches = matches.where((m) => m.round == round).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Round $round',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    ...roundMatches.map((m) {
                      final isBye = m.player1Id == m.player2Id;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.player1Name ?? 'Player #${m.player1Id}',
                                      style: TextStyle(
                                        fontWeight: m.winnerId == m.player1Id
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: m.winnerId == m.player1Id
                                            ? Colors.green
                                            : null,
                                      ),
                                    ),
                                    if (!isBye) ...[
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4),
                                        child: Text('vs', textAlign: TextAlign.center),
                                      ),
                                      Text(
                                        m.player2Name ?? 'Player #${m.player2Id}',
                                        style: TextStyle(
                                          fontWeight: m.winnerId == m.player2Id
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: m.winnerId == m.player2Id
                                              ? Colors.green
                                              : null,
                                        ),
                                      ),
                                    ],
                                    if (isBye)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Text('(Bye)', style: TextStyle(color: Colors.grey)),
                                      ),
                                  ],
                                ),
                              ),
                              if (m.winnerName != null)
                                Chip(
                                  label: Text(m.winnerName!, style: const TextStyle(fontSize: 11)),
                                  avatar: const Icon(Icons.emoji_events, size: 16),
                                  backgroundColor: Colors.amber.shade100,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
