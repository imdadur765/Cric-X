import 'package:http/http.dart' as http;

class SourceParser {
  /// Fetches the HTML content of a given URL.
  Future<String?> fetchHtml(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extracts the first .m3u8 link found in the content.
  String? extractHls(String content) {
    // Regex to find https://...m3u8 or http://...m3u8
    // This is a naive regex for educational purposes.
    final regex = RegExp(r'(https?://[^\s]+\.m3u8)');
    final match = regex.firstMatch(content);
    return match?.group(0);
  }

  /// Extracts the first .mp4 link found in the content.
  String? extractMp4(String content) {
    final regex = RegExp(r'(https?://[^\s]+\.mp4)');
    final match = regex.firstMatch(content);
    return match?.group(0);
  }
}
