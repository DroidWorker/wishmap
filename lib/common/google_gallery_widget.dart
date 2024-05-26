import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/res/colors.dart';

class PhotoGalleryWidget extends StatelessWidget {
  final List<String> imageUrls;
  Function(String url) onTap;

  PhotoGalleryWidget({super.key, required this.imageUrls, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child:
    GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return _buildImageTile(context, imageUrls[index]);
      },
    )
    );
  }

  Widget _buildImageTile(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () {
        onTap(imageUrl);
      },
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const CircularProgressIndicator(color: AppColors.darkGrey,),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            )),
      ),
    );
  }

  Widget _buildImagePage(String imageUrl) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(color: AppColors.darkGrey,),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
