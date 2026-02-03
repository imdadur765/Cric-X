import 'package:cric_x/core/link_service.dart';
import 'package:cric_x/core/source_parser.dart';
import 'package:cric_x/features/home/models/match_model.dart';
import 'package:cric_x/features/player/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LinkService _linkService = LinkService();
  final SourceParser _sourceParser = SourceParser();
  late Future<List<MatchModel>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _linkService.fetchMatches();
  }

  Future<void> _refreshMatches() async {
    setState(() {
      _matchesFuture = _linkService.fetchMatches();
    });
  }

  void _showParserDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text("Test Stream Parser", style: GoogleFonts.outfit(color: Colors.white)),
          content: TextField(
            controller: urlController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter Webpage URL",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text;
                if (url.isNotEmpty) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Parsing source code..."), duration: Duration(seconds: 1)),
                  );

                  final html = await _sourceParser.fetchHtml(url);
                  if (html != null) {
                    final hls = _sourceParser.extractHls(html);
                    if (hls != null) {
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(videoUrl: hls, title: "Parsed Stream"),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text("No HLS (.m3u8) link found in source.")));
                      }
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text("Failed to fetch webpage.")));
                    }
                  }
                }
              },
              child: const Text("Extract & Play"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "CRIC-X TV",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.blueAccent),
              onPressed: () => _showParserDialog(context),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.blueAccent,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Cricket 🏏"),
              Tab(text: "Entertainment 🎭"),
              Tab(text: "News 📰"),
              Tab(text: "Movies 🎬"),
              Tab(text: "Kids �"),
            ],
          ),
        ),
        body: FutureBuilder<List<MatchModel>>(
          future: _matchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text("Error loading streams", style: TextStyle(color: Colors.white70)),
              );
            }

            final allMatches = snapshot.data!;

            Widget buildCategoryView(String category) {
              final matches = allMatches.where((m) => m.category == category).toList();

              if (matches.isEmpty) {
                return const Center(
                  child: Text("No channels available", style: TextStyle(color: Colors.white60)),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshMatches,
                backgroundColor: const Color(0xFF0F172A),
                color: Colors.blueAccent,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 16),
                    if (category == "Cricket") ...[
                      _SectionHeader(title: "Featured Matches", onViewAll: () {}),
                      _FeaturedCarousel(match: matches[0]),
                      const SizedBox(height: 20),
                    ],
                    _SectionHeader(title: category == "Cricket" ? "Trending Now" : "All Channels", onViewAll: () {}),
                    _HorizontalList(matches: matches),
                    const SizedBox(height: 20),
                    _SectionHeader(title: "Recommended", onViewAll: () {}),
                    _VerticalList(matches: matches),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                buildCategoryView("Cricket"),
                buildCategoryView("Entertainment"),
                buildCategoryView("News"),
                buildCategoryView("Movies"),
                buildCategoryView("Kids"),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeaturedCarousel extends StatelessWidget {
  final MatchModel match;
  const _FeaturedCarousel({required this.match});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerScreen(videoUrl: match.streamUrl, title: match.title, headers: match.headers),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(match.imageUrl),
            fit: BoxFit.cover,
            onError: (e, s) => const Icon(Icons.broken_image),
          ),
          boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                child: const Text("LIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(
                match.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(match.subtitle, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              "View All",
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalList extends StatelessWidget {
  final List<MatchModel> matches;
  const _HorizontalList({required this.matches});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: matches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final match = matches[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerScreen(videoUrl: match.streamUrl, title: match.title, headers: match.headers),
              ),
            ),
            child: Container(
              width: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1E293B),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5)),
                ],
                image: DecorationImage(
                  image: NetworkImage(match.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                  onError: (e, s) => const Icon(Icons.broken_image),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.95)],
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            match.title.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(match.subtitle, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                  if (match.isLive)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            const Text("LIVE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VerticalList extends StatelessWidget {
  final List<MatchModel> matches;
  const _VerticalList({required this.matches});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final match = matches[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerScreen(videoUrl: match.streamUrl, title: match.title, headers: match.headers),
            ),
          ),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    match.imageUrl,
                    width: 100,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(match.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(match.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_outline, color: Colors.blueAccent),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
