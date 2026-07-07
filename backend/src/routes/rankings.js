const express = require('express');
const router = express.Router();
const { pool } = require('../db');

router.get('/:tournamentId', async (req, res) => {
  try {
    const { tournamentId } = req.params;
    const tResult = await pool.query('SELECT * FROM tournaments WHERE id = $1', [tournamentId]);
    if (tResult.rows.length === 0) {
      return res.status(404).json({ error: 'Tournament not found' });
    }
    const result = await pool.query(`
      SELECT p.id, p.name, COUNT(CASE WHEN m.winner_id = p.id THEN 1 END)::int AS wins,
             COUNT(m.id)::int AS matches_played
      FROM tournament_players tp
      JOIN players p ON tp.player_id = p.id
      LEFT JOIN matches m ON m.tournament_id = tp.tournament_id
        AND (m.player1_id = p.id OR m.player2_id = p.id)
        AND m.status = 'completed'
      WHERE tp.tournament_id = $1
      GROUP BY p.id, p.name
      ORDER BY wins DESC, matches_played DESC
    `, [tournamentId]);
    const rankings = result.rows;
    let podium = [];
    if (rankings.length >= 1) podium.push({ ...rankings[0], rank: 1, label: '1st Place' });
    if (rankings.length >= 2) podium.push({ ...rankings[1], rank: 2, label: '2nd Place' });
    if (rankings.length >= 3) podium.push({ ...rankings[2], rank: 3, label: '3rd Place' });
    res.json({ tournament_id: tournamentId, rankings, podium });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
