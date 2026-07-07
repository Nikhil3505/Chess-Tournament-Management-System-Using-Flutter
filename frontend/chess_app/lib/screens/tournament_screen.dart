import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tournament_provider.dart';
import 'tournament_form_screen.dart';
import 'tournament_detail_screen.dart';

class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tournamentProvider.notifier).loadTournaments());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const TournamentFormScreen()),
          );
          if (result == true) {
            ref.read(tournamentProvider.notifier).loadTournaments();
          }
        },
      ),
      body: tournaments.isEmpty
          ? const Center(child: Text('No tournaments found. Create one!'))
          : ListView.builder(
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final t = tournaments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: Text(t.name),
                    subtitle: Text('${t.startDate} - ${t.endDate}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(t.status.toUpperCase(),
                              style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: _statusColor(t.status),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 4),
                        Text('${t.playerCount ?? 0} players'),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TournamentDetailScreen(tournamentId: t.id!),
                        ),
                      );
                      ref.read(tournamentProvider.notifier).loadTournaments();
                    },
                  ),
                );
              },
            ),
    );
  }
}
