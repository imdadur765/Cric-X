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
        title: "Gujarat Giants vs Delhi Capitals",
        subtitle: "WPL Eliminator • Today 7:30 PM",
        imageUrl: "https://images.unsplash.com/photo-1531415074984-6a8820809c76?q=80&w=1000&auto=format&fit=crop",
        streamUrl: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", // Reliable test stream
        isLive: true,
        category: "Cricket",
        headers: {}
    },
    {
        title: "DD Sports (Live)",
        subtitle: "Live TV Channel",
        imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/DD_Sports_logo.svg/1200px-DD_Sports_logo.svg.png",
        streamUrl: "https://d1388k3o9m3651.cloudfront.net/v1/master/9a06143c7b8979d39e836365b2632b8aa83f619e/dm-intro/intro.m3u8",
        isLive: true,
        category: "Live TV"
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

const { scrapeMatches } = require('./scraper');

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

// ADMIN: Trigger Scraper
app.post('/admin/scrape', async (req, res) => {
    console.log("[Admin] Triggering Scraper...");
    const newMatches = await scrapeMatches();
    if (newMatches.length > 0) {
        // Option 1: Replace all (Clean Slate)
        // matches = newMatches;

        // Option 2: Append (Keep old)
        matches = [...newMatches, ...matches];

        console.log(`[Admin] Scraper added ${newMatches.length} matches.`);
    }
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
