const axios = require('axios');

/**
 * THE GLOBAL PRO SCRAPER (Level 3 Ready)
 * Targets International & Indian sources for Premium Sports.
 */

const SOURCES = [
    { name: "India - Full", url: "https://iptv-org.github.io/iptv/countries/in.m3u", type: "m3u" },
    { name: "Global Sports", url: "https://iptv-org.github.io/iptv/categories/sports.m3u", type: "m3u" },
    { name: "USA - Sports", url: "https://iptv-org.github.io/iptv/countries/us.m3u", type: "m3u" },
    { name: "Australia - General", url: "https://iptv-org.github.io/iptv/countries/au.m3u", type: "m3u" }
];

async function scrapeMatches() {
    let allFoundMatches = [];
    console.log(`[Global Scraper] Scanning ${SOURCES.length} premium sources...`);

    for (const source of SOURCES) {
        try {
            console.log(`[Global Scraper] Fetching: ${source.name}...`);
            const response = await axios.get(source.url, { timeout: 15000 });
            const data = response.data;
            const parsed = parseM3U(data, source.name);
            allFoundMatches = [...allFoundMatches, ...parsed];
        } catch (error) {
            console.error(`[Global Scraper] Skip ${source.name}: ${error.message}`);
        }
    }

    // Deduplicate and Rank (Prioritize specific channels requested by USER)
    const finalMatches = [];
    const seenUrls = new Set();

    // Sort by Priority (Star/Willow/Fox first)
    allFoundMatches.sort((a, b) => (b.priority || 0) - (a.priority || 0));

    allFoundMatches.forEach(m => {
        if (!seenUrls.has(m.streamUrl)) {
            seenUrls.add(m.streamUrl);
            finalMatches.push(m);
        }
    });

    console.log(`[Global Scraper] Successfully indexed ${finalMatches.length} channels.`);
    return finalMatches;
}

function parseM3U(data, sourceName) {
    const lines = data.split('\n');
    const matches = [];
    let currentTitle = "";
    let currentLogo = "";
    let currentGroup = "";

    lines.forEach((line) => {
        line = line.trim();
        if (line.startsWith('#EXTINF')) {
            const titleMatch = line.match(/,(.+)$/);
            currentTitle = titleMatch ? titleMatch[1].trim() : "Unknown Stream";
            const logoMatch = line.match(/tvg-logo="([^"]*)"/);
            currentLogo = logoMatch ? logoMatch[1] : "https://via.placeholder.com/300?text=TV";
            const groupMatch = line.match(/group-title="([^"]*)"/);
            currentGroup = groupMatch ? groupMatch[1] : "General";
        } else if (line.startsWith('http')) {
            const nameLower = currentTitle.toLowerCase();
            const groupLower = currentGroup.toLowerCase();

            // USER'S SPECIFIC CHANNELS (Priority 10)
            const priorityKeywords = ['star sports', 'willow tv', 'fox sports', 'channel 7'];
            const isPriority = priorityKeywords.some(k => nameLower.includes(k));

            // General Sports Filter
            const sportsKeywords = ['cricket', 'sony', 'ten sports', 'astro', 'sky sports', 'bein', 'eurosport', 'dd sports'];
            const isSports = sportsKeywords.some(k => nameLower.includes(k) || groupLower.includes('sport'));

            if (isPriority || isSports || sourceName === "India - Full") {
                let category = "Entertainment";
                if (isPriority || isSports) category = "Cricket";
                else if (nameLower.includes('news') || groupLower.includes('news')) category = "News";
                else if (nameLower.includes('kids') || groupLower.includes('kids')) category = "Kids";
                else if (nameLower.includes('movie') || groupLower.includes('cinema')) category = "Movies";

                matches.push({
                    title: currentTitle,
                    subtitle: `${sourceName} • ${isPriority ? '★ Premium' : 'Live'}`,
                    imageUrl: currentLogo,
                    streamUrl: line,
                    isLive: true,
                    category: category,
                    priority: isPriority ? 10 : 1,
                    headers: {
                        "User-Agent": "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36"
                    }
                });
            }
        }
    });
    return matches;
}

module.exports = { scrapeMatches };
