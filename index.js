const express = require('express');
const bodyParser = require('body-parser');
const Airtable = require('airtable');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors());

const apiKey = 'keycaST0E770p7HWb';
const baseId = 'appJYghlwwJ41QRkx';
const tableName = 'Tips';
const airtable = new Airtable({ apiKey }).base(baseId);

app.get('/tips', async (req, res) => {
  try {
    const tips = await airtable(tableName).select().all();
    res.json(tips.map((record) => record.fields));
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch tips' });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server listening on port ${port}`));
