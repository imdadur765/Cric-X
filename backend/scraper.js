const axios = require('axios');

/**
 * THE PRO SCRAPER (Level 2.5)
 * Targets multiple community-maintained sources to find premium sports channels.
 */

// These are high-quality, updated sources from the GitHub community
const SOURCES = [
    {
        name: "IPTV Org - India",
        url: "https://iptv-org.github.io/iptv/countries/in.m3u",
        type: "m3u"
    },
    {
        name: "IPTV Org - Sports",
        url: "https://iptv-org.github.io/iptv/categories/sports.m3u",
        type: "m3u"
    }
];

async function scrapeMatches() {
    let allFoundMatches = [];
    console.log(`[Pro Scraper] Starting crawl on ${SOURCES.length} sources...`);

    for (const source of SOURCES) {
        try {
            console.log(`[Pro Scraper] Fetching: ${source.name}...`);
            const response = await axios.get(source.url, { timeout: 10000 });
            const data = response.data;

            if (source.type === "m3u") {
                const parsed = parseM3U(data);
                allFoundMatches = [...allFoundMatches, ...parsed];
            }
        } catch (error) {
            console.error(`[Pro Scraper] Error fetching ${source.name}: ${error.message}`);
        }
    }

    // Deduplicate by Stream URL to keep list clean
    const uniqueMatches = [];
    const seenUrls = new Set();

    allFoundMatches.forEach(m => {
        if (!seenUrls.has(m.streamUrl)) {
            seenUrls.add(m.streamUrl);
            uniqueMatches.push(m);
        }
    });

    console.log(`[Pro Scraper] Total unique channels found: ${uniqueMatches.length}`);
    return uniqueMatches;
}

function parseM3U(data) {
    const lines = data.split('\n');
    const matches = [];
    let currentTitle = "";
    let currentLogo = "";
    let currentGroup = "";

    lines.forEach((line) => {
        line = line.trim();
        if (line.startsWith('#EXTINF')) {
            // Meta-data parsing
            const titleMatch = line.match(/,(.+)$/);
            currentTitle = titleMatch ? titleMatch[1].trim() : "Unknown Stream";

            const logoMatch = line.match(/tvg-logo="([^"]*)"/);
            currentLogo = logoMatch ? logoMatch[1] : "https://via.placeholder.com/300?text=Live+TV";

            const groupMatch = line.match(/group-title="([^"]*)"/);
            currentGroup = groupMatch ? groupMatch[1] : "General";

        } else if (line.startsWith('http')) {
            // Apply Next-Level Filtering for Sports
            const sportsKeywords = [
                'star sports', 'sony', 'willow', 'ten sports', 'cricket',
                'ipl', 'wpl', 'world cup', 't sports', 'ptv sports',
                'astro', 'sky sports', 'bein', 'eurosport', 'dd sports'
            ];

            const nameLower = currentTitle.toLowerCase();
            const groupLower = currentGroup.toLowerCase();

            const isSports = sportsKeywords.some(keyword =>
                nameLower.includes(keyword) || groupLower.includes(keyword)
            );

            if (isSports || source.name === "IPTV Org - India") {
                // Determine Category
                let category = "Live TV";

                if (nameLower.includes('news') || groupLower.includes('news')) category = "News";
                else if (nameLower.includes('kids') || groupLower.includes('kids') || nameLower.includes('cartoon')) category = "Kids";
                else if (nameLower.includes('movie') || groupLower.includes('cinema')) category = "Movies";
                else if (sportsKeywords.some(k => nameLower.includes(k) || groupLower.includes(k))) category = "Cricket";
                else category = "Entertainment";

                matches.push({
                    title: currentTitle,
                    subtitle: `${currentGroup} • Live`,
                    imageUrl: currentLogo,
                    streamUrl: line,
                    isLive: true,
                    category: category,
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
