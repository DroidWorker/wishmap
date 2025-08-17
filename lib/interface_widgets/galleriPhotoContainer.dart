import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../res/colors.dart';

class GalleryPhotoContainer extends StatefulWidget {
  final Uint8List image;
  final Function(Uint8List) onTap;
  final bool needToSelect;

  const GalleryPhotoContainer(this.image, this.onTap, {this.needToSelect = false, super.key});

  // Именованный конструктор для веба
  factory GalleryPhotoContainer.fromBytes(Uint8List imageBytes, Function(Uint8List) onTap, {bool needToSelect = false}) {
    return GalleryPhotoContainer(imageBytes, onTap, needToSelect: needToSelect);
  }

  @override
  State<GalleryPhotoContainer> createState() => _GalleryPhotoContainerState();
}

class _GalleryPhotoContainerState extends State<GalleryPhotoContainer> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap(widget.image);
        if (widget.needToSelect) {
          setState(() {
            isSelected = !isSelected;
          });
        }
      },
      child: Container(
        decoration: isSelected && widget.needToSelect
            ? BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              widget.image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
