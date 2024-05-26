import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wishmap/interface_widgets/galleriPhotoContainer.dart';
import 'package:wishmap/res/colors.dart';

class RoundedPhotoGallery extends StatefulWidget {
  @override
  _RoundedPhotoGalleryState createState() => _RoundedPhotoGalleryState();

  Function(Uint8List photo) onClick;

  RoundedPhotoGallery({super.key, required this.onClick});
}

class _RoundedPhotoGalleryState extends State<RoundedPhotoGallery> {
  List<AssetEntity> _images = [];
  late final List<AssetPathEntity> albums;
  late Set<String> albumNames = {"загрузка..."};

  String selectedAlbum="загрузка...";
  List<Uint8List> selectedItems = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadImages();
  }

  Future<void> _checkPermissionAndLoadImages() async {
    var status = await Permission.photos.request();
    var statusOld = await Permission.storage.request();
    if (status.isGranted||statusOld.isGranted) {
      albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      albumNames=albums.map((e) => e.name).toSet();
      selectedAlbum=albumNames.firstOrNull??"";
      await _loadImages();
    } else {
      // Handle the case where the user denied permission
    }
  }

  Future<void> _loadImages({String albumName = ""}) async {
    AssetPathEntity? cameraAlbum;

    // Поиск альбома камеры
    if(albumName!=""){
      cameraAlbum = albums.firstWhereOrNull((element) => element.name==albumName);
    }else {
      for (var album in albums) {
        if (album.name.toLowerCase().contains("recent") || album.name.toLowerCase().contains("all") || album.name.toLowerCase().contains("все") || album.name.toLowerCase().contains("camera") || album.name.toLowerCase().contains("камер")) {
          cameraAlbum = album;
          selectedAlbum=album.name;
          break;
        }
      }
    }

    if (cameraAlbum != null) {
      final assets = await cameraAlbum.getAssetListRange(start: 0, end: 100); // Загрузка первых 100 изображений
      setState(() {
        _images = assets;
      });
    }
    else{
      if (albums.isNotEmpty) {
        final assets = await albums[0].getAssetListRange(start: 0, end: 100); // Загрузка первых 100 изображений
        selectedAlbum=albums[0].name;
        setState(() {
          _images = assets;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          const Text("Альбом"),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.darkGrey),
                  value: selectedAlbum,
                  onChanged: (newValue) {
                    selectedAlbum = newValue??"";
                    _loadImages(albumName: selectedAlbum);
                  },
                  items: albumNames.map<DropdownMenuItem<String>>((albumName) {
                    return DropdownMenuItem<String>(
                      value: albumName,
                      child: Text(albumName),
                    );
                  }).toList()
                ),
              ),
            ),
          ),
        ],),
        const SizedBox(height: 24),
        Expanded(child:
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // количество элементов в строке
            crossAxisSpacing: 4.0, // расстояние между элементами по горизонтали
            mainAxisSpacing: 4.0, // расстояние между элементами по вертикали
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return GalleryPhotoContainer(_images[index], (image) async {
                widget.onClick(image);
            });
          },
        ))
      ],
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