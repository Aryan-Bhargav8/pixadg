import 'package:flutter/material.dart';
import 'package:pixadg/screens/favourites.dart';
import 'package:pixadg/services/pixapi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'details.dart';
import 'searchImages.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PixAPI pixAPI = PixAPI();
  List<dynamic> images = [];
  bool isLoading = true;
  String query = '';

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  void fetchImages() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<dynamic> fetchedImages = await pixAPI.fetchImages(query: query);
      setState(() {
        images = fetchedImages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FavoritesScreen()),
          );
        },
        child: Icon(Icons.favorite),
      ),
      appBar: AppBar(
        title: Text('PixAdg : Images From Pixabay'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchImages(api: pixAPI),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                fetchImages();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailsScreen(imageData: images[index]),
                            ),
                          );
                        },
                        child: Hero(
                          tag: images[index]['id'],
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: images[index]['webformatURL'],
                              placeholder: (context, url) => Container(
                                height: 150,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
    );
  }
}
