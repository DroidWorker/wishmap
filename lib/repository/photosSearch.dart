import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GRepository{
  static const String key = "JVHjjtfr2-lzWYmKl9426KnG-108DJ88B6uSIlX0Sg8";

  static Future<List<String>> searchImages(String q)async{
    List<String> imgUrls = [];
    final response = await http.get(Uri.parse('https://api.unsplash.com/search/photos?client_id=$key&query=$q'));
    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      List<dynamic> itemsList = decodedResponse["results"] as List<dynamic>;
      for (var element in itemsList) {
        var image = (element as Map<String, dynamic>)["urls"];
        var thumbnailLink = image["regular"];
        imgUrls.add(thumbnailLink);
        print("Thumbnail Link: $thumbnailLink");
      }
    } else {
      debugPrint("google photo error: ${response.statusCode}");
    }
    return imgUrls;
  }

  static Future<Uint8List> loadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      return Uint8List.fromList(response.bodyBytes);
    } else {
      throw Exception('Failed to load image');
    }
  }
}