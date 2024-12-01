import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/res/colors.dart';
import 'package:wishmap/testModule/testingEngine/pages/report1.dart';
import '../../router.dart';
import '../../toolWidgets/EmojiText.dart';
import '../../toolWidgets/indexes_edit_table.dart';
import '../../toolWidgets/wavwChart.dart';
import '../../toolWidgets/wind_rose.dart';
import '../../tools/tools.dart';
import '../ViewModel.dart';
import '../data/models.dart';

class ModuleAdmin extends StatefulWidget {
  const ModuleAdmin({super.key});

  ModuleAdminState createState() => ModuleAdminState();
}

class ModuleAdminState extends State{
  late TestViewModel vm;
  bool isVideoVisible = true;
  List<Question> questions = [];
  var step = 1;
  var maxStep = 21;

  List<double> ansvers = [];

  Map<String, double> wawefuncAnswer = {
  "Стыд/Позор":0,
  "Вина":0,
  "Апатия":0,
  "Горе":0,
  "Страх":0,
  "Вожделение":0,
  "Гнев":0,
  "Гордость":0,
  "Смелость":0,
  "Нейтралитет":0,
  "Готовность":0,
  "Принятие":0,
 "Разумность":0,
  "Любовь":0,
  "Радость":0,
  "Покой":0
  };

  List<String> spheres = [
  "Здоровье",
  "Отношения",
  "Окружение",
  "Призвание",
  "Богатство",
  "Саморазвитие",
  "Яркость жизни",
  "Духовность"
  ];

  Map<String, double> hokkingSumm =  {
    "Стыд/Позор":0,
    "Вина":0,
    "Апатия":0,
    "Горе":0,
    "Страх":0,
    "Вожделение":0,
    "Гнев":0,
    "Гордость":0,
    "Смелость":0,
    "Нейтралитет":0,
    "Готовность":0,
    "Принятие":0,
    "Разумность":0,
    "Любовь":0,
    "Радость":0,
    "Покой":0
  };

  @override
  void initState() {
    super.initState();
    // Получаем экземпляр ViewModel
    vm = Provider.of<TestViewModel>(context, listen: false);

    // Вызываем методы во ViewModel только один раз
    vm.getmoduleName();
    vm.getQuestions();
  }

  int toggledButton = -1;

  List<Question> currentResults = [];
  List<Question> totalResults = [];
  List<double> ressumm = [0,0,0,0,0,0,0,0];

  double expectation = 0;
  List<double> exps = const [0.20,0.30,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.50,3.10,3.50,4.00,5.00,5.40,6.00];
  int expectationLocation = 0;

  TextEditingController tc1 = TextEditingController()..text="Используйте кинезиологический тест";
  TextEditingController tc2 = TextEditingController()..text="Чтобы получить доступ к сознанию, используйте несложный кинезиологический мышечный тест, который определяет истинность или ложность утверждения в зависимости от мышечного тонуса. Мышцы тела мгновенно ослабевают в отсутствии Истины или становятся сильными в ее присутствии.\n\nГлубоко погрузитесь в чувства, которые вы исптываете, представляя себе свои любовные отношения с партнером.\n\nЕсли мышцы ваших палец и рук ослабевают и кольца разжимаются сами собой, значит вы чувствуете физическую слабость и отношения доставляют вам тревожные или негативные ощущения. Напротив, если мышцы в тонусе, и легко удерживают кольца скрепленными, то вы чуствуете силу, представляя ваши отношения, они не вводят  вас в тревогу и страх, вы уверены в себе, ваше настроение преподнято.";

