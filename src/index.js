const express = require('express');
const bodyParser = require('body-parser');
const db = require('./firebase');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(bodyParser.json());

// Basic health
app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'lemonaide-reservations' });
});

// POST /reservations
// body: { instrument_id, user_id, start_date, end_date }
app.post('/reservations', async (req, res) => {
  try {
    const { instrument_id, user_id, start_date, end_date } = req.body;
    if (!instrument_id || !user_id || !start_date || !end_date) {
      return res.status(400).json({ error: 'instrument_id, user_id, start_date and end_date are required' });
    }

    const start = new Date(start_date);
    const end = new Date(end_date);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      return res.status(400).json({ error: 'start_date and end_date must be valid ISO date strings' });
    }
    if (end <= start) {
      return res.status(400).json({ error: 'end_date must be after start_date' });
    }

    const id = uuidv4();
    const reservation = {
      id,
      instrument_id,
      user_id,
      start_date: start.toISOString(),
      end_date: end.toISOString(),
      approved: false
    };

    await db.collection('reservation').doc(id).set(reservation);

    res.status(201).json({ reservation });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'internal_error' });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`lemonaide-reservations running on port ${port}`);
});
