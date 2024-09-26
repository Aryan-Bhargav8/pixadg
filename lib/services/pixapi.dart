import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class PixAPI {
  final String apiKey='46165096-19cc1d0b291b3d58f82b276c7';

  // Fetch images from Pixabay API
  Future<List<dynamic>> fetchImages({ String query = ''}) async {
    int page= Random().nextInt(20) + 1;
    final response = await http.get(
      Uri.parse('https://pixabay.com/api/?key=$apiKey&q=$query&image_type=photo&page=$page&per_page=40&order=latest'),
    );

    if (response.statusCode == 200) {
      Map<String , dynamic> data = jsonDecode(response.body);
      return data['hits'];
    } else {
      throw Exception('Failed to load images');
    }
  }

  // Fetch image by ID for favourites
  Future<Map<String, dynamic>?> fetchImageById(String id) async {
    final response = await http.get(
      Uri.parse('https://pixabay.com/api/?key=$apiKey&id=$id'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> hits = data['hits'];
      return hits.isNotEmpty ? hits.first : null;
    } else {
      throw Exception('Failed to load image');
    }
  }
}