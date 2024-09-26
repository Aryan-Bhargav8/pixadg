import 'package:flutter/material.dart';
import 'package:pixadg/screens/favourites.dart';
import 'package:pixadg/services/pixapi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixadg/services/pixapipop.dart';
import 'details.dart';
import 'searchImages.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PixAPI pixAPI = PixAPI();
  final PixAPIPop pixAPIPop = PixAPIPop();
  List<dynamic> images = [];
  List<dynamic> popImages = [];
  bool isLoading = true;
  bool isLoadingPop = true;
  String query = '';

  final bgcolor = Color(0xFFF5F5DC);
  final darkbgcolor = Color.fromARGB(255, 214, 180, 94);
  final fav = Color.fromARGB(255, 255, 0, 68);
  @override
  void initState() {
    super.initState();
    fetchImages();
    fetchPopImages();
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

  void fetchPopImages() async {
    setState(() {
      isLoadingPop = true;
    });
    try {
      List<dynamic> fetchedPopImages =
          await pixAPIPop.fetchPopImages(query: query);
      setState(() {
        popImages = fetchedPopImages;
        isLoadingPop = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPop = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching popular images: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgcolor,
        floatingActionButton: FloatingActionButton(
          backgroundColor: fav,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritesScreen()),
            );
          },
          child: Icon(Icons.favorite),
        ),
        appBar: AppBar(
          backgroundColor: darkbgcolor,
          title: Center(
            child: Text(
              'PixAdg : Images From Pixabay',
              style: TextStyle(
                color: Colors.yellow[200],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          actions: [
            IconButton(
                icon: Icon(
                Icons.search,
                size: 35.0, // Increase the icon size
                color: Colors.black, // Change the icon color to black
                ),

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
                  fetchPopImages();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        color: darkbgcolor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Popular Images",
                            style: TextStyle(
                                color: Colors.yellow[200],
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    
                    SliverToBoxAdapter(
                      child: Container(
                        color: darkbgcolor,
                        child: buildCarouselView()),
                    ),

                    SliverToBoxAdapter(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: Container(
                          color: darkbgcolor,
                          child: SizedBox(height: 40)),
                      ),
                    ),

                    SliverToBoxAdapter(
                      // Wrap the Text widget
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Latest Images",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    buildImageGrid(),
                  ],
                ),
              ));
  }

  // image grid
  Widget buildImageGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverMasonryGrid.count(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childCount: images.length,
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
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
    );
  }

  // carousal view

  Widget buildCarouselView() {
    if (isLoadingPop) {
      return Center(child: CircularProgressIndicator());
    }

    if (popImages.isEmpty) {
      return SizedBox.shrink();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: CarouselView(
          itemExtent: MediaQuery.of(context).size.width * 0.7,
          shrinkExtent: 20,
          children: popImages.map<Widget>((popImage) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(imageData: popImage),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: popImage['webformatURL'],
                  placeholder: (context, url) => Container(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

