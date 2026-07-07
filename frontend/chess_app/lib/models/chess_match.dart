class ChessMatch {
  final int? id;
  final int tournamentId;
  final int player1Id;
  final int player2Id;
  final int? winnerId;
  final int round;
  final String status;
  final String? createdAt;
  final String? player1Name;
  final String? player2Name;
  final String? winnerName;

  ChessMatch({
    this.id,
    required this.tournamentId,
    required this.player1Id,
    required this.player2Id,
    this.winnerId,
    this.round = 1,
    this.status = 'pending',
    this.createdAt,
    this.player1Name,
    this.player2Name,
    this.winnerName,
  });

  factory ChessMatch.fromJson(Map<String, dynamic> json) {
    return ChessMatch(
      id: json['id'] as int?,
      tournamentId: json['tournament_id'] as int,
      player1Id: json['player1_id'] as int,
      player2Id: json['player2_id'] as int,
      winnerId: json['winner_id'] as int?,
      round: json['round'] as int? ?? 1,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String?,
      player1Name: json['player1_name'] as String?,
      player2Name: json['player2_name'] as String?,
      winnerName: json['winner_name'] as String?,
    );
  }
}
