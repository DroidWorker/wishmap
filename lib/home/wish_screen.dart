import 'dart:typed_data';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/data/models.dart';

import '../ViewModel.dart';
import '../common/collage.dart';
import '../common/colorpicker_widget.dart';
import '../common/treeview_widget.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class WishScreen extends StatefulWidget {

  WishScreen({super.key});

  @override
  _WishScreenState createState() => _WishScreenState();
}

class _WishScreenState extends State<WishScreen>{
  Color circleColor = Colors.redAccent;
  Color? _color;

  bool isDataLoaded = false;

  TaskItem? wishTasks;
  AimItem? wishAims;

  final List<MyTreeNode> root = [];

  WishData curwish = WishData(id: -1, parentId: -1, text: "", description: "", affirmation: "", color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    TextEditingController _title = TextEditingController(text: curwish.text);
    TextEditingController _description = TextEditingController(text: curwish.description);
    TextEditingController _affirmation = TextEditingController(text: curwish.affirmation);
    _title.addListener(() { curwish.text=_title.text;});
    _description.addListener(() { curwish.description=_description.text;});
    _affirmation.addListener(() { curwish.affirmation=_affirmation.text;});

    return  Consumer<AppViewModel>(
        builder: (context, appVM, child){
          if(appVM.wishScreenState!=null&&curwish.id==-1) {
            curwish = appVM.wishScreenState!.wish;
            _title.text = appVM.wishScreenState!.wish.text;
            _description.text = appVM.wishScreenState!.wish.description;
            _affirmation.text = appVM.wishScreenState!.wish.affirmation;
            _color = appVM.wishScreenState!.wish.color;
            isDataLoaded = true;
            appViewModel.getAimsForCircles(appVM.wishScreenState!.wish.id);
            if(appVM.wishScreenState!.wish.photoIds.isNotEmpty){
              final ids = appVM.wishScreenState!.wish.photoIds.split("|");
              if(ids.isNotEmpty) {
                List<int> intList = ids
                    .where((str) => str != null)
                    .map((str) => int.tryParse(str!))
                    .where((value) => value != null)
                    .cast<int>()
                    .toList();
                if (intList.isNotEmpty) appViewModel.getImages(intList);
              }
            }
          }
          final aims = appVM.wishScreenState?.wishAims;
          final tasks = appVM.wishScreenState?.wishTasks;
          if(aims!=null&&tasks!=null){
            root.clear();
            for (var element in aims) {
              final childTasks = tasks.where((e) => e.parentId==element.id).toList();
              root.add(MyTreeNode(id: element.id, type: 'a', title: element.text, isChecked: element.isChecked, children: childTasks.map((item) => MyTreeNode(id: item.id, type: 't', title: item.text, isChecked: item.isChecked)).toList()));
            }
          }

          return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
              maintainBottomViewPadding: true,
              child:Column(children:[
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    iconSize: 30,
                    onPressed: () {
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigateToMainScreenEvent());
                    },
                  ),
                  const Expanded(child: SizedBox(),),
                  if(curwish.id > 800)
                    TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: curwish.isChecked?AppColors.pinkButtonTextColor:AppColors.greyBackButton,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onPressed: () async {
                          showDialog(context: context,
                            builder: (BuildContext context) => AlertDialog(
                              contentPadding: EdgeInsets.zero,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
                              title: const Text('Внимание', textAlign: TextAlign.center,),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  (!curwish.isChecked)?const Text("Если в данном желании создавались другие желания, цели и задачи, то они также получат статус 'исполнена' / 'достигнута' / 'выполнена'", maxLines: 6, textAlign: TextAlign.center,):
                                  const Text("Если в данном желании создавались другие желания, цели и задачи, то они останутся в статусе 'исполнена' / 'достигнута' / 'выполнена'", maxLines: 6, textAlign: TextAlign.center,),
                                  const SizedBox(height: 4,),
                                  const Divider(color: AppColors.dividerGreyColor,),
                                  const SizedBox(height: 4,),
                                  (curwish.isChecked)?const Text("Не исполнено?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),):
                                  const Text("Исполнено?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () { Navigator.pop(context, 'OK');
                                  curwish.isChecked=!curwish.isChecked;
                                  appViewModel.updateWishStatus(appVM.wishScreenState!.wish.id, curwish.isChecked);
                                  showDialog(context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: curwish.isChecked?const Text('исполнено'):const Text('не исполнено'),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () { Navigator.pop(context, 'OK');},
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                  },
                                  child: const Text('Да'),
                                ),
                                TextButton(
                                  onPressed: () { Navigator.pop(context, 'Cancel');},
                                  child: const Text('Нет'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text("Исполнено",style: TextStyle(color: Colors.black, fontSize: 12))
                    ),
                  const SizedBox(width: 3,),
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () async {
                        showDialog(context: context,
                          builder: (BuildContext c) => AlertDialog(
                            contentPadding: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(32.0))),
                            title: const Text('Внимание', textAlign: TextAlign.center,),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                (curwish.id > 800)?const Text("Если в данном желании создавались желания, цели и задачи, то они также будут удалены", maxLines: 4, textAlign: TextAlign.center,):
                                const Text("Если в данной сфере\n создавались желания,\n цели и задачи, то они\n также будут удалены", maxLines: 4, textAlign: TextAlign.center,),
                                const SizedBox(height: 4,),
                                const Divider(color: AppColors.dividerGreyColor,),
                                const SizedBox(height: 4,),
                                const Text("Удалить?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () { Navigator.pop(context, 'OK');
                                appViewModel.deleteSphereWish(appVM.wishScreenState!.wish.id);
                                showDialog(context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: const Text('Удалено'),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () { Navigator.pop(context, 'OK');
                                        var moon = appVM.mainScreenState!.moon;
                                        appViewModel.mainScreenState = null;
                                        appViewModel.mainCircles.clear();
                                        appViewModel.startMainScreen(moon);},
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                ).then((value) {
                                  var moon = appVM.mainScreenState!.moon;
                                  appViewModel.mainScreenState = null;
                                  appViewModel.mainCircles.clear();
                                  appViewModel.startMainScreen(moon);
                                  BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                });
                                },
                                child: const Text('Да'),
                              ),
                              TextButton(
                                onPressed: () { Navigator.pop(context, 'Cancel');},
                                child: const Text('Нет'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("Удалить",style: TextStyle(color: Colors.black, fontSize: 12))
                  ),
                  const SizedBox(width: 3,),
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () async {
                        appVM.wishScreenState!.wish
                          ..text=_title.text
                          ..description=_description.text
                          ..affirmation=_affirmation.text
                          ..color = _color!;
                        await appViewModel.createNewSphereWish(appVM.wishScreenState!.wish);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('сохранено'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                            },
                        );
                      },
                      child: const Text("Cохранить",
                        style: TextStyle(color: AppColors.blueTextColor, fontSize: 12),)
                  ),
                ],),
                Expanded(child:SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  TextField(
                    controller: _title,
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
                    minLines: 4,
                    maxLines: 15,
                    controller: _description,
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
                  if(curwish.id > 800)
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
                  if(curwish.id > 800)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fieldFillColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                      ),
                      onPressed: (){
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToGalleryScreenEvent());
                      },
                      child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor),)
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _affirmation,
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
                        const Text("Выбери цвет", style: TextStyle(color: Colors.black54),),
                        const SizedBox(height: 10),
                        Container(
                          width: 100.0, // Ширина круга
                          height: 100.0, // Высота круга
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Задаем форму круга
                            color: _color, // Устанавливаем цвет
                          ),
                        )
                      ],),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ColorPickerWidget(initColor: _color, onColorSelected: (Color c){setState(() {_color=c;curwish.color=c;});});
                            },
                          );
                        },
                      )),
                  if(curwish.id > 800)
                  Align(
                    alignment: Alignment.center,
                    child: Column(children: [
                      const Text("Цели и задачи", style: TextStyle(color: Colors.black54),),
                      const SizedBox(height: 5),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: root.length*150,
                            child: MyTreeView(key: UniqueKey(),roots: root, onTap: (id, type){
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
                          )
                      ),
                      /*...appVM.wishScreenState?.wishAims.asMap()
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
                      }).toList()??[],
                      ...appVM.wishScreenState?.wishTasks.asMap()
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
                      const SizedBox(height: 5),
                      if(curwish.id > 800)
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.fieldFillColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // <-- Radius
                            ),
                          ),
                          onPressed: (){
                            if(appVM.mainScreenState!.allCircles.where((element) => element.id==appVM.wishScreenState!.wish.id).isNotEmpty) {
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToAimCreateScreenEvent(
                                  appVM.wishScreenState!.wish.id));
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Необходимо сохранить желание'),
                                  duration: Duration(
                                      seconds: 3), // Установите желаемую продолжительность отображения
                                ),
                              );
                            }
                          },
                          child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor))
                      ),
                    ],),
                  )                ],
              ),),
          )),
                if(MediaQuery.of(context).viewInsets.bottom!=0) SizedBox(height: 30,
                  child: FooterLayout(
                    footer: Container(height: 30,color: Colors.white,alignment: Alignment.centerRight, child:
                      GestureDetector(
                        onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                        child: const Text("готово", style: TextStyle(fontSize: 20),),
                      )
                      ,),
                  ),)
              ]))
    );});
  }
}
