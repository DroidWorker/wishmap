import 'package:flutter/material.dart';
import 'package:wishmap/navigation/navigation_block.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/common/moon_widget.dart';
import 'package:wishmap/common/solarsystem.dart';
import 'package:wishmap/res/colors.dart';
import 'package:wishmap/data/models.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});
  final GlobalKey columnKey = GlobalKey();
  List<Circle> circles = [
    Circle(id: 1, text: 'Икигай', color: const Color(0xFFFF0000)),
    Circle(id: 2, text: 'Любовь', color: const Color(0xFFFF006B)),
    Circle(id: 3, text: 'Дети', color: const Color(0xFFD9D9D9)),
    Circle(id: 4, text: 'Путешествия', color: const Color(0xFFFFE600)),
    Circle(id: 5, text: 'Карьера', color: const Color(0xFF0029FF)),
    Circle(id: 6, text: 'Образование', color: const Color(0xFF46C8FF)),
    Circle(id: 7, text: 'Семья', color: const Color(0xFF3FA600)),
    Circle(id: 8, text: 'Богатство', color: const Color(0xFFB4EB5A)),
  ];

  List<MainCircle> centralCircles = [
    MainCircle(id: 0, coords: Pair(key: 0.0, value: 0.0), text: "я", textSize: 40, color: Colors.black, radius: 80)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(child:Stack(
        children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    iconSize: 30,
                    onPressed: () {},
                  )
                ],
              ),
              const SizedBox(height: 10.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          MoonWidget(fillPercentage: 0.7),
                          Text("08.10.2023")
                        ],
                      )),
                  Expanded(
                      flex: 6,
                      child:
                      Text("подсказка")
                  )
                ],
              ),
              const SizedBox(height: 10),
              Expanded(child:
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return const SizedBox();
                },
              )
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous_outlined),
                    iconSize: 50,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.pause_circle_outline),
                    iconSize: 50,
                    onPressed: () {
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigateToAuthScreenEvent());
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.skip_next_outlined),
                    iconSize: 50,
                    onPressed: () {},
                  )
                ],),
              const SizedBox(height: 20),
              const Divider(
                height: 10,
                thickness: 5,
                indent: 0,
                endIndent: 0,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/icons/checklist2665651.png'),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToTasksScreenEvent());
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/goal6002764.png'),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToAimsScreenEvent());
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/wheel2526426.png'),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToAimsScreenEvent());
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/notelove1648387.png'),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToWishesScreenEvent());
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/notepad2725914.png'),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToProfileScreenEvent());
                      },
                    )
                  ],
                ),)
            ],
          ),
        ),
        CircularDraggableCircles(circles: circles, centralCircles: centralCircles, size: MediaQuery.of(context).size.height-350<MediaQuery.of(context).size.width-20? MediaQuery.of(context).size.height-350 : MediaQuery.of(context).size.width-20, center: Pair(key: MediaQuery.of(context).size.width/2, value: MediaQuery.of(context).size.height*0.50)),
      ],))
    );
  }
}
