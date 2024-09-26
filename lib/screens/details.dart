import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class DetailsScreen extends StatefulWidget {
  final dynamic imageData;

  DetailsScreen({required this.imageData});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  void checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ??[];
    String imageId = widget.imageData;

    setState(() {
      isFavorite = favorites.contains(imageId);
    });
  }

  void toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];
    String imageId = jsonEncode(widget.imageData);

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
      SnackBar(content: Text(isFavorite ? 'Added to Favorites' : 'Removed from Favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Details'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(widget.imageData['largeImageURL']);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: widget.imageData['id'],
              child: CachedNetworkImage(
                imageUrl: widget.imageData['largeImageURL'],
                placeholder: (context, url) => Container(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Author: ${widget.imageData['user']}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Tags: ${widget.imageData['tags']}'),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await downloadImage(context);
                      },
                      icon: Icon(Icons.download),
                      label: Text('Download Image'),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Future<void> downloadImage(BuildContext context) async {
    //checking Storage permission
    if (await Permission.storage.request().isGranted) {
      var response = await http.get(Uri.parse(widget.imageData['largeImageURL']));
      var documentDirectory = await getExternalStorageDirectory();
      String path = documentDirectory!.path;
      File file = File('$path/${widget.imageData['id']}.jpg');
      file.writeAsBytesSync(response.bodyBytes);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image downloaded to $path')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Permission denied')));
    }
  }
}
