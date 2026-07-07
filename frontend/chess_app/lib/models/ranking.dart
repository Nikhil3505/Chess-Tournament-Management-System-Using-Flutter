class RankingEntry {
  final int id;
  final String name;
  final int wins;
  final int matchesPlayed;

  RankingEntry({
    required this.id,
    required this.name,
    required this.wins,
    required this.matchesPlayed,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      id: json['id'] as int,
      name: json['name'] as String,
      wins: json['wins'] as int? ?? 0,
      matchesPlayed: json['matches_played'] as int? ?? 0,
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

  factory PodiumEntry.fromJson(Map<String, dynamic> json) {
    return PodiumEntry(
      id: json['id'] as int,
      name: json['name'] as String,
      wins: json['wins'] as int? ?? 0,
      rank: json['rank'] as int,
      label: json['label'] as String,
    );
  }
}
