
import 'package:flutter/material.dart';

import 'package:wishmap/res/colors.dart';
import '../../toolWidgets/horizontalChart.dart';
import '../../toolWidgets/wavwChart.dart';
import '../../toolWidgets/wind_rose.dart';

class Report5 extends StatelessWidget {

  final List<BarData> data = [
    BarData(label: 'интерес', value: 0.8, color: Colors.blue, maxValue: 1),
    BarData(label: 'радость', value: 0.9, color: Colors.green, maxValue: 1),
    BarData(label: 'горе', value: 0.6, color: Colors.orange, maxValue: 1),
    BarData(label: 'гнев', value: 0.4, color: Colors.lightBlueAccent, maxValue: 1),
    BarData(label: 'страх', value: 0.3, color: Colors.lightBlueAccent, maxValue: 1),
    BarData(label: 'стыд', value: 0.4, color: Colors.lightBlueAccent, maxValue: 1),
  ];
  final List<BarData> data1 = [
    BarData(label: 'пэм', value: 18, color: Colors.lightBlueAccent, maxValue: 100),
  ];
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
                  child: Column(children:[Container(
                      width: constraints.maxWidth,
                      color: bgMainColor,
                      padding: constraints.maxWidth>600? const EdgeInsets.all(100.0): const EdgeInsets.all(20.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Center(child: Text('Модуль 5: Смертные грехи', style: TextStyle(fontSize: 20),),),
                            const SizedBox(height: 10,),
                            const Center(child: Text('Промежуточные результаты', style: TextStyle(fontSize: 16),),),
                            const SizedBox(height: 70,),
                            const Center(child: Text("Диаграмма смертные грехи", style: TextStyle(fontSize: 24))),
                            const SizedBox(height: 20),
                            HorizontalBarChart(barDataList: data),
                            const Text("тип: кающийся грешник"),
                            const SizedBox(height: 15,),
                            const Text("Предрасположенность к греху гордыни"),
                            const SizedBox(height: 10,),
                            HorizontalBarChart(barDataList: data1),
                            const SizedBox(height: 15,),
                            const Text("Шкала гнева"),
                            const SizedBox(height: 10,),
                            HorizontalBarChart(barDataList: data1),
                            const SizedBox(height: 15,),
                            const Text("Шкала 1"),
                            const SizedBox(height: 10,),
                            HorizontalBarChart(barDataList: data1),
                            const SizedBox(height: 15,),
                            const Text("Шкала 2"),
                            const SizedBox(height: 10,),
                            HorizontalBarChart(barDataList: data1),
                            const SizedBox(height: 15,),
                            const Text("Итоговый результат"),
                            const SizedBox(height: 10,),
                            HorizontalBarChart(barDataList: data1),
                            const SizedBox(height: 15,),
                            const Text("Шкала зависти"),
                            const SizedBox(height: 10,),
                            HorizontalBarChart(barDataList: data1),
                            HorizontalBarChart(barDataList: data),
                            const SizedBox(height: 15,),
                            const Text("Шкала профессиональной апатии"),
                            const SizedBox(height: 10,),
                            HorizontalBarChart(barDataList: data1),
                            const Text("Шкала апатии"),
                            const SizedBox(height: 10,),
                            HorizontalBarChart(barDataList: data1),
                            const Text("Чтобы расшифровать и сохранить результаты теста необходимо зарегестрироваться", style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
                            const SizedBox(height: 70,),
                            Row(children: [
                              const Expanded(child:Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Колесо баланса", style: TextStyle(fontSize: 24),),
                                  SizedBox(height: 30,),
                                  Text('''
Отношения          5 из 10
Богатство          4 из 10
Здоровье           8 из 10
Призвание          9 из 10
Окружение          7 из 10
Саморазвитие       7 из 10
Яркость жизни      6 из 10
Духовность         4 из 10'''),
                                  SizedBox(height: 30,),
                                  Text('Важно пройти следующие модули для получения более реалистичных показателей.')
                                ],)),
                              if(constraints.maxWidth>600)const WindRose(values: [0.2, 0.5, 0.1, 0.8, 0.6, 0.4, 0.8, 0.4])
                            ],),
                            if(constraints.maxWidth<=600)const WindRose(values: [0.2, 0.5, 0.1, 0.8, 0.6, 0.4, 0.8, 0.4]),
                            const SizedBox(height: 70,),
                            const Center(child: Text("Волновая функция", style: TextStyle(fontSize: 24))),
                            const SizedBox(height: 20,),
                            CustomLineChart(data: const {"Богатство": 2, "Здоровье":3, "Призвание": 5, "Окружение":2}, expectations: const [0.20,0.30,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.50,3.10,3.50,4.00,5.00,5.40,6.00]),
                            const SizedBox(height: 70,),
                            if(constraints.maxWidth<=600)const Text("""На основании результатов теста строится распределение плотности вероятности ваших энергетических состоятний. 

С помощью вычислений мы определяем в каком наиболее вероятном чувстве вы пребываете в тех или иных условиях реальности соприкаясь с разными сферами жизни.

Наиболее веротяное состотяние, так называемое математическое ожидание, определяет численное значение на графике и наиболее близкое чувство по значению."""),
                            Row(children: [
                              if(constraints.maxWidth>600)const Expanded(child: Text("""На основании результатов теста строится распределение плотности вероятности ваших энергетических состоятний. 

С помощью вычислений мы определяем в каком наиболее вероятном чувстве вы пребываете в тех или иных условиях реальности соприкаясь с разными сферами жизни.

Наиболее веротяное состотяние, так называемое математическое ожидание, определяет численное значение на графике и наиболее близкое чувство по значению."""),),
                              if(constraints.maxWidth>600)const SizedBox(width: 40),
                              const Column(children: [
                                Text("Ваш индекс:", style: TextStyle(fontSize: 20),),
                                Text("168", style: TextStyle(fontSize: 28)),
                                Text("Ваше “наиболее вероятное” состояние: ", style: TextStyle(fontSize: 18)),
                                Text("Гордость", style: TextStyle(fontSize: 26))
                              ],)
                            ],),
                            const SizedBox(height: 50,),
                            const Center(child: Text("""Здорово! Ты большой молодец, ты прошел все 5 модулей. Теперь мы можем составить полную анкету и на основании этих данных строить план действий по развитию показателей жизни. """, style: TextStyle(fontSize: 20),),),
                            const SizedBox(height: 70,),
                            const Center(child: Text("Расшифровать тесты", style: TextStyle(fontSize: 18, decoration: TextDecoration.underline),))
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
    );
  }
}