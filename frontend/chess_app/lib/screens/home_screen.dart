import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Tournament Manager'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    Text('Chess Tournament', style: theme.textTheme.headlineSmall),
                    Text('Management System', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Manage players, tournaments, matches, and rankings',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _MenuCard(
                    icon: Icons.people,
                    label: 'Players',
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, '/players'),
                  ),
                  _MenuCard(
                    icon: Icons.emoji_events,
                    label: 'Tournaments',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/tournaments'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
