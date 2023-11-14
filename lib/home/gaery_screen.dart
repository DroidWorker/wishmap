
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../ViewModel.dart';
import '../common/gallery_widget.dart';
import '../navigation/navigation_block.dart';

class GalleryScreen extends StatefulWidget{
  const GalleryScreen({super.key});

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen>{
  int screenNumber = 1;
  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    return Scaffold(
      //backgroundColor: AppColors.backgroundColor,
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
                  const Expanded(child:
                  Text(
                    "Заполните коллаж изображениями и аффирмациями, которые вам нравятся",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ))
                ]
              ),
              Row(
                children: [
                  Expanded(child: ElevatedButton(
                      onPressed: () {
                          setState(() {
                            screenNumber = 1;
                          });
                      },
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),
                      child: Column(
                      children: [
                        const Icon(Icons.check_box_outline_blank_rounded, size:30, color: Colors.black,),
                        Text("Галерея", style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, decoration: screenNumber==1?TextDecoration.underline:TextDecoration.none),)
                      ]
                  )
                  ),),
                  Expanded(child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          screenNumber = 2;
                        });
                      },
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.transparent,),
                      child: Column(
                      children: [
                        const Icon(Icons.image_outlined, size:30, color: Colors.black,),
                        Text("Добавить", style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, decoration: screenNumber==2?TextDecoration.underline:TextDecoration.none),)
                      ]
                  )
                  ),)
                ],
              ),


              screenNumber==1?Expanded(child: RoundedPhotoGallery(onClick: (image){
                appViewModel.cachedImages.add(image);
                BlocProvider.of<NavigationBloc>(context).handleBackPress();
              })): Center(
                child: GestureDetector(
                  onTap: (){

                  },
                  child: const Icon(Icons.photo_camera, size: 90, color: Colors.black,),
                )
              ),
            ],
          ),
      ),
    );
  }
}