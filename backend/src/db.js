const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 5432,
  database: process.env.DB_NAME || 'chess_tournament',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

async function initDatabase() {
  const client = await pool.connect();
  try {
    const sqlPath = path.join(__dirname, 'schema.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    await client.query(sql);

    // Migration: Fix existing FK constraints for player deletes
    await client.query(`
      DO $$ BEGIN
        BEGIN
          ALTER TABLE matches DROP CONSTRAINT matches_player1_id_fkey;
        EXCEPTION WHEN undefined_object THEN NULL;
        END;
      END $$;
    `);
    await client.query(`
      DO $$ BEGIN
        BEGIN
          ALTER TABLE matches DROP CONSTRAINT matches_player2_id_fkey;
        EXCEPTION WHEN undefined_object THEN NULL;
        END;
      END $$;
    `);
    await client.query(`
      DO $$ BEGIN
        BEGIN
          ALTER TABLE matches DROP CONSTRAINT matches_winner_id_fkey;
        EXCEPTION WHEN undefined_object THEN NULL;
        END;
      END $$;
    `);
    await client.query(`
      ALTER TABLE matches ADD CONSTRAINT matches_player1_id_fkey
        FOREIGN KEY (player1_id) REFERENCES players(id) ON DELETE CASCADE;
    `);
    await client.query(`
      ALTER TABLE matches ADD CONSTRAINT matches_player2_id_fkey
        FOREIGN KEY (player2_id) REFERENCES players(id) ON DELETE CASCADE;
    `);
    await client.query(`
      ALTER TABLE matches ADD CONSTRAINT matches_winner_id_fkey
        FOREIGN KEY (winner_id) REFERENCES players(id) ON DELETE SET NULL;
    `);

    console.log('Database schema initialized successfully.');
  } catch (err) {
    console.error('Error initializing database:', err.message);
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { pool, initDatabase };