  @override
  Widget build(BuildContext context) {
    expectation=calculateExpectation(hokkingSumm.values.toList(), exps);
    double minDifference = 0;
    for (int i = 0; i < 16; i++) {
      double difference = (exps[i]*100 - expectation*10.0).abs();
      if (difference < minDifference) {
        minDifference = difference;
        expectationLocation = i;
      }
    }

    return Consumer<TestViewModel>(builder: (context, viewModel, child){
      questions= viewModel.questionsAndKoeffs;
      if(questions.isNotEmpty) {
        maxStep = questions.length;
        currentResults.clear();
        totalResults.clear();
        for(int i=0; i<8; i++){
          currentResults.add(Question(question: spheres[i], answers: [], indexes: [questions[step-1].indexes[i], (ansvers.length==step)?ansvers[step-1]:-1, (ansvers.length==step)?ansvers[step-1]*questions[step-1].indexes[i]:-1]));
          totalResults.add(Question(question: spheres[i], answers: [], indexes: [questions[step-1].indexes[i], (ansvers.length==step)?ansvers[step-1]:-1, (ansvers.length==step)?ressumm[i]+(ansvers[step-1]*questions[step-1].indexes[i]):-1]));
        }
        if(ansvers.length==step) {
          int i =0;
          final hokins = viewModel.getHokinsForQuestion(step-1);
          wawefuncAnswer.forEach((key, value) {
          switch(ansvers.last){
            case 1:
              wawefuncAnswer[key]=hokins[0][i]/100.toDouble();
            case 0.75:
              wawefuncAnswer[key]=hokins[1][i]/100.toDouble();
            case 0.5:
              wawefuncAnswer[key]=hokins[2][i]/100.toDouble();
            case 0.25:
              wawefuncAnswer[key]=hokins[3][i]/100.toDouble();
            case 0:
              wawefuncAnswer[key]=hokins[4][i]/100.toDouble();
          }
          i++;
        });
        }
      }
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(child: Text(viewModel.moduleName, style: const TextStyle(fontSize: 20),),),
                                step>9?const SizedBox(height: 40,):Container(),
                                (step>9&&step<21)? Center(child: EmojiText(text: 'Хорошо идем 👍 10 вопросов позади', style: const TextStyle(fontSize: 18),)): step>19? Center(child: EmojiText(text: 'Отлично 🙂 20 вопросов позади', style: const TextStyle(fontSize: 18),),):Container(),
                                const SizedBox(height: 40,),
                                Row(children: [
                                  if(constraints.maxWidth>600)TextButton(onPressed: (){

                                  },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            bottomLeft: Radius.circular(20.0),
                                          ),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(progressColor),
                                    ),
                                    child: const Text(
                                      'назад',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),),
                                  if(constraints.maxWidth>600)const SizedBox(width: 30,),
                                  Expanded(child:SizedBox(height: 32,
                                      child:
                                      ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(20.0),
                                            bottomRight: Radius.circular(20.0),
                                          ),
                                          child:Stack(
                                            children: [
                                              Positioned.fill(
                                                child: LinearProgressIndicator(
                                                  minHeight: 10,
                                                  value: (step)/21, // Пример: 0.5 означает 50% заполнения
                                                  backgroundColor: buttonGrey, // Прозрачный фон для видимости границ
                                                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  '   Утверждение $step из $maxStep (${(step*100)~/maxStep}%)', // Текст внутри progress bar
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))))
                                ],),
                                const SizedBox(height:30,),
                                const Text('Оцените утверждение ниже', textAlign: TextAlign.left,),
                                const SizedBox(height: 20,),
                                Text(questions.isNotEmpty?questions[step-1].question:"", style: const TextStyle(fontSize: 22),),
                                const SizedBox(height: 30,),
                                Row(children: [
                                  Expanded(child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size(300.0, 60.0),
                                          backgroundColor: toggledButton==0?Colors.yellow:buttonGrey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            toggledButton=0;
                                            ansvers.length==step?ansvers[step-1]=1:ansvers.add(1);
                                          });
                                        },
                                        child: Text(
                                          questions.isNotEmpty?questions[step-1].answers[0]:'Согласен',
                                          style: TextStyle(fontSize: 20.0, color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(height: 30,),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size(300.0, 60.0),
                                          backgroundColor: toggledButton==1?Colors.yellow:buttonGrey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            toggledButton=1;
                                            ansvers.length==step?ansvers[step-1]=0.75:ansvers.add(0.75);
                                          });
                                        },
                                        child:  Text(
                                          questions.isNotEmpty?questions[step-1].answers[1]:'Скорее согласен',
                                          style: TextStyle(fontSize: 18.0, color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(height: 30,),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size(300.0, 60.0),
                                          backgroundColor: toggledButton==2?Colors.yellow:buttonGrey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            toggledButton=2;
                                            ansvers.length==step?ansvers[step-1]=0.5:ansvers.add(0.5);
                                          });
                                        },
                                        child: Text(
                                          questions.isNotEmpty?questions[step-1].answers[2]:'Нечто среднее',
                                          style: TextStyle(fontSize: 18.0, color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(height: 30,),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size(300.0, 60.0),
                                          backgroundColor: toggledButton==3?Colors.yellow:buttonGrey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            toggledButton=3;
                                            ansvers.length==step?ansvers[step-1]=0.25:ansvers.add(0.25);
                                          });
                                        },
                                        child: Text(
                                          questions.isNotEmpty?questions[step-1].answers[3]:'Скорее не согласен',
                                          style: const TextStyle(fontSize: 18.0, color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(height: 30,),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size(300.0, 60.0),
                                          backgroundColor: toggledButton==4?Colors.yellow:buttonGrey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            toggledButton=4;
                                            ansvers.length==step?ansvers[step-1]=0:ansvers.add(0);
                                          });
                                        },
                                        child: Text(
                                          questions.isNotEmpty?questions[step-1].answers[4]:'Не согласен',
                                          style: const TextStyle(fontSize: 20.0, color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(height: 30,),
                                    ],)),
                                  if(constraints.maxWidth>600)Expanded(child:Column(children: [
                                    TextField(controller: tc1, maxLines: 2, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                    TextField(controller: tc2, maxLines: 20, style: const TextStyle(fontWeight: FontWeight.normal, decoration: TextDecoration.none))
                                  ],))
                                ],),
                                const SizedBox(height: 80,),
                                Row(children: [
                                  TextButton(
                                    onPressed: () {
                                      viewModel.ansversM1=ansvers;
                                      for(int i=0; i<8; i++) {
                                        ressumm[i]+=(ansvers[step-1]*questions[step-1].indexes[i]);
                                      }
                                      wawefuncAnswer.forEach((key, value) {
                                        if(hokkingSumm.containsKey(key))hokkingSumm[key] = hokkingSumm[key]!+(wawefuncAnswer[key]??0);
                                      });
                                      setState(() {
                                        if(step!=maxStep) {
                                          step++;
                                        } else{
                                          viewModel.calculateResult();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => Report1()),
                                          );
                                        }
                                      });
                                    },
                                    child: Text(
                                      'Далее',
                                      style: TextStyle(fontSize: constraints.maxWidth>600?20.0:14, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: buttonGrey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  TextButton(
                                    onPressed: () {
                                      AppRouter.router.navigateTo(context, '/setting', transition: TransitionType.inFromRight);
                                    },
                                    child: Text(
                                      'Настройки',
                                      style: TextStyle(fontSize: constraints.maxWidth>600?20.0:14, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: buttonGrey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {

                                    },
                                    child: Text(
                                      'Сохранить',
                                      style: TextStyle(fontSize: constraints.maxWidth>600?20.0:14, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: buttonGrey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0), // Установите радиус скругления в 0.0, чтобы сделать кнопку квадратной
                                      ),
                                    ),
                                  ),
                                ],),
                                const Text("Колесо баланса", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                const Text("Результат данного ответа"),
                                const SizedBox(height: 10,),
                                EditableTable(maxWidth:  MediaQuery.of(context).size.width, questions: currentResults, indexTitle: const ["Вес вопроса", "Вес ответа", "Значение текущего ответа"], onValueUpdate: (value){},),
                                const SizedBox(height: 15),
                                const Text("Результат нарастающим итогом"),
                                const SizedBox(height: 10),
                                EditableTable(maxWidth:  MediaQuery.of(context).size.width, questions: totalResults, indexTitle: const ["Вес вопроса", "Вес ответа", "Значение текущего ответа"], onValueUpdate: (value){},),
                                const SizedBox(height: 55,),
                                const Center(child: Text("Диаграмма нарастающим итогом"),),
                                const SizedBox(height: 55,),
                                Center(child:WindRose(
                                  values: ressumm.indexed.map((e) => ((ansvers.length==step)?ressumm[e.$1]+(ansvers[step-1]*questions[step-1].indexes[e.$1]):0)*1.0).toList()
                                )),
                                const SizedBox(height: 45,),
                                const Center(child: Text("Распределение по Хокинсу")),
                                Row(children: [
                                  const SizedBox(width: 100, child:const Text("Мат.ожидание")),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black)
                                    ),
                                    child: Text(expectation.toString()),
                                  )
                                ],),
                                Row(children: [
                                  const SizedBox(width: 100, child:Text("Состояние")),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black)
                                    ),
                                    child: Text(expectationLocation.toString()),
                                  )
                                ],),
                                Row(children: [
                                  const SizedBox(width: 100, child:Text("Индекс")),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black)
                                    ),
                                    child: Text("none"),
                                  ),
                                ],),
                                  const SizedBox(height: 55,),
                                  const Text("Волновая функция ответа"),
                                  CustomLineChart(data: wawefuncAnswer, expectations: const [0.20,0.30,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.50,3.10,3.50,4.00,5.00,5.40,6.00]),
                                const SizedBox(height: 55,),
                                const Text("Волновая функция нарастающим итогом (Хокинс)"),
                                CustomLineChart(data: hokkingSumm, expectations: const [0.20,0.30,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.50,3.10,3.50,4.00,5.00,5.40,6.00]),

                              ])),
                        Container(
                          height: 100,
                          color: footerColor,
                        )
                      ])
                  );
                })
        );
    }
    );
  }
}