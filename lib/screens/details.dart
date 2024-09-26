// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixadg/services/pixapi.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DetailsScreen extends StatefulWidget {
  final dynamic imageData;

  DetailsScreen({required this.imageData});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool isFavorite = false;
  List<dynamic> similarImages = [];
  bool isLoadingSimilar = true;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
    fetchSimilarImages();
  }

  void fetchSimilarImages() async {
    setState(() {
      isLoadingSimilar = true;
    });

    try {
      final PixAPI pixAPI = PixAPI();
      String tags = widget.imageData['tags'];

      List<dynamic> fetchedImages = await pixAPI.fetchImages(query: tags);

      fetchedImages
          .removeWhere((element) => element['id'] == widget.imageData['id']);

      setState(() {
        similarImages = fetchedImages;
        isLoadingSimilar = false;
      });
    } catch (e) {
      setState(() {
        isLoadingSimilar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];
    String imageId = widget.imageData['id'].toString();

    setState(() {
      isFavorite = favorites.contains(imageId);
    });
  }

  void toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];
    String imageId = widget.imageData['id'].toString();

    if (isFavorite) {
      favorites.remove(imageId);
    } else {
      favorites.add(imageId);
    }

    await prefs.setStringList('favorites', favorites);

    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              isFavorite ? 'Added to Favorites' : 'Removed from Favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.6,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: widget.imageData['id'],
              child: CachedNetworkImage(
                imageUrl: widget.imageData['largeImageURL'],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.imageData['userImageURL']),
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.imageData['user'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                widget.imageData['tags'],
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border),
                    onPressed: toggleFavorite,
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      Share.share(widget.imageData['largeImageURL']);
                    },
                  ),
                  
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Similar Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Container(
                height: 250,
                child: isLoadingSimilar
                    ? Center(child: CircularProgressIndicator())
                    : similarImages.isEmpty
                        ? Text('No similar images found.')
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: similarImages.length,
                            itemBuilder: (context, index) {
                              final image = similarImages[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigate to DetailsScreen for the similar image
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailsScreen(imageData: image),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: image[
                                          'previewURL'], // Use 'previewURL' for thumbnails
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        )),
      ]),
    );
  }

  
}
