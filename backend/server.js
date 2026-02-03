const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

app.set('view engine', 'ejs');
app.use(bodyParser.urlencoded({ extended: true }));

// In-memory "Database"
let matches = [
    {
        title: "IND vs AUS | Finals",
        subtitle: "Live from Server",
        imageUrl: "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?q=80&w=2000&auto=format&fit=crop",
        streamUrl: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
        isLive: true,
        category: "Cricket"
    },
    {
        title: "Big Buck Bunny",
        subtitle: "Animated Movie",
        imageUrl: "https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=2000&auto=format&fit=crop",
        streamUrl: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
        isLive: false,
        category: "Movies"
    }
];

// --- ROUTES ---

// API: Get Matches (For App)
app.get('/matches', (req, res) => {
    res.json(matches);
});

// ADMIN: Dashboard (For You)
app.get('/admin', (req, res) => {
    res.render('admin', { matches: matches });
});

// ADMIN: Add Match
app.post('/admin/add', (req, res) => {
    const { title, subtitle, imageUrl, streamUrl, isLive, category, headers } = req.body;

    let parsedHeaders = {};
    if (headers && headers.trim().length > 0) {
        try {
            parsedHeaders = JSON.parse(headers);
        } catch (e) {
            console.error("Invalid JSON headers:", headers);
        }
    }

    matches.unshift({
        title,
        subtitle,
        imageUrl,
        streamUrl,
        isLive: isLive === 'true',
        category: category || "Cricket",
        headers: parsedHeaders
    });
    console.log(`[Admin] Added: ${title} (${category})`);
    res.redirect('/admin');
});

// ADMIN: Delete Match
app.post('/admin/delete', (req, res) => {
    const { index } = req.body;
    if (index >= 0 && index < matches.length) {
        console.log(`[Admin] Deleted: ${matches[index].title}`);
        matches.splice(index, 1);
    }
    res.redirect('/admin');
});

app.listen(PORT, () => {
    console.log(`\n🚀 SERVER STARTED 🚀`);
    console.log(`- App API:   http://localhost:${PORT}/matches`);
    console.log(`- Admin UI:  http://localhost:${PORT}/admin`);
});
