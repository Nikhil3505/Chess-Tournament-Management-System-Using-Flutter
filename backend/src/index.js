const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const { initDatabase } = require('./db');
const playersRouter = require('./routes/players');
const tournamentsRouter = require('./routes/tournaments');
const matchesRouter = require('./routes/matches');
const rankingsRouter = require('./routes/rankings');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/players', playersRouter);
app.use('/api/tournaments', tournamentsRouter);
app.use('/api/matches', matchesRouter);
app.use('/api/rankings', rankingsRouter);

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

async function start() {
  try {
    await initDatabase();
    app.listen(PORT, () => {
      console.log(`Chess Tournament API running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err.message);
    process.exit(1);
  }
}

start();
