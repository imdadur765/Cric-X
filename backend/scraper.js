const axios = require('axios');

// PUBLIC SOURCE: India specific channels (Free-to-air)
// NOTE: For Star/Willow, user needs to replace this URL with a Premium M3U link.
const SOURCE_URL = "https://iptv-org.github.io/iptv/countries/in.m3u";

async function scrapeMatches() {
    console.log(`[Scraper] Fetching M3U data from: ${SOURCE_URL}`);
    try {
        const response = await axios.get(SOURCE_URL);
        const data = response.data;

        // M3U Parsing Logic
        const lines = data.split('\n');
        const newMatches = [];
        let currentTitle = "";
        let currentLogo = "";
        let currentGroup = "";

        lines.forEach((line) => {
            line = line.trim();
            if (line.startsWith('#EXTINF')) {
                // Extract Meta Data
                // Example: #EXTINF:-1 tvg-logo="url" group-title="Sports", Channel Name
                const titleMatch = line.match(/,(.+)$/);
                currentTitle = titleMatch ? titleMatch[1].trim() : "Unknown Channel";

                const logoMatch = line.match(/tvg-logo="([^"]*)"/);
                currentLogo = logoMatch ? logoMatch[1] : "https://via.placeholder.com/300?text=TV";

                const groupMatch = line.match(/group-title="([^"]*)"/);
                currentGroup = groupMatch ? groupMatch[1] : "General";

            } else if (line.startsWith('http')) {
                // This is the Link
                // FILTER: Only pick Sports or specific channels to keep list clean
                const keywords = ['cricket', 'sport', 'star', 'willow', 'dd sports', 'sony'];
                const isSports = keywords.some(k => currentTitle.toLowerCase().includes(k) || currentGroup.toLowerCase().includes('sport'));

                if (isSports) {
                    newMatches.push({
                        title: currentTitle,
                        subtitle: `${currentGroup} • Live`,
                        imageUrl: currentLogo,
                        streamUrl: line,
                        isLive: true,
                        category: "Live TV",
                        headers: {} // Public links usually don't need headers
                    });
                }
            }
        });

        console.log(`[Scraper] Found ${newMatches.length} Sports/Indian channels.`);
        return newMatches;

    } catch (error) {
        console.error(`[Scraper] Error: ${error.message}`);
        return [];
    }
}

module.exports = { scrapeMatches };
