import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cric_x/features/home/models/match_model.dart';

class LinkService {
  // Using direct Wi-Fi IP of the laptop.
  // Ensure Phone and Laptop are on the SAME Wi-Fi.
  static const String _configUrl = "http://10.224.198.174:3000/matches";

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
