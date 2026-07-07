const express = require('express');
const router = express.Router();
const { pool } = require('../db');

router.get('/', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT t.*, COUNT(tp.id)::int AS player_count
      FROM tournaments t
      LEFT JOIN tournament_players tp ON t.id = tp.tournament_id
      GROUP BY t.id
      ORDER BY t.id
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM tournaments WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Tournament not found' });
    }
    const tournament = result.rows[0];
    const playersResult = await pool.query(`
      SELECT p.*, tp.registered_at
      FROM tournament_players tp
      JOIN players p ON tp.player_id = p.id
      WHERE tp.tournament_id = $1
    `, [id]);
    tournament.players = playersResult.rows;
    res.json(tournament);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { name, description, start_date, end_date } = req.body;
    if (!name || !start_date || !end_date) {
      return res.status(400).json({ error: 'Name, start_date, and end_date are required' });
    }
    const result = await pool.query(
      'INSERT INTO tournaments (name, description, start_date, end_date, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [name, description || null, start_date, end_date, 'upcoming']
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, start_date, end_date, status } = req.body;
    const result = await pool.query(
      'UPDATE tournaments SET name = $1, description = $2, start_date = $3, end_date = $4, status = $5 WHERE id = $6 RETURNING *',
      [name, description, start_date, end_date, status, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Tournament not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM tournaments WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Tournament not found' });
    }
    res.json({ message: 'Tournament deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/:id/players', async (req, res) => {
  try {
    const { id } = req.params;
    const { player_id } = req.body;
    if (!player_id) {
      return res.status(400).json({ error: 'player_id is required' });
    }
    const tResult = await pool.query('SELECT * FROM tournaments WHERE id = $1', [id]);
    if (tResult.rows.length === 0) {
      return res.status(404).json({ error: 'Tournament not found' });
    }
    const pResult = await pool.query('SELECT * FROM players WHERE id = $1', [player_id]);
    if (pResult.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found' });
    }
    const result = await pool.query(
      'INSERT INTO tournament_players (tournament_id, player_id) VALUES ($1, $2) RETURNING *',
      [id, player_id]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    if (err.code === '23505') {
      return res.status(409).json({ error: 'Player already registered in this tournament' });
    }
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id/players/:playerId', async (req, res) => {
  try {
    const { id, playerId } = req.params;
    const result = await pool.query(
      'DELETE FROM tournament_players WHERE tournament_id = $1 AND player_id = $2 RETURNING *',
      [id, playerId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Player not found in tournament' });
    }
    res.json({ message: 'Player removed from tournament' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
