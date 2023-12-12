import 'dart:typed_data';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';

import '../ViewModel.dart';
import '../common/collage.dart';
import '../common/colorpicker_widget.dart';
import '../common/treeview_widget.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class MainSphereEditScreen extends StatefulWidget{

  const MainSphereEditScreen({super.key});

  @override
  _MainSphereEditScreenState createState() => _MainSphereEditScreenState();
}

class _MainSphereEditScreenState extends State<MainSphereEditScreen>{
  Color circleColor = Colors.black12;
  CircleData curWd = CircleData(id: -1, text: "", color: Colors.black12, parenId: -1);

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    appViewModel.isChanged;
    if(curWd.id==-1){
      if(appViewModel.mainSphereEditCircle==null){
        appViewModel.mainSphereEditCircle = appViewModel.mainScreenState?.allCircles[0];
        appViewModel.isChanged = false;
      }
      appViewModel.isChanged = appViewModel.isChanged;
      curWd = appViewModel.mainSphereEditCircle??CircleData(id: 0, text: "", color: Colors.grey, parenId: -1);
      if(curWd.photosIds.isNotEmpty&&appViewModel.cachedImages.isEmpty){
        final ids = curWd.photosIds.split("|");
        List<int> intList = ids.map((str) => int.parse(str)).toList();
        appViewModel.getImages(intList);
      }
    }
    TextEditingController text = TextEditingController(text: curWd.text);
    TextEditingController description = TextEditingController(text: curWd.subText);
    TextEditingController affirmation = TextEditingController(text: curWd.affirmation);
    circleColor = curWd.color;
    text.addListener(() { curWd.text=text.text;appViewModel.isChanged = true;});
    description.addListener(() { curWd.subText=description.text;appViewModel.isChanged = true;});
    affirmation.addListener(() { curWd.affirmation=affirmation.text;appViewModel.isChanged = true;});
    return Consumer<AppViewModel>(
        builder: (context, appVM, child){
          final aims = appVM.aimItems.where((element) => element.parentId==0).toList();
          List<int> aimsids = aims.map((e) => e.id).toList();
          final tasks = appVM.taskItems.where((element) => aimsids.contains(element.parentId)).toList();
          final List<MyTreeNode> root = [];
          for (var element in aims) {
            final childTasks = tasks.where((e) => e.parentId==element.id).toList();
            root.add(MyTreeNode(id: element.id, type: 'a', title: element.text, isChecked: element.isChecked, children: childTasks.map((item) => MyTreeNode(id: item.id, type: 't', title: item.text, isChecked: item.isChecked)).toList()));
          }
          return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          maintainBottomViewPadding: true,
            child: Column(
              children: [
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    iconSize: 30,
                    onPressed: () {
                      if(appViewModel.isChanged){
                      showDialog(context: context,
                        builder: (BuildContext c) => AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(32.0))),
                          title: const Text('Внимание', textAlign: TextAlign.center,),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Вы изменили поля но не нажали 'Сохранить'", maxLines: 6, textAlign: TextAlign.center,),
                              SizedBox(height: 4,),
                              Divider(color: AppColors.dividerGreyColor,),
                              SizedBox(height: 4,),
                              Text("Сохранить изменения?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async { Navigator.pop(c, 'OK');
                              await appViewModel.updateSphereWish(WishData(id: curWd.id, parentId: curWd.parenId, text: curWd.text, description: curWd.subText, affirmation: curWd.affirmation, color: curWd.color));
                              if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                              appViewModel.isChanged = false;
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToMainScreenEvent());
                              showDialog(context: context,
                                builder: (BuildContext c) => AlertDialog(
                                  title: const Text('Сохранено'),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () { Navigator.pop(c, 'OK');},
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              },
                              child: const Text('Да'),
                            ),
                            TextButton(
                              onPressed: () { Navigator.pop(context, 'Cancel');
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToMainScreenEvent());},
                              child: const Text('Нет'),
                            ),
                          ],
                        ),
                      );}else{
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      }
                    },
                  ),
                  const Spacer(),
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () async {
                        await appViewModel.updateSphereWish(WishData(id: curWd.id, parentId: curWd.parenId, text: curWd.text, description: curWd.subText, affirmation: curWd.affirmation, color: curWd.color));
                        if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                        appViewModel.isChanged = false;
                        showDialog(context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Сохранено'),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(32.0))),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                        );
                      },
                      child: const Text("Cохранить",
                        style: TextStyle(color: AppColors.blueTextColor),)
                  ),
                ],),
                const SizedBox(height: 5),
                Expanded(child: SingleChildScrollView(child:Padding(
                    padding: const EdgeInsets.all(15),
                child: Column(children: [
                TextField(
                  controller: text,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true, // Заливка фона
                    fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                    hintText: 'Запиши желание', // Базовый текст
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: description,
                  minLines: 4,
                  maxLines: 15,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true, // Заливка фона
                    fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                    hintText: 'Опиши подробно свое желание', // Базовый текст
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    double fullWidth = constraints.maxWidth-4;
                    double leftWidth = (constraints.maxWidth * 4 /7)-2;
                    double rightWidth = constraints.maxWidth - leftWidth - 2;
                    List<List<Uint8List>> imagesSet = [];
                    appViewModel.cachedImages.forEach((element) {if(imagesSet.isNotEmpty&&imagesSet.last.length<3){imagesSet.last.add(element);}else{imagesSet.add([element]);}});
                    if(imagesSet.isNotEmpty)imagesSet.removeAt(0);
                    return Column(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          Row(
                            children: [
                              Container(width: leftWidth, height: leftWidth, color: AppColors.fieldFillColor,
                                child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                  child: LinearCappedProgressIndicator(
                                    backgroundColor: Colors.black26,
                                    color: Colors.black,
                                    cornerRadius: 0,
                                  ),): appViewModel.cachedImages.isNotEmpty?Image.memory(appViewModel.cachedImages.first, fit: BoxFit.cover):Container(),
                              ),
                              const SizedBox(width: 2),
                              Column(children: [
                                Container(width: rightWidth, height: leftWidth/2-2, color: AppColors.fieldFillColor,
                                  child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                    child: LinearCappedProgressIndicator(
                                      backgroundColor: Colors.black26,
                                      color: Colors.black,
                                      cornerRadius: 0,
                                    ),): appViewModel.cachedImages.length>1?Image.memory(appViewModel.cachedImages[1], fit: BoxFit.cover):Container(),
                                ),
                                const SizedBox(height: 2),
                                Container(width: rightWidth, height: leftWidth/2-1, color: AppColors.fieldFillColor,
                                  child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                    child: LinearCappedProgressIndicator(
                                      backgroundColor: Colors.black26,
                                      color: Colors.black,
                                      cornerRadius: 0,
                                    ),): appViewModel.cachedImages.length>2?Image.memory(appViewModel.cachedImages[2], fit: BoxFit.cover):Container(),
                                ),
                              ],)
                            ],
                          ),
                          ...imagesSet.map((e) {
                            if(e.length==1) return buildSingle(fullWidth, e.first, appVM.isinLoading);
                            else if(e.length==2) return buildTwin(leftWidth, rightWidth, e, appVM.isinLoading);
                            else if(imagesSet.indexOf(e)%2!=0) return buildTriple(leftWidth, rightWidth, e, appVM.isinLoading);
                            else return buildTripleReverce(leftWidth, rightWidth, e, appVM.isinLoading);
                          }).toList()
                        ]);
                  },
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fieldFillColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // <-- Radius
                      ),
                    ),
                    onPressed: (){
                      appViewModel.isChanged = true;
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigateToGalleryScreenEvent());
                    },
                    child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor),)
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: affirmation,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true, // Заливка фона
                    fillColor: AppColors.fieldFillColor, // Серый фон с полупрозрачностью
                    hintText: 'Напиши аффирмацию', // Базовый текст
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child:
                  Text("Выберите аффирмацию или напишите свою", style: TextStyle(fontSize: 10, color: Colors.black54),),
                ),
                const SizedBox(height: 10),
                Align(
                    alignment: Alignment.center,
                    child:
                    GestureDetector(child:
                    Column(children: [
                      const Text("Выбери цвет", style: TextStyle(color: Colors.black54/*, decoration: TextDecoration.underline*/),),
                      const SizedBox(height: 10),
                      Container(
                        width: 100.0, // Ширина круга
                        height: 100.0, // Высота круга
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Задаем форму круга
                          color: circleColor, // Устанавливаем цвет
                        ),
                      )
                    ],),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ColorPickerWidget(initColor: circleColor ,onColorSelected: (Color c){setState(() {curWd.color=c; circleColor = c;appViewModel.isChanged=true;});});
                          },
                        );
                      },
                    )),
                Align(
                  alignment: Alignment.center,
                  child: Column(children: [
                    const Text("Цели и задачи", style: TextStyle(color: Colors.black54/*, decoration: TextDecoration.underline*/),),
                    const SizedBox(height: 5),

                    /*...aims.asMap()
                        .entries
                        .map((entry) {
                      return GestureDetector(
                        onTap: () async {
                          await appViewModel.getAim(entry.value.id);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToAimEditScreenEvent(entry.value.id));
                        },
                        child: Row(
                          children: [
                            Expanded(child:Text(entry.value.text, maxLines: 3,),flex: 7,),
                            const Expanded(child: SizedBox()),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                              child: entry.value.isChecked?Image.asset('assets/icons/target1914412.png', width: 25, height: 25,):Image.asset('assets/icons/nountarget423422.png', width: 25, height: 25),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                    ...tasks.asMap()
                        .entries
                        .map((entry) {
                      return GestureDetector(
                        onTap: () async {
                          await appViewModel.getTask(entry.value.id);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToTaskEditScreenEvent(entry.value.id));
                        },
                        child: Row(
                          children: [
                            Expanded(child:Text(entry.value.text, maxLines: 3,),flex: 7),
                            const Expanded(child: SizedBox()),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                              child: entry.value.isChecked?const Icon(Icons.check_circle_outline, size: 19,):const Icon(Icons.circle_outlined, size: 19,),
                            )
                          ],
                        ),
                      );
                    }).toList()??[],*/
                    //Expanded(
                      //height: root.length*150,
                      MyTreeView(key: UniqueKey(),roots: root, onTap: (id, type){
                        if(type=="m"){
                          BlocProvider.of<NavigationBloc>(context).clearHistory();
                          appVM.cachedImages.clear();
                          appVM.startMainsphereeditScreen();
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainSphereEditScreenEvent());
                        }else if(type=="w"){
                          BlocProvider.of<NavigationBloc>(context).clearHistory();
                          appVM.startWishScreen(id, 0);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToWishScreenEvent());
                        }else if(type=="a"){
                          appVM.getAim(id);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToAimEditScreenEvent(id));
                        }else if(type=="t"){
                          appVM.getTask(id);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToTaskEditScreenEvent(id));
                        }
                      },),
                    //),
                    const SizedBox(height: 5),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.fieldFillColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // <-- Radius
                          ),
                        ),
                        onPressed: (){
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToAimCreateScreenEvent(0));
                        },
                        child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor))
                    )
                  ],),
                )]))),),
                if(MediaQuery.of(context).viewInsets.bottom!=0) SizedBox(height: 30,
                  child: FooterLayout(
                    footer: Container(height: 30,color: Colors.white,alignment: Alignment.centerRight, child:
                    GestureDetector(
                      onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                      child: const Text("готово", style: TextStyle(fontSize: 20),),
                    )
                      ,),
                  ),)
              ],
            ),
    ));});
  }
}
