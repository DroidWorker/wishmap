import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../res/colors.dart';

class GalleryPhotoContainer<T> extends StatefulWidget{

  Function(Uint8List) onTap;
  T image;
  bool needtoSelect;

  GalleryPhotoContainer(this.image, this.onTap, {this.needtoSelect = false, super.key});

  @override
  GalleryPhotoContainerState createState() => GalleryPhotoContainerState();

}

class GalleryPhotoContainerState extends State<GalleryPhotoContainer> {
  bool isSelected = false;
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant GalleryPhotoContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _loadImage();
    }
  }

  void _loadImage() async {
    final data = (widget.image is AssetEntity)?await widget.image.thumbnailDataWithSize(const ThumbnailSize(200, 200)):widget.image;
    setState(() {
      imageData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap(imageData!);
        if(widget.needtoSelect) {
          setState(() {
          isSelected = !isSelected;
        });
        }
      },
      child: imageData != null ? Container(
        decoration: isSelected ? BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd]),
        ) : null,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              imageData!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      )
          : Container(), // Ваша заглушка или индикатор загрузки
    );
  }
}
