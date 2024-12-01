import 'package:flutter/material.dart';

import '../../../res/colors.dart';
import 'module.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  MainPageState createState() => MainPageState();
}

class MainPageState extends State{
  var isToggled = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: appbarColor,
            scrolledUnderElevation: 0,
            toolbarHeight: 90,
            title: Center(
              child: Image.asset(
                'assets/res/images/logo.png',
                    height: 90,
              ),
            )
        ),
        body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  width: constraints.maxWidth,
                  color: bgMainColor,
                  padding: constraints.maxWidth>600? const EdgeInsets.all(100.0): const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Зачем нужен тест?',
                          style: TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        const Text(
                          'Чтобы сбежать из тюрьмы, нужно прежде всего знать, что ты в ней находишься.  (с) Гурджиев',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(height: 20.0),
                        constraints.maxWidth>600?Row(
                          children: [
                            const Expanded(flex:2,child:Text('Итак, для эффективной работы по изменению своей жизни и приведения себя в невероятно потрясающую реальность необходимо проделать путь, но любой путь с чего-то начинается. Именно для этого мы должны обнаружить, где мы сейчас находимся. Тест это сканирование нашего состояния по множеству параметров нашей личности, нашей жизни, наших ощущений. Тест это возможность задать себе множество важных вопросов, отвечая на которые мы определяемся с нашим местоположением в этой реальности, а именно, в каком состоянии души и тела мы тут пребываем, насколько все в нашей жизни хорошо или плохо, что надо срочно исправлять и как это делать.', style: TextStyle(fontSize: 18))),
                            Expanded(child: Image.asset('assets/res/images/vitruvian.png'))
                          ],
                        ):Column(
                          children: [
                            Image.asset('assets/res/images/vitruvian.png'),
                            const Text('Итак, для эффективной работы по изменению своей жизни и приведения себя в невероятно потрясающую реальность необходимо проделать путь, но любой путь с чего-то начинается. Именно для этого мы должны обнаружить, где мы сейчас находимся. Тест это сканирование нашего состояния по множеству параметров нашей личности, нашей жизни, наших ощущений. Тест это возможность задать себе множество важных вопросов, отвечая на которые мы определяемся с нашим местоположением в этой реальности, а именно, в каком состоянии души и тела мы тут пребываем, насколько все в нашей жизни хорошо или плохо, что надо срочно исправлять и как это делать.', style: TextStyle(fontSize: 18))
                          ]
                        ),
                        const SizedBox(height: 20.0),
                        const Text(
                          'Механика теста',
                          style: TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        constraints.maxWidth>600?Row(
                          children: [
                            Expanded(child:Image.asset('assets/res/images/progress.png')),
                            const SizedBox(width: 20,),
                            const Expanded(flex:3,child:Text("Комплексный тест включает в себя  290 вопросов и состоит из 5 модулей.\n1. Сферы жизни\n2. Шкала эмоций\n3. Качество жизни\n4. Оценка Я\n5. Смертные грехи\n\nКаждая часть теста раскрывает все глубже и глубже истинное положение дел в твоей жизни и с твоим Я.\nОбщее время, комплексного тетсирования порядка 2 часов, если без перерывов. Для получения достоверного результата важно проходить тест с максимальной отдачей и искренностью перед самим собой, а на это требуются силы и время. Вы можете делать перерывы на свое усмотрение, система вам поможет соориентироваться по ходу теста", style: TextStyle(fontSize: 18))),
                          ],
                        ):Column(children: [
                          Image.asset('assets/res/images/progress.png'),
                          const Text("Комплексный тест включает в себя  290 вопросов и состоит из 5 модулей.\n1. Сферы жизни\n2. Шкала эмоций\n3. Качество жизни\n4. Оценка Я\n5. Смертные грехи\n\nКаждая часть теста раскрывает все глубже и глубже истинное положение дел в твоей жизни и с твоим Я.\nОбщее время, комплексного тетсирования порядка 2 часов, если без перерывов. Для получения достоверного результата важно проходить тест с максимальной отдачей и искренностью перед самим собой, а на это требуются силы и время. Вы можете делать перерывы на свое усмотрение, система вам поможет соориентироваться по ходу теста", style: TextStyle(fontSize: 18)),
                        ],),
                        const SizedBox(height: 20.0),
                        const Text(
                          'Что на выходе?',
                          style: TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        constraints.maxWidth>600?Row(
                          children: [
                            const Expanded(child:Text("Полная анкета, определяющая:\nПозитивные / негативные / тревожные эмоции\nПодробное описание\n\nПозитивные отношения\nАвтономия\nУправление средой\nЛичностный рост\nЦели в жизни\nСамопринятие\nБаланс аффекта\nОсмысленность жизни\nЧеловек как открытая система\n\n Оптимистичность\n Напряженность\n Самоконтроль\nПоддержка\n\nи смертные грехи \nГордыня \nЗависть \nГнев \nАлчность \nУныние", style: TextStyle(fontSize: 18))),
                            Expanded(child:Image.asset('assets/res/images/brain.png')),
                          ],
                        ):Column(children: [
                          Image.asset('assets/res/images/brain.png'),
                          const Text("Полная анкета, определяющая:\nПозитивные / негативные / тревожные эмоции\nПодробное описание\n\nПозитивные отношения\nАвтономия\nУправление средой\nЛичностный рост\nЦели в жизни\nСамопринятие\nБаланс аффекта\nОсмысленность жизни\nЧеловек как открытая система\n\n Оптимистичность\n Напряженность\n Самоконтроль\nПоддержка\n\nи смертные грехи \nГордыня \nЗависть \nГнев \nАлчность \nУныние", style: TextStyle(fontSize: 18)),
                        ],),
                        const SizedBox(height: 40.0),
                        const Text(
                          'Волновая функция',
                          style: TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Image.asset("assets/res/images/wawefunc.png"),
                        const SizedBox(height: 10.0),
                        const Text("Тест определит вашу личную текущую суперпозицию чувств, вашу личную волновую функцию, а именно распределение эмоциональных состояний по разным сферам жизни",
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 20.0),
                        const Text("Отвечая на вопросы система анализирует ваши ответы и определяет, какое чувство у вас возникает как реакция на вопрос и строит распределение вероятностей нахождения в той или иной эмоции в разных обстоятельствах и сферах жизни и представляет это распределение в виде волновой функции - суперпозииция энергетических состотяний", style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 20.0),
                        const Text(
                          'Колесо баланса',
                          style: TextStyle(fontSize: 24.0),
                        ),
                        const SizedBox(height: 20.0),
                        constraints.maxWidth>600?Row(
                          children: [
                            const Expanded(child:Text('Колесо баланса - показывает, насколько развиты твои различные сферы жизни. Уникальный для каждого человека набор показателей показывает степень развитости личности.\nОт того, насколько гармонично сферы жизни взаимодействуют между собой, зависит  успешность, благополучие, моральное состояние, ощущение удовлетворенности от жизни. Чтобы достичь гармонии между этими составными частями важно поддерживать баланс. Они не должны мешать или как-то противоречить друг другу.', style: TextStyle(fontSize: 18))),
                            Expanded(child:Image.asset('assets/res/images/vitruvian.png'))
                          ],
                        ): Column(children: [
                          Image.asset('assets/res/images/vitruvian.png'),
                          const Text('Колесо баланса - показывает, насколько развиты твои различные сферы жизни. Уникальный для каждого человека набор показателей показывает степень развитости личности.\nОт того, насколько гармонично сферы жизни взаимодействуют между собой, зависит  успешность, благополучие, моральное состояние, ощущение удовлетворенности от жизни. Чтобы достичь гармонии между этими составными частями важно поддерживать баланс. Они не должны мешать или как-то противоречить друг другу.', style: TextStyle(fontSize: 18)),
                        ],),
                        const SizedBox(height: 100.0),
                        const Text(
                          'Устраивайтесь поудобнее, мы начинаем!',
                          style: TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                        const SizedBox(height: 60.0),
                        const Text("Укажите свой пол:", style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10.0),
                        Row(mainAxisSize: MainAxisSize.min,
                          children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: isToggled != 1 ? buttonGrey : buttonActive,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isToggled = 1;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Module1()),
                              );
                            },
                            child: const Text(
                              'мужчина',
                              style: TextStyle(fontSize: 18.0, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: isToggled != 2 ? buttonGrey : buttonActive,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isToggled = 2;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Module1()),
                              );
                            },
                            child: const Text(
                              'женщина',
                              style: TextStyle(fontSize: 18.0, color: Colors.black),
                            ),
                          ),
                        ],)
                      ],
                    ),
                  ),
                ),
              );
            })
    );
  }
}