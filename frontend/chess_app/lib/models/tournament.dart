import 'player.dart';

class Tournament {
  final int? id;
  final String name;
  final String? description;
  final String startDate;
  final String endDate;
  final String status;
  final String? createdAt;
  final int? playerCount;
  final List<Player>? players;

  Tournament({
    this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    this.status = 'upcoming',
    this.createdAt,
    this.playerCount,
    this.players,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      status: json['status'] as String? ?? 'upcoming',
      createdAt: json['created_at'] as String?,
      playerCount: json['player_count'] as int?,
      players: json['players'] != null
          ? (json['players'] as List).map((e) => Player.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
    };
  }
}
