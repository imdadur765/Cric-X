import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cric_x/features/home/models/match_model.dart';

class LinkService {
  // LIVE CLOUD SERVER ☁️
  // Now your app works anywhere (No Wi-Fi needed!)
  static const String _configUrl = "https://cric-x.onrender.com/matches";

  // Fallback data if internet fails
  static List<MatchModel> get fallbackMatches => MatchModel.dummyMatches;

  Future<List<MatchModel>> fetchMatches() async {
    try {
      print("Fetching from $_configUrl");
      final response = await http.get(Uri.parse(_configUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Data fetched: ${data.length} items");
        return data.map((e) => MatchModel.fromJson(e)).toList();
      } else {
        print("Server error: ${response.statusCode}");
        return fallbackMatches;
      }
    } catch (e) {
      print("Network error: $e");
      return fallbackMatches;
    }
  }
}
