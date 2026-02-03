class MatchModel {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String streamUrl;
  final bool isLive;
  final String category;
  final Map<String, String>? headers;

  MatchModel({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.streamUrl,
    this.isLive = false,
    this.category = "Cricket",
    this.headers,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      title: json['title'] ?? 'Unknown Match',
      subtitle: json['subtitle'] ?? 'Live Stream',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/300',
      streamUrl: json['streamUrl'] ?? '',
      isLive: json['isLive'] ?? false,
      category: json['category'] ?? "Cricket",
      headers: json['headers'] != null ? Map<String, String>.from(json['headers']) : null,
    );
  }

  static List<MatchModel> get dummyMatches => [
    MatchModel(
      title: "IND vs AUS | Final",
      subtitle: "Live from Melbourne",
      imageUrl: "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?q=80&w=2000&auto=format&fit=crop",
      streamUrl: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
      isLive: true,
      category: "Cricket",
    ),
    MatchModel(
      title: "Big Buck Bunny",
      subtitle: "Animated Movie",
      imageUrl: "https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=2000&auto=format&fit=crop",
      streamUrl: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
      isLive: false,
      category: "Movies",
    ),
    MatchModel(
      title: "BBC News",
      subtitle: "Global News",
      imageUrl: "https://images.unsplash.com/photo-1495020686667-45e86d4e610d?q=80&w=2000&auto=format&fit=crop",
      streamUrl: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
      isLive: true,
      category: "Live TV",
    ),
  ];
}
