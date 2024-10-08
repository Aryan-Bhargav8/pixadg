import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class PixAPIPop {
  final String apiKey='46165096-19cc1d0b291b3d58f82b276c7';

  Future<List<dynamic>> fetchPopImages({ String query = ''}) async {
    int page= Random().nextInt(20) + 1;
    final response = await http.get(
      Uri.parse('https://pixabay.com/api/?key=$apiKey&q=$query&image_type=photo&order=popular&per_page=20&page=$page'),
    );

    if (response.statusCode == 200) {
      Map<String , dynamic> data = jsonDecode(response.body);
      return data['hits'];
    } else {
      throw Exception('Failed to load images');
    }
  }
}