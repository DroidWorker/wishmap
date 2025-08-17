import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/interface_widgets/galleriPhotoContainer.dart';

class RoundedPhotoGallery extends StatefulWidget {
  @override
  _RoundedPhotoGalleryState createState() => _RoundedPhotoGalleryState();

  Function(Uint8List photo) onClick;

  RoundedPhotoGallery({super.key, required this.onClick});
}

class _RoundedPhotoGalleryState extends State<RoundedPhotoGallery> {
  List<Uint8List> _images = [];

  List<Uint8List> selectedItems = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _images = result.files
            .where((file) => file.bytes != null)
            .map((file) => file.bytes!)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          ElevatedButton(
            onPressed: _pickImages,
            child: const Text("Выбрать изображения"),
          ),
        ]),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return GalleryPhotoContainer.fromBytes(_images[index], (image) {
                widget.onClick(image);
              });
            },
          ),
        ),
      ],
    );
  }
}