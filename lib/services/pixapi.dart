import 'dart:convert';
import 'package:http/http.dart' as http;

class PixAPI {
  final String apiKey='46165096-19cc1d0b291b3d58f82b276c7';

  Future<List<dynamic>> fetchImages({ String query = ''}) async {
    final response = await http.get(
      Uri.parse('https://pixabay.com/api/?key=$apiKey&q=$query&image_type=photo'
      '&order=latest&per_page=70'),
    );

    if (response.statusCode == 200) {
      Map<String , dynamic> data = jsonDecode(response.body);
      return data['hits'];
    } else {
      throw Exception('Failed to load images');
    }
  }
}