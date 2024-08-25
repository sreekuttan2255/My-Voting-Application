const express = require('express');
const { Pool } = require('pg');
const app = express();
const port = 3000;

// Database connection pool
const pool = new Pool({
  host: 'db', // PostgreSQL service name from Docker Compose
  user: 'postgres',
  password: 'postgres',
  database: 'db',
  port: 5432, // Default PostgreSQL port
});

// Route to fetch and display the voting results
app.get('/results', async (req, res) => {
  try {
    const client = await pool.connect();

    // Query to count votes for each option
    const result = await client.query(`
      SELECT vote, COUNT(*) AS count 
      FROM votes 
      GROUP BY vote
    `);

    const votes = result.rows.reduce((acc, row) => {
      acc[row.vote] = row.count;
      return acc;
    }, {});

    // Render a simple HTML page with the results
    res.send(`
      <html>
      <head>
        <title>Voting Results</title>
      </head>
      <body>
        <h1>Voting Results</h1>
        <table border="1">
          <thead>
            <tr>
              <th>Option</th>
              <th>Votes</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Cats</td>
              <td>${votes.Cats || 0}</td>
            </tr>
            <tr>
              <td>Dogs</td>
              <td>${votes.Dogs || 0}</td>
            </tr>
          </tbody>
        </table>
      </body>
      </html>
    `);

    client.release();
  } catch (err) {
    console.error(err);
    res.status(500).send('Error fetching voting results');
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Voting results app listening at http://localhost:${port}`);
});
