const express = require('express');
const app = express();

// Serve static HTML
app.use(express.static(__dirname));

// API endpoint to return the sum
app.get('/sum', (req, res) => {
    const sum = 5 + 3;
    res.json({ result: sum });
});

// Start the server on port 3000
app.listen(3000, () => {
    console.log('Server is running on http://localhost:3000');
});
