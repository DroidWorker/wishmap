import 'package:wishmap/testModule/testingEngine/pages/registration.dart';
import 'package:wishmap/testModule/testingEngine/pages/report2.dart';
import 'package:wishmap/testModule/toolWidgets/wind_rose.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wishmap/res/colors.dart';
import '../../toolWidgets/wavwChart.dart';
import '../../tools/tools.dart';
import '../ViewModel.dart';

class Report1 extends StatelessWidget {

  bool isVideoVisible = true;
  @override
  Widget build(BuildContext context) {
    return Consumer<TestViewModel>(builder: (context, viewModel, child)
    {
      final testResult = viewModel.resultM1.values.toList();
      return testResult.isNotEmpty?
      Scaffold(
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
                const exp = [0.20,0.30,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.50,3.10,3.50,4.00,5.00,5.40,6.00];
                final expectation = calculateExpectation(viewModel.hokinsResultM1.values.toList(), exp);
                String expectationStatus = "";
                double minDifference = double.infinity;

                for (int i = 0; i < exp.length; i++) {
                  double difference = (exp[i]*100 - expectation*10.0).abs();
                  if (difference < minDifference) {
                    minDifference = difference;
                    expectationStatus = viewModel.hokinsResultM1.keys.toList()[i];
                  }
                }
                return SingleChildScrollView(
                    child: Column(children: [Container(
                        width: constraints.maxWidth,
                        color: bgMainColor,
                        padding: constraints.maxWidth > 600 ? const EdgeInsets
                            .all(100.0) : const EdgeInsets.all(20.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(child: Text(
                                'Вы прошли Модуль 1:  Сферы жизни',
                                style: TextStyle(fontSize: 20),),),
                              const SizedBox(height: 10,),
                              const Center(child: Text(
                                'Промежуточные результаты', style: TextStyle(
                                  fontSize: 16),),),
                              const SizedBox(height: 40,),
                              Row(children: [
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Колесо баланса",
                                      style: TextStyle(fontSize: 24),),
                                    const SizedBox(height: 30,),
                                    Text('''
Отношения          ${(testResult[0].toInt()~/10)} из 10
Богатство          ${(testResult[1].toInt()~/10)} из 10
Здоровье           ${(testResult[2].toInt()~/10)} из 10
Призвание          ${(testResult[3].toInt()~/10)} из 10
Окружение          ${(testResult[4].toInt()~/10)} из 10
Саморазвитие       ${(testResult[5].toInt()~/10)} из 10
Яркость жизни      ${(testResult[6].toInt()~/10)} из 10
Духовность         ${(testResult[7].toInt()~/10)} из 10'''),
                                    const SizedBox(height: 30,),
                                    const Text(
                                        'Важно пройти следующие модули для получения более реалистичных показателей.')
                                  ],)),
                                if(constraints.maxWidth > 600) WindRose(
                                    values: [
                                      testResult[0],
                                      testResult[1],
                                      testResult[2],
                                      testResult[3],
                                      testResult[4],
                                      testResult[5],
                                      testResult[6],
                                      testResult[7]
                                    ])
                              ],),
                              if(constraints.maxWidth <= 600) WindRose(
                                  values: [
                                    testResult[0],
                                    testResult[1],
                                    testResult[2],
                                    testResult[3],
                                    testResult[4],
                                    testResult[5],
                                    testResult[6],
                                    testResult[7]
                                  ]),
                              const SizedBox(height: 70,),
                              const Center(child: Text(
                                  "Волновая функция", style: TextStyle(
                                  fontSize: 24))),
                              const SizedBox(height: 20,),
                              CustomLineChart(data: viewModel.hokinsResultM1, expectations: const [0.20,0.30,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.50,3.10,3.50,4.00,5.00,5.40,6.00]),
                              const SizedBox(height: 70,),
                              if(constraints.maxWidth <= 600)const Text("""На основании результатов теста строится распределение плотности вероятности ваших энергетических состоятний. 

С помощью вычислений мы определяем в каком наиболее вероятном чувстве вы пребываете в тех или иных условиях реальности соприкаясь с разными сферами жизни.

Наиболее веротяное состотяние, так называемое математическое ожидание, определяет численное значение на графике и наиболее близкое чувство по значению."""),
                              Row(children: [
                                if(constraints.maxWidth > 600)const Expanded(
                                  child: Text("""На основании результатов теста строится распределение плотности вероятности ваших энергетических состоятний. 

С помощью вычислений мы определяем в каком наиболее вероятном чувстве вы пребываете в тех или иных условиях реальности соприкаясь с разными сферами жизни.

Наиболее веротяное состотяние, так называемое математическое ожидание, определяет численное значение на графике и наиболее близкое чувство по значению."""),),
                                if(constraints.maxWidth > 600)const SizedBox(
                                    width: 40),
                                Column(children: [
                                  const Text("Ваш индекс:",
                                    style: TextStyle(fontSize: 20),),
                                  Text((expectation.toInt()*10).toString(), style: TextStyle(fontSize: 28)),
                                  const Text("Ваше “наиболее вероятное” состояние: ",
                                      style: TextStyle(fontSize: 18)),
                                  Text(expectationStatus,
                                      style: const TextStyle(fontSize: 26))
                                ],)
                              ],),
                              const SizedBox(height: 50,),
                              const Center(child: Text(
                                "Чтобы сохранить промежуточные результаты - зарегистрируйтесь",
                                style: TextStyle(fontSize: 20),),),
                              const SizedBox(height: 70,),
                              Row(mainAxisAlignment: MainAxisAlignment
                                  .spaceAround,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Report2()),
                                      );
                                    },
                                    child: Text(
                                      'Продолжить тест\nмодуль2: Шкала Эмоций',
                                      style: TextStyle(
                                          fontSize: constraints.maxWidth > 600
                                              ? 20.0
                                              : 14, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            Registration()),
                                      );
                                    },
                                    child: Text(
                                      'Пройти оставшиеся\nтесты потом',
                                      style: TextStyle(
                                          fontSize: constraints.maxWidth > 600
                                              ? 20.0
                                              : 14, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],)
                            ]
                        )
                    ),
                      Container(
                        height: 100,
                        color: footerColor,
                      )
                    ]
                    )
                )
                ;
              }
          )
      ):
      inCalculating();
    });
  }

  Widget inCalculating(){
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
      body: const Center(
        child: Text("Вычисляем результаты"),
      ),
    );
  }
}