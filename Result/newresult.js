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
        select vote,count(voter_id) from voting group by vote;
      `);

    let html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Voting Results</title>
    </head>
    <body>
      <h1>Voting Results</h1>
      <table border="1">
          <tr>
            <th>Vote</th>
            <th>Count</th>
          </tr>
      `;

      // Iterate over the result and build the table rows
    result.rows.forEach(row => {
       html += `
        <tr>
        <td>${row.vote}</td>
        <td>${row.count}</td>
        </tr>
        `;
      });

    html += `
      </table>
    </body>
    </html>
    `;

    // Send the HTML as a response
    res.send(html);


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
