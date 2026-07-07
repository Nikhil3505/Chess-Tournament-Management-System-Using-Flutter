const express = require('express');
const router = express.Router();
const { pool } = require('../db');

router.get('/tournament/:tournamentId', async (req, res) => {
  try {
    const { tournamentId } = req.params;
    const result = await pool.query(`
      SELECT m.*, p1.name AS player1_name, p2.name AS player2_name, pw.name AS winner_name
      FROM matches m
      JOIN players p1 ON m.player1_id = p1.id
      JOIN players p2 ON m.player2_id = p2.id
      LEFT JOIN players pw ON m.winner_id = pw.id
      WHERE m.tournament_id = $1
      ORDER BY m.round, m.id
    `, [tournamentId]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/generate/:tournamentId', async (req, res) => {
  const client = await pool.connect();
  try {
    const { tournamentId } = req.params;
    const tResult = await client.query('SELECT * FROM tournaments WHERE id = $1', [tournamentId]);
    if (tResult.rows.length === 0) {
      return res.status(404).json({ error: 'Tournament not found' });
    }
    const tournament = tResult.rows[0];
    if (tournament.status === 'completed') {
      return res.status(400).json({ error: 'Tournament is already completed' });
    }
    await client.query("UPDATE tournaments SET status = 'ongoing' WHERE id = $1", [tournamentId]);
    const existingMatches = await client.query(
      'SELECT COUNT(*)::int AS count FROM matches WHERE tournament_id = $1', [tournamentId]
    );
    const nextRound = existingMatches.rows[0].count > 0
      ? (await client.query(
          'SELECT MAX(round)::int AS max_round FROM matches WHERE tournament_id = $1', [tournamentId]
        )).rows[0].max_round + 1
      : 1;

    const playersResult = await client.query(`
      SELECT p.id, p.name
      FROM tournament_players tp
      JOIN players p ON tp.player_id = p.id
      WHERE tp.tournament_id = $1
    `, [tournamentId]);

    const allPlayers = playersResult.rows;
    if (allPlayers.length < 2) {
      return res.status(400).json({ error: 'Need at least 2 players in the tournament' });
    }

    let activePlayers = allPlayers;
    if (nextRound > 1) {
      const prevRoundWinners = await client.query(`
        SELECT DISTINCT winner_id AS id, p.name
        FROM matches m
        JOIN players p ON m.winner_id = p.id
        WHERE m.tournament_id = $1 AND m.round = $2 AND m.winner_id IS NOT NULL
      `, [tournamentId, nextRound - 1]);
      activePlayers = prevRoundWinners.rows;
    }

    if (activePlayers.length < 2) {
      if (activePlayers.length === 1) {
        await client.query("UPDATE tournaments SET status = 'completed' WHERE id = $1", [tournamentId]);
        return res.json({ message: 'Tournament completed', winner: activePlayers[0] });
      }
      return res.status(400).json({ error: 'Not enough players for a match' });
    }

    const shuffled = [...activePlayers].sort(() => Math.random() - 0.5);
    const matches = [];
    for (let i = 0; i < shuffled.length - 1; i += 2) {
      const p1 = shuffled[i];
      const p2 = shuffled[i + 1];
      const winner = Math.random() < 0.5 ? p1 : p2;
      const result = await client.query(
        `INSERT INTO matches (tournament_id, player1_id, player2_id, winner_id, round, status)
         VALUES ($1, $2, $3, $4, $5, 'completed') RETURNING *`,
        [tournamentId, p1.id, p2.id, winner.id, nextRound]
      );
      matches.push(result.rows[0]);
    }

    if (shuffled.length % 2 !== 0) {
      const byePlayer = shuffled[shuffled.length - 1];
      const byeResult = await client.query(
        `INSERT INTO matches (tournament_id, player1_id, player2_id, winner_id, round, status)
         VALUES ($1, $2, $3, $4, $5, 'completed') RETURNING *`,
        [tournamentId, byePlayer.id, byePlayer.id, byePlayer.id, nextRound]
      );
      matches.push(byeResult.rows[0]);
    }

    const winnersCount = matches.filter(m => m.winner_id).length;
    if (winnersCount <= 1) {
      await client.query("UPDATE tournaments SET status = 'completed' WHERE id = $1", [tournamentId]);
    }

    res.status(201).json({ round: nextRound, matches });
  } catch (err) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

module.exports = router;
