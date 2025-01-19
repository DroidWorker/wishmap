import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stories/flutter_stories.dart';

import '../navigation/navigation_block.dart';

class InitialOnboardingScreen extends StatelessWidget {
  final _momentCount = 3;
  final _momentDuration = const Duration(seconds: 5);

  final slidesSet = {
    "Привет! \nЯ знаю, ты здесь, чтобы исполнить все свои заветные мечты и изменить свою жизнь.":
    "Твой путь уникален, таких как ты больше нет, ты единственный в своем роде. Каким бы ни был твой следующий шаг, он также будет уникальным.\n\nОднако все мы здесь, чтобы наша жизнь была уникальна не только в наших страданиях, но и в нашем счастье.\n\nСделай первый шаг на пути к той жизни, которую хочешь прожить, сделай первый шаг к реализации своих желаний.",
    "Чтобы понять, как изменить свою жизнь, исполняя свои желания, ты должен осознать, где ты находишься!":
    "Важно понять свои сильные и слабые стороны, осознать, как устроена твоя жизнь и какие ее сферы требуют наибольшего внимания уже сейчас.\n\nЭто поможет тебе определить, какие жизненные проекты и желания для тебя наиболее актуальны, какие изменения на пути к их реализации принесут наибольшую пользу.",
    "Пройди этот простой тест, и мы вместе поймем, как и куда тебе следовать, чтобы исполнить все твои заветные желания!":
    "Тест состоит из 35 вопросов, которые помогут проанализировать твое текущее состояние в разных сферах жизни, а также подсветить актуальные желания, страхи и многое другое.\n\n  Не переживай, это займет всего несколько минут!\Отнесись к тесту максимально вдумчиво и честно. Посмотри памятку о технике кинезиологии — это важно!Ну что, начнем?"
  };

  InitialOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final images = List.generate(
      _momentCount,
          (idx) =>
          Stack(children: [
            Container(alignment: Alignment.bottomCenter,
              child: (idx == 0 || idx == 1) ? Image.asset(
                  'assets/res/onboarding/${idx + 1}.png') : idx == 2 ? Image
                  .asset('assets/res/onboarding/emp.png') : Image.asset(
                  'assets/res/onboarding/emp.png'),),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    slidesSet.entries.toList()[idx].key,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    slidesSet.entries.toList()[idx].value,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
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
            Expanded(child: Image.asset("assets/res/onboarding/back.png")),
            Story(
              onFlashForward: () {
                BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
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
                    BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigateToModuleScreenEvent());
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
