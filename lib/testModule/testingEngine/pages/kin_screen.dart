import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../navigation/navigation_block.dart';
import '../../../res/colors.dart';

class KinScreen extends StatefulWidget {
  @override
  KinScreenState createState() => KinScreenState();
}

class KinScreenState extends State<KinScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://videos.pexels.com/video-files/11159624/11159624-uhd_2560_1440_25fps.mp4'));
    await _controller.initialize();
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: false,
        looping: false,
        showOptions: false,
        aspectRatio: _controller.value.aspectRatio,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
              child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize
                                .shrinkWrap, // the '2023' part
                          ),
                          icon: const Icon(Icons.keyboard_arrow_left,
                              size: 28, color: AppColors.gradientStart),
                          onPressed: () {
                            BlocProvider.of<NavigationBloc>(context)
                                .handleBackPress();
                          }),
                      const Text("“Кинезиологический тест”",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(width: 29)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      _chewieController != null
                          ? SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxWidth / 2,
                              child: Chewie(controller: _chewieController!))
                          : const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      const Text(
                        "Используйте кинезиологический тест",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                          "Чтобы получить доступ к сознанию, используйте несложный кинезиологический мышечный тест, который определяет истинность или ложность утверждения в зависимости от мышечного тонуса. Мышцы тела мгновенно ослабевают в отсутствии Истины или становятся сильными в ее присутствии."),
                      const SizedBox(height: 4),
                      const Text(
                          "Глубоко погрузитесь в чувства, которые вы исптываете, представляя себе свои любовные отношения с партнером. "),
                      const SizedBox(height: 4),
                      const Text(
                          "Если мышцы ваших палец и рук ослабевают и кольца разжимаются сами собой, значит вы чувствуете физическую слабость и отношения доставляют вам тревожные или негативные ощущения. Напротив, если мышцы в тонусе, и легко удерживают кольца скрепленными, то вы чуствуете силу, представляя ваши отношения, они не вводят  вас в тревогу и страх, вы уверены в себе, ваше настроение преподнято.")
                    ],
                  ),
                )
              ],
            );
          }));
        })));
  }
}
