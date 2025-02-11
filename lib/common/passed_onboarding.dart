import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stories/flutter_stories.dart';

import '../navigation/navigation_block.dart';

class PassedOnboardingScreen extends StatelessWidget {
  final _momentCount = 5;
  final _momentDuration = const Duration(seconds: 5);

  final slidesSet = {
    "Я говорю тебе спасибо!\nТы прошел тест — это важный шаг на пути к исполнению желаний и переменам в твоей жизни\n":
    "Уверен, ты отвечал на все вопросы теста искренне, вовлекаясь в свои чувства и представления.\n\nНе менее важно было глубоко погрузиться в смыслы, заложенные в отчеты, вобрать их в себя и учесть рекомендации стратегии эмпаурмента The Self.\n\nСо временем значение смыслов, заложенных в эти отчеты, будет раскрываться для тебя с новой силой снова и снова.",
    "Тесты помогают отслеживать прогресс\n":
    "Тест “Сферы жизни” всегда доступен для повторного прохождения. Однако делать это имеет смысл не чаще чем раз в полгода. Иначе результат теста будет бессознательно искажен. Проходи тест каждые полгода и отслеживай свой прогресс.\n\nСо временем в разделе “Мои тесты” будут появляться новые тесты. Проходи их и получай новые знания о себе. Каждый тест призван уточнять твой уровень сознания в определенных сферах жизни.",
    "Теперь ты готов к более осознанному исполнению своих желаний и переменам в жизни, однако...\n":
    "Отныне у тебя есть инструмент, который поможет тебе работать со своими желаниями так, чтобы они сбывались и вместе с тем изменить свою жизнь так, как ты пожелаешь.\n\nНо как и в любом ремесле, инструмент лишь упрощает работу и делает ее результат непревзойденного качества, если...\n\nЕсли ремесленник истинно любит то, чем занимается. Ровно так же и ты должен полюбить свою жизнь, возбудить в себе страсть к переменам, к исполнению своих заветных желаний, а данный инструмент поможет тебе в этом.",
    "Инструкция — это для тех, кто еще не умеет\n":
        "Одно из универсальных правил счастья гласит: «Остерегайся всякого полезного приспособления, если оно весит меньше, чем инструкция по его использованию».\n\nЛюбой инструмент требует знаний в обращении с собой. Я, создатель этого инструмента, с большой любовью отнесся к написанию инструкции к нему, сделав ее важной частью твоего пути к исполнению желаний и поистине настоящим переменам.",
    "Человек, овладевший знаниями, видит свой путь\n":
        "Моя цель — чтобы ты освободился от плена своих демонов, вырвался из клетки обстоятельств, расправил крылья и полетел навстречу своей яркой и счастливой жизни. \n\nЯ создал систему знаний, которая позволит тебе всецело осознать, как исполнять свои заветные мечты.\n\nПолучай знания, используй данное приложение, и ты обязательно придешь в лучшее место своей жизни."
  };

  PassedOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final images = List.generate(
      _momentCount,
          (idx) =>
          Stack(children: [
            Container(alignment: Alignment.bottomCenter,
              child: (idx < 5) ? Image.asset(
                  'assets/res/onboarding/p${idx + 1}.png') : Image.asset(
                  'assets/res/onboarding/emp.png')
            ),
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
                BlocProvider.of<NavigationBloc>(context).handleBackPress();
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
