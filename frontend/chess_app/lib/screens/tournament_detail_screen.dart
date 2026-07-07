import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/tournament.dart';
import '../providers/tournament_provider.dart';
import '../providers/player_provider.dart';
import '../providers/match_provider.dart';
import 'match_screen.dart';
import 'ranking_screen.dart';
import 'tournament_form_screen.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final int tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen> {
  Tournament? _tournament;
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final t = await ref.read(tournamentProvider.notifier).getTournament(widget.tournamentId);
    if (mounted) {
      setState(() {
        _tournament = t;
        _loading = false;
      });
    }
  }

  Future<void> _addPlayer() async {
    await ref.read(playerProvider.notifier).loadPlayers();
    final players = ref.read(playerProvider);
    final registeredIds = (_tournament?.players ?? []).map((p) => p.id).toSet();
    final available = players.where((p) => !registeredIds.contains(p.id)).toList();

    if (available.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No available players to add')),
        );
      }
      return;
    }

    final selected = await showDialog<Player>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Player'),
        children: available.map((p) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, p),
          child: Text('${p.name} (${p.email})'),
        )).toList(),
      ),
    );

    if (selected != null && selected.id != null) {
      final success = await ref.read(tournamentProvider.notifier)
          .addPlayerToTournament(widget.tournamentId, selected.id!);
      if (success) {
        _load();
      }
    }
  }

  Future<void> _generateMatches() async {
    setState(() => _generating = true);
    final result = await ref.read(matchProvider.notifier).generateRound(widget.tournamentId);
    setState(() => _generating = false);
    if (result != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Round ${result.isNotEmpty ? result[0].round : '?'} generated!')),
        );
      }
      _load();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate matches. Need at least 2 players.')),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'upcoming': return Colors.blue;
      case 'ongoing': return Colors.orange;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final t = _tournament;
    if (t == null) {
      return const Scaffold(body: Center(child: Text('Tournament not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.name),
        actions: [
          if (t.status != 'completed')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TournamentFormScreen(tournament: t),
                  ),
                );
                if (result == true) _load();
              },
            ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Rankings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RankingScreen(tournamentId: widget.tournamentId),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(t.status.toUpperCase(),
                            style: const TextStyle(fontSize: 11, color: Colors.white)),
                        backgroundColor: _statusColor(t.status),
                      ),
                      const Spacer(),
                      Text('${t.players?.length ?? 0} players',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  if (t.description != null && t.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(t.description!),
                  ],
                  const SizedBox(height: 8),
                  Text('${t.startDate} to ${t.endDate}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Players', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (t.status == 'upcoming')
                FilledButton.tonalIcon(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if ((t.players ?? []).isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No players added yet.')))
          else
            ...t.players!.map((p) => Card(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: ListTile(
                leading: CircleAvatar(child: Text(p.name[0].toUpperCase())),
                title: Text(p.name),
                subtitle: Text(p.email),
                trailing: t.status == 'upcoming'
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () async {
                          await ref.read(tournamentProvider.notifier)
                              .removePlayerFromTournament(widget.tournamentId, p.id!);
                          _load();
                        },
                      )
                    : null,
              ),
            )),
          if (t.status != 'completed') ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _generating ? null : _generateMatches,
                icon: _generating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.shuffle),
                label: Text(_generating ? 'Generating...' : 'Generate Match Round'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MatchScreen(tournamentId: widget.tournamentId),
                ),
              ),
              icon: const Icon(Icons.scoreboard),
              label: const Text('View Matches'),
            ),
          ),
        ],
      ),
    );
  }
}
