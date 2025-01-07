import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stories/flutter_stories.dart';

import '../navigation/navigation_block.dart';

class InitialOnboardingScreen extends StatelessWidget {
  final _momentCount = 3;
  final _momentDuration = const Duration(seconds: 5);

  const InitialOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final images = List.generate(
      _momentCount,
      (idx) => Stack(children: [
        Image.asset('assets/res/onboarding/${idx + 1}.png'),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Привет! \nЯ знаю, ты здесь, чтобы исполнить все свои заветные мечты и изменить свою жизнь.",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              Text(
                "Твой путь уникален, таких как ты больше нет, ты единственный в своем роде. Каким бы ни был твой следующий шаг, он также будет уникальным.\n\nОднако все мы здесь, чтобы наша жизнь была уникальна не только в наших страданиях, но и в нашем счастье.\n\nСделай первый шаг на пути к той жизни, которую хочешь прожить, сделай первый шаг к реализации своих желаний.",
                style: TextStyle(fontSize: 14, color: Colors.white),
              )
            ],
          ),
        ),
      ]),
    );

    return Scaffold(
        backgroundColor: CupertinoColors.black,
        body: SafeArea(
          child: Stack(children: [
            Story(
              onFlashForward: () {
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToModuleScreenEvent());
              },
              onFlashBack: () {},
              //Navigator.of(context).pop,
              momentCount: _momentCount,
              momentDurationGetter: (idx) => _momentDuration,
              momentBuilder: (context, idx) => images[idx],
            ),
            Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                  onTap: () {
                    BlocProvider.of<NavigationBloc>(context).handleBackPress();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  )),
            )
          ]),
        ));
  }
}
