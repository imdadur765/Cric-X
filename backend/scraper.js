const axios = require('axios');
const cheerio = require('cheerio');

// Configuration: Replace with your Target Source
// For now, using a test gist that simulates a raw text list of streams
const SOURCE_URL = "https://gist.githubusercontent.com/imdadur-rahman/dummy/raw/streams.txt";

async function scrapeMatches() {
    console.log(`[Scraper] Fetching data from: ${SOURCE_URL}`);
    try {
        const response = await axios.get(SOURCE_URL);
        const data = response.data;

        // Use Cheerio/Regex to parse. 
        // For this simple example, we'll assume the text is a list of links.
        // In a real scenario, we would parse HTML.
        const lines = data.split('\n');
        const newMatches = [];

        lines.forEach((line, index) => {
            if (line.includes('.m3u8')) {
                // Determine category based on keywords
                let category = "Live TV";
                if (line.toLowerCase().includes('cricket') || line.toLowerCase().includes('ipl')) category = "Cricket";
                if (line.toLowerCase().includes('movie')) category = "Movies";

                newMatches.push({
                    title: `Auto Stream ${index + 1}`,
                    subtitle: "Auto-fetched via Scraper",
                    imageUrl: "https://via.placeholder.com/300?text=Live+Stream",
                    streamUrl: line.trim(),
                    isLive: true,
                    category: category,
                    headers: { "User-Agent": "Mozilla/5.0" } // Default header
                });
            }
        });

        console.log(`[Scraper] Found ${newMatches.length} streams.`);
        return newMatches;

    } catch (error) {
        console.error(`[Scraper] Error: ${error.message}`);
        return [];
    }
}

module.exports = { scrapeMatches };
