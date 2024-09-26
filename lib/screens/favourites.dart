// lib/screens/favorites_screen.dart

// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixadg/services/pixapi.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favoriteIDs = [];
  List<Map<String, dynamic>> favoriteImages = [];
  bool isLoading = true;
  final PixAPI pixAPI = PixAPI();

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    favoriteIDs = prefs.getStringList('favorites') ?? [];

    favoriteImages = [];   
    for (String id in favoriteIDs) {
      try{
        var imageData = await pixAPI.fetchImageById(id);
        if(imageData != null) {
          favoriteImages.add(imageData);
        }
      } catch (e) {
        print('Error loading favorite image: $e');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<Map<String, dynamic>?> fetchImageData(String id) async {
    try {
      List<dynamic> imageData = await pixAPI.fetchImages(query: id);
      if (imageData.isNotEmpty) {
        return imageData.first;
      }
    } catch (e) {
      print('Error fetching image data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 214, 180, 94),
        title: Text('Favorite Images'),
      ),
      body: favoriteImages.isEmpty
          ? Center(child: Text('No favorites yet.'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: favoriteImages.length,
                itemBuilder: (context, index) {
                  var image = favoriteImages[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(imageData: image),
                        ),
                      ).then((_) {
                        // Reload favorites in case any changes were made
                        loadFavorites();
                      });
                    },
                    child: Hero(
                      tag: image['id'],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: image['webformatURL'],
                          placeholder: (context, url) => Container(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

