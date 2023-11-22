import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class RoundedPhotoGallery extends StatefulWidget {
  @override
  _RoundedPhotoGalleryState createState() => _RoundedPhotoGalleryState();

  Function(Uint8List photo) onClick;

  RoundedPhotoGallery({super.key, required this.onClick});
}

class _RoundedPhotoGalleryState extends State<RoundedPhotoGallery> {
  List<AssetEntity> _images = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadImages();
  }

  Future<void> _checkPermissionAndLoadImages() async {
    var status = await Permission.photos.request();
    var statusOld = await Permission.storage.request();
    if (status.isGranted||statusOld.isGranted) {
      await _loadImages();
    } else {
      // Handle the case where the user denied permission
    }
  }

  Future<void> _loadImages() async {
      final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      if (albums.isNotEmpty) {
        final assets = await albums[0].getAssetListRange(start: 0, end: 100); // Загрузка первых 100 изображений
        setState(() {
          _images = assets;
        });
      }
  }

  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // количество элементов в строке
        crossAxisSpacing: 8.0, // расстояние между элементами по горизонтали
        mainAxisSpacing: 8.0, // расстояние между элементами по вертикали
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            final image = await compressImage(_images[index]);
            if(image!=null) {
              widget.onClick(image);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: FutureBuilder<Uint8List?>(
              future: _images[index].thumbnailDataWithSize(const ThumbnailSize(200, 200)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                } else {
                  return Container(); // Ваша заглушка или индикатор загрузки
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<Uint8List> compressImage(AssetEntity assetEntity) async {
    // Получаем байты изображения из AssetEntity
    Uint8List? imageBytes = await assetEntity.originBytes;

    // Сжатие изображения
    List<int> compressedImage = await FlutterImageCompress.compressWithList(
      imageBytes!,
      minHeight: 300,
      minWidth: 300,
      quality: 40,
      rotate: 0,
    );

    return Uint8List.fromList(compressedImage);
  }
}