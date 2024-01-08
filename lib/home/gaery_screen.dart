
import 'dart:typed_data';

import 'package:advanced_search/advanced_search.dart';
import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/google_gallery_widget.dart';
import 'package:wishmap/common/manage_image_overlay.dart';
import 'package:wishmap/data/static_search.dart';

import '../ViewModel.dart';
import '../common/collage.dart';
import '../common/gallery_widget.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class GalleryScreen extends StatefulWidget{
  const GalleryScreen({super.key});

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen>{
  int screenNumber = 0;
  bool onLoading = false;
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    iconSize: 30,
                    onPressed: () {
                      BlocProvider.of<NavigationBloc>(context).handleBackPress();
                    },
                  ),
                  Expanded(child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          screenNumber = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),
                      child: Text("Мои образы", style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, decoration: screenNumber==0?TextDecoration.underline:TextDecoration.none),)
                  ),),
                  Expanded(child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          screenNumber = 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),
                      child: Text("Галерея", style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, decoration: screenNumber==1?TextDecoration.underline:TextDecoration.none),)
                  ),),
                  Expanded(child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          screenNumber = 2;
                        });
                      },
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),
                      child: Text("Поиск", style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, decoration: screenNumber==2?TextDecoration.underline:TextDecoration.none),)
                  ),),
                  /*Expanded(child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          screenNumber = 3;
                        });
                      },
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),
                      child: Text("Добавить", style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, decoration: screenNumber==2?TextDecoration.underline:TextDecoration.none),)
                  ),)*/
                ]
              ),
              screenNumber==0?  Consumer<AppViewModel>(builder: (context, appVM, child) {
                return LayoutBuilder(
                    builder: (context, constraints) {
                      double fullWidth = constraints.maxWidth-4;
                      double leftWidth = (constraints.maxWidth * 4 /7)-2;
                      double rightWidth = constraints.maxWidth - leftWidth - 2;
                      List<Map<Uint8List, int?>> imagesSet = [];
                      appViewModel.cachedImages.indexed.forEach((element) {if(imagesSet.isNotEmpty&&imagesSet.last.length<3){imagesSet.last[element.$2]=element.$1;}else{imagesSet.add({element.$2: element.$1});}});
                      return Expanded(child:
                      Column(children:
                      imagesSet.map((e) {
                        if(e.length==1) {
                          return buildSingle(fullWidth, e.keys.first, appVM.isinLoading,false, imageId: e.values.first,onTap: (index) async {
                          final image = await showOverlayedImageManager(context, index.toString(), mode: 1, image: appViewModel.cachedImages[index]);
                          if(image!=null){
                            setState(() {
                              appViewModel.cachedImages.removeAt(index);
                            });
                          }
                        });
                        } else if(e.length==2) return buildTwin(leftWidth, rightWidth, e, appVM.isinLoading,false, onTap: (index) async {
                          final image = await showOverlayedImageManager(context, index.toString(), mode: 1, image: appViewModel.cachedImages[index]);
                          if(image!=null){
                            setState(() {
                              appViewModel.cachedImages.removeAt(index);
                            });
                          }
                        });
                        else if(imagesSet.indexOf(e)%2!=0) return buildTriple(leftWidth, rightWidth, e, appVM.isinLoading,false, onTap: (index) async {
                          final image = await showOverlayedImageManager(context, index.toString(), mode: 1, image: appViewModel.cachedImages[index]);
                          if(image!=null){
                            setState(() {
                              appViewModel.cachedImages.removeAt(index);
                            });
                          }
                        });
                        else return buildTripleReverce(leftWidth, rightWidth, e, appVM.isinLoading,false, onTap: (index) async {
                            final image = await showOverlayedImageManager(context, index.toString(), mode: 1, image: appViewModel.cachedImages[index]);
                            if(image!=null){
                              setState(() {
                                appViewModel.cachedImages.removeAt(index);
                              });
                            }
                          });
                      }).toList()
                        ,)
                      );
                    });}):
              screenNumber==1?Expanded(child: RoundedPhotoGallery(onClick: (image){
                appViewModel.cachedImages.add(image);
                BlocProvider.of<NavigationBloc>(context).handleBackPress();
              })):
              screenNumber==2?
              Consumer<AppViewModel>(builder: (context, appVM, child){
                if(appVM.photoUrls.isNotEmpty)onLoading=false;
                return Expanded(child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: AppColors.greyBackButton,
                          borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child:AdvancedSearch( // This is basically an Input Text Field
                              hintText: '',
                              searchItems: suggestions,
                              maxElementsToDisplay: 3,
                              itemsShownAtStart: 0,
                              hideHintOnTextInputFocus: true,
                              inputTextFieldBgColor: AppColors.greyBackButton,
                              searchResultsBgColor: AppColors.greyBackButton,
                              onItemTap: (index, text) {
                                // user just found what he needs, now it's your turn to handle that
                              },
                              onSearchClear: () {
                                // may be display the full list? or Nothing? it's your call
                              },
                              onSubmitted: (value, value2) {
                                onLoading = true;
                                appViewModel.searchImages(value);
                                print("search  starteeeeeeeed$value");
                              },
                              onEditingProgress: (value, value2) {
                                searchText = value;
                              },
                            )),
                            IconButton(onPressed: (){
                              onLoading = true;
                              appViewModel.searchImages(searchText);
                            }, icon: const Icon(Icons.search),  style: const ButtonStyle(foregroundColor: MaterialStatePropertyAll(AppColors.greyBackButton)),)
                          ]),
                    ),
                    onLoading?const LinearCappedProgressIndicator(
                      backgroundColor: Colors.black26,
                      color: Colors.black,
                      cornerRadius: 0,):
                    PhotoGalleryWidget(imageUrls: appViewModel.photoUrls, onTap: (url) async {
                      final image = await showOverlayedImageManager(context, url);
                      if(image!=null)appViewModel.cachedImages.add(image);
                    }),
                    //const Expanded(child: SizedBox())
                  ],
                ));
              }):const SizedBox()
            ],
          ),
      ),
    );
  }

 /* screenNumber==2?Center(
  child: GestureDetector(
  onTap: () async {
  Uint8List? imageBytes = await getImageFromCamera();

  if (imageBytes != null) {
  appViewModel.cachedImages.add(imageBytes);
  BlocProvider.of<NavigationBloc>(context).handleBackPress();
  }
  },
  child: const Icon(Icons.photo_camera, size: 90, color: Colors.black,),
  )
  )*/

  Future<Uint8List?> getImageFromCamera() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();

        // Преобразование List<int> в Uint8List
        final uint8List = Uint8List.fromList(bytes);

        return uint8List;
      } else {
        print("Отменено пользователем");
      }
    } catch (e) {
      print("Ошибка: $e");
    }

    return null;
  }
}