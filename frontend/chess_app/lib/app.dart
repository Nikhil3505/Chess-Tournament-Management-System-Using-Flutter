import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'screens/player_form_screen.dart';
import 'screens/tournament_screen.dart';
import 'screens/tournament_form_screen.dart';

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Tournament Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
      routes: {
        '/players': (_) => const PlayerScreen(),
        '/players/add': (_) => const PlayerFormScreen(),
        '/tournaments': (_) => const TournamentScreen(),
        '/tournaments/add': (_) => const TournamentFormScreen(),
      },
    );
  }
}
