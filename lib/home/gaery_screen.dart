
import 'dart:typed_data';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/google_gallery_widget.dart';
import 'package:wishmap/common/manage_image_overlay.dart';
import 'package:wishmap/interface_widgets/outlined_button.dart';

import '../ViewModel.dart';
import '../common/collage.dart';
import '../common/gallery_widget.dart';
import '../interface_widgets/colorButton.dart';
import '../interface_widgets/galleriPhotoContainer.dart';
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

  bool deleteMode = false;
  List<int> deleteIndexes = [];

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                      ),
                      icon: const Icon(Icons.keyboard_arrow_left, size: 32, color: AppColors.gradientStart),
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context).handleBackPress();
                      },
                    ),
                    const Text("Добавить образ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                    (screenNumber==0&&!deleteMode)?GestureDetector(
                      onTap: (){
                        setState(() {
                          deleteMode=true;
                        });
                      },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset("assets/icons/trash.svg", width: 28, height: 28),
                        )
                    ):const SizedBox(width: 44),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text("Добавьте образы вашего желания - это важно!", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const Text("Чем ближе будут образы вашему представлению, тем сильнее будет визуализация вашего желания.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.greyTransparent)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          screenNumber = 0;
                        });
                      },
                        child: screenNumber==0?ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black
                                    )
                                )
                            ),
                            child: const Center(child: Text("Мои образы")),
                          ),
                        ):const Center(child: Text("Мои образы")),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          appViewModel.allowSkipAuth=true;
                          screenNumber = 1;
                        });
                      },
                      child: screenNumber==1?ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black
                                  )
                              )
                          ),
                          child: const Center(child: Text("Галерея")),
                        ),
                      ):const Center(child: Text("Галерея")),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          screenNumber = 2;
                        });
                      },
                      child: screenNumber==2?ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black
                                  )
                              )
                          ),
                          child: const Center(child: Text("Поиск")),
                        ),
                      ):const Center(child: Text("Поиск")),
                    ),
                  ),
                  const SizedBox(width: 16)
                ]
              ),
              screenNumber==0?  Consumer<AppViewModel>(builder: (context, appVM, child) {
                return Expanded(child: appViewModel.cachedImages.isNotEmpty?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Expanded(child:
                      GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // количество элементов в строке
                          crossAxisSpacing: 4.0, // расстояние между элементами по горизонтали
                          mainAxisSpacing: 4.0, // расстояние между элементами по вертикали
                        ),
                        itemCount: appViewModel.cachedImages.length,
                        itemBuilder: (context, index) {
                          return GalleryPhotoContainer(key: ValueKey(appViewModel.cachedImages[index]), appViewModel.cachedImages[index], needtoSelect: deleteMode, (image) async {
                            if(deleteMode){
                              deleteIndexes.contains(index)?deleteIndexes.remove(index):deleteIndexes.add(index);
                            }
                            else {
                              final image = await showOverlayedImageManager(
                                  context, index.toString(), mode: 1,
                                  image: appViewModel.cachedImages[index]);
                              if (image != null) {
                                setState(() {
                                  appViewModel.cachedImages.removeAt(index);
                                  appViewModel.isChanged=true;
                                });
                              }
                            }
                          });
                        },
                      ))
                    ],
                  ),
                ):
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/icons/no_images.png', height: 180),
                          const SizedBox(height: 40),
                          const Text("Моих образов пока нет", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                          const SizedBox(height: 4),
                          const Text("Добавьте свои образы\nчерез галерею или поиск"),
                          const SizedBox(height: 50)
                        ],
                      )));
              }):
              screenNumber==1?Expanded(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RoundedPhotoGallery( onClick: (image) async {
                  final imge = await showOverlayedImageManager(context, "no url", image: image);
                  if(imge!=null){
                    appViewModel.cachedImages.add(image);
                    appViewModel.isChanged=true;
                  }
                }),
              )):
              screenNumber==2? Consumer<AppViewModel>(builder: (ccontext, appVM, child){
                if(appVM.photoUrls.isNotEmpty)onLoading=false;
                return Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(onPressed: (){
                                onLoading = true;
                                appViewModel.searchImages(searchText);
                              }, icon: const Icon(Icons.search),  style: const ButtonStyle(foregroundColor: MaterialStatePropertyAll(AppColors.greyBackButton)),
                              ),
                              Expanded(
                                child: TextField(
                                  maxLines: 1,
                                  cursorColor: AppColors.darkGrey,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (q){
                                    searchText=q;
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    onLoading = true;
                                    appViewModel.searchImages(q);
                                  },
                                    onChanged: (str){
                                      searchText=str;
                                      },
                                ),
                              )
                              ]),
                      ),
                      const SizedBox(height: 24),
                      onLoading?const LinearCappedProgressIndicator(
                        backgroundColor: Colors.black26,
                        color: Colors.black,
                        cornerRadius: 0,):
                      PhotoGalleryWidget(imageUrls: appViewModel.photoUrls, onTap: (url) async {
                        final image = await showOverlayedImageManager(context, url);
                        if(image!=null){
                          appViewModel.cachedImages.add(image);
                          appViewModel.isChanged=true;
                        }
                      }),
                      //const Expanded(child: SizedBox())
                    ],
                  ),
                ));
              }):
              const SizedBox(),
              if(screenNumber==0&&deleteMode)Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ColorRoundedButton("Удалить", c: AppColors.buttonBackRed, () async {
                      setState(() {
                        deleteIndexes.sort((a,b)  => b.compareTo(a));
                        print(deleteIndexes);
                        for (var index in deleteIndexes) {
                          appViewModel.cachedImages.removeAt(index);
                          appViewModel.isChanged=true;
                        }
                        deleteMode=false;
                        deleteIndexes.clear();
                      });
                    }),
                    const SizedBox(height: 8),
                    OutlinedGradientButton("Отмена", () {
                      setState(() {
                        deleteMode=false;
                        deleteIndexes.clear();
                      });
                    }),
                  ],
                )
              ),
              if(MediaQuery.of(context).viewInsets.bottom!=0) Align(
                alignment: Alignment.topRight,
                child: Container(height: 50, width: 50,
                    margin: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ), child:
                    GestureDetector(
                      onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                      child: const Icon(Icons.keyboard_hide_sharp, size: 30, color: AppColors.darkGrey,),
                    )
                ),
              )
            ],
          ),
      ),
    );
  }

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

extension on Uint8List{
  int getCustomHashCode(){
    var hash = first;
    hash+=last;
    forEach((element) {
      hash+=element%1000;
    });
    return hash;
  }
}