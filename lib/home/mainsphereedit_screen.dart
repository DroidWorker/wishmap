import 'dart:math';
import 'dart:typed_data';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/affirmationOverlay.dart';
import 'package:wishmap/data/static_affirmations_women.dart';

import '../ViewModel.dart';
import '../common/collage.dart';
import '../common/colorpicker_widget.dart';
import '../common/treeview_widget.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class MainSphereEditScreen extends StatefulWidget{

  const MainSphereEditScreen({super.key});

  @override
  _MainSphereEditScreenState createState() => _MainSphereEditScreenState();
}

class _MainSphereEditScreenState extends State<MainSphereEditScreen>{
  Color circleColor = Colors.black12;
  CircleData curWd = CircleData(id: -1, prevId: -1, nextId: -1, text: "", color: Colors.black12, parenId: -1);

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    appViewModel.isChanged;
    if(curWd.id==-1){
      if(appViewModel.mainSphereEditCircle==null){
        appViewModel.mainSphereEditCircle = appViewModel.mainScreenState?.allCircles[0].copy();
        appViewModel.isChanged = false;
      }
      appViewModel.isChanged = appViewModel.isChanged;
      curWd = appViewModel.mainSphereEditCircle??CircleData(id: 0, prevId: -1, nextId: -1, text: "", color: Colors.grey, parenId: -1);
      if(curWd.photosIds.isNotEmpty&&appViewModel.cachedImages.isEmpty){
        final ids = curWd.photosIds.split("|");
        List<int> intList = ids.map((str) => int.parse(str)).toList();
        appViewModel.getImages(intList);
      }
    }
    TextEditingController text = TextEditingController(text: curWd.text);
    TextEditingController affirmation = TextEditingController(text: curWd.affirmation.split("|")[0]);
    circleColor = curWd.color;
    text.addListener(() { curWd.text=text.text;appViewModel.isChanged = true;});
    return Consumer<AppViewModel>(
        builder: (context, appVM, child){
          final aims = appVM.aimItems.where((element) => element.parentId==0).toList();
          List<int> aimsids = aims.map((e) => e.id).toList();
          final tasks = appVM.taskItems.where((element) => aimsids.contains(element.parentId)).toList();
          List<MyTreeNode> root = [];
          for (var element in aims) {
            final childTasks = tasks.where((e) => e.parentId==element.id).toList();
            root.add(MyTreeNode(id: element.id, type: 'a', title: element.text, isChecked: element.isChecked, children: childTasks.map((item) => MyTreeNode(id: item.id, type: 't', title: item.text, isChecked: item.isChecked)).toList()));
          }
          if(root.isNotEmpty)root = [MyTreeNode(id: 0, type: 'm', title: curWd.text, isChecked: false, children: root)..noClickable=true];
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
                                onSaveClicked(appVM);
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
                      appViewModel.backPressedCount++;
                      if(appViewModel.backPressedCount==appViewModel.settings.quoteupdateFreq){
                        appViewModel.backPressedCount=0;
                        appViewModel.hint=quoteBack[Random().nextInt(367)];
                      }
                    },
                  ),
                  const Spacer(),
                  curWd.isActive?TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () async {
                        await appViewModel.updateSphereWish(WishData(id: curWd.id, prevId: curWd.prevId, nextId: curWd.nextId, parentId: curWd.parenId, text: curWd.text, description: curWd.subText, affirmation: curWd.affirmation, color: curWd.color));
                        if(appViewModel.mainScreenState!=null) await appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                        appViewModel.hint="Отлично! Теперь пришло время заполнить все сферы жизни. Ты можешь настроить состав и название сфер так, как считаешь нужным. И помни, что максимальное количество сфер ограничено и равно 1.";
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
                  ):
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          appViewModel.activateSphereWish(curWd.id, true);
                          if(appVM.mainScreenState!=null)appViewModel.startMainScreen(appVM.mainScreenState!.moon);
                          curWd.isActive = true;
                        });
                      },
                      child: const Text("Осознать",
                        style: TextStyle(color: AppColors.redTextColor),)
                  ),
                  const SizedBox(width: 15,)
                ],),
                const SizedBox(height: 5),
                Expanded(child: SingleChildScrollView(child:Padding(
                    padding: const EdgeInsets.all(15),
                child: Column(children: [
                TextField(
                  controller: text,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  onTap: (){if(!curWd.isActive)showUneditable();},
                  showCursor: true,
                  readOnly: curWd.isActive?false:true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    filled: true, // Заливка фона
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 7,
                      minHeight: 2,
                    ),
                    suffixIcon: const Text("*"),
                    fillColor: curWd.isActive?AppColors.fieldFillColor:AppColors.fieldInactive, // Серый фон с полупрозрачностью
                    hintText: 'Запиши желание', // Базовый текст
                    helperText: "Твое имя или то, с чем ты себя ассоциируешь",
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                  ),
                ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: affirmation,
                    readOnly: true,
                    onTap: () async {
                      final affirmationsStr = curWd.affirmation==""?
                        await showOverlayedAffirmations(context, defaultAffirmations, false, curWd.shuffle, onShuffleClick: (value){curWd.shuffle=value;}):
                        await showOverlayedAffirmations(context, curWd.affirmation.split("|"), true, curWd.shuffle, onShuffleClick: (value){curWd.shuffle=value;});
                      if(curWd.shuffle) curWd.lastShuffle = "|${DateTime.now().weekday.toString()}";
                      affirmation.text=affirmationsStr?.split("|")[0]??"";
                      curWd.affirmation=affirmationsStr??"";
                      appViewModel.isChanged =true;
                      },
                    style: const TextStyle(color: Colors.black), // Черный текст ввода
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      suffixIcon: const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.black),
                      suffixText: "*",
                      filled: true, // Заливка фона
                      fillColor: curWd.isActive?AppColors.fieldFillColor:AppColors.fieldInactive, // Серый фон с полупрозрачностью
                      hintText: 'Выбери аффирмацию', // Базовый текст
                      helperText: "Выберите аффирмацию или напишите свою",
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                    ),
                  ),
                const SizedBox(height: 15),
                LayoutBuilder(
                  builder: (context, constraints) {
                    double fullWidth = constraints.maxWidth-4;
                    double leftWidth = (constraints.maxWidth * 4 /7)-2;
                    double rightWidth = constraints.maxWidth - leftWidth - 2;
                    List<List<Uint8List>> imagesSet = [];
                    appViewModel.cachedImages.forEach((element) {if(imagesSet.isNotEmpty&&imagesSet.last.length<3){imagesSet.last.add(element);}else{imagesSet.add([element]);}});
                    if(imagesSet.isNotEmpty)imagesSet.removeAt(0);
                    return InkWell(onTap: (){
                      if(curWd.isActive) {
                        appViewModel.isChanged = true;
                        appViewModel.photoUrls.clear();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToGalleryScreenEvent());
                      }else{
                        showUneditable();
                      }
                    },
                        child:
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          Row(
                            children: [
                              Container(width: leftWidth, height: leftWidth, color: curWd.isActive?AppColors.fieldFillColor:AppColors.fieldInactive,
                                child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                  child: LinearCappedProgressIndicator(
                                    backgroundColor: Colors.black26,
                                    color: Colors.black,
                                    cornerRadius: 0,
                                  ),): appViewModel.cachedImages.isNotEmpty?Image.memory(appViewModel.cachedImages.first, fit: BoxFit.cover, color: curWd.isActive?null:Colors.redAccent,):Stack(children: [Container(padding: const EdgeInsets.all(8), child: const Center(child: Text("Добавьте образы вашего 'Я' - это важно!\n Чем ближе будут образы вашему представлению, тем сильнее будет визуализация вашего желания.", style: TextStyle(color: AppColors.greytextColor),))), const Align(alignment: Alignment.topRight, child: Text("*  "),)]),
                              ),
                              const SizedBox(width: 2),
                              Column(children: [
                                Container(width: rightWidth, height: leftWidth/2-2, color: curWd.isActive?AppColors.fieldFillColor:AppColors.fieldInactive,
                                  child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                    child: LinearCappedProgressIndicator(
                                      backgroundColor: Colors.black26,
                                      color: Colors.black,
                                      cornerRadius: 0,
                                    ),): appViewModel.cachedImages.length>1?Image.memory(appViewModel.cachedImages[1], fit: BoxFit.cover, color: curWd.isActive?null:Colors.redAccent):Container(),
                                ),
                                const SizedBox(height: 2),
                                Container(width: rightWidth, height: leftWidth/2-1, color: curWd.isActive?AppColors.fieldFillColor:AppColors.fieldInactive,
                                  child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                    child: LinearCappedProgressIndicator(
                                      backgroundColor: Colors.black26,
                                      color: Colors.black,
                                      cornerRadius: 0,
                                    ),): appViewModel.cachedImages.length>2?Image.memory(appViewModel.cachedImages[2], fit: BoxFit.cover, color: curWd.isActive?null:Colors.redAccent):Container(),
                                ),
                              ],)
                            ],
                          ),
                          ...imagesSet.map((e) {
                            Map<Uint8List, int?> em = Map.fromIterable(e, key: (v)=>v, value: (v)=>null);
                            if(e.length==1) return buildSingle(fullWidth, e.first, appVM.isinLoading,!curWd.isActive);
                            else if(e.length==2) return buildTwin(leftWidth, rightWidth, em, appVM.isinLoading,!curWd.isActive);
                            else if(imagesSet.indexOf(e)%2!=0) return buildTriple(leftWidth, rightWidth, em, appVM.isinLoading,!curWd.isActive);
                            else return buildTripleReverce(leftWidth, rightWidth, em, appVM.isinLoading,!curWd.isActive);
                          }).toList()
                        ])
                    );
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
                      if(curWd.isActive) {
                        appViewModel.isChanged = true;
                        appViewModel.photoUrls.clear();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToGalleryScreenEvent());
                      }else{
                        showUneditable();
                      }
                    },
                    child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor),)
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
                        if(curWd.isActive){showDialog(
                          context: context,
                          builder: (context) {
                            return ColorPickerWidget(initColor: circleColor ,onColorSelected: (Color c){setState(() {curWd.color=c; circleColor = c;appViewModel.isChanged=true;});});
                          },
                        );}else{
                          showUneditable();
                        }
                      },
                    )),
                Align(
                  alignment: Alignment.center,
                  child: Column(children: [
                    const Text("Цели и задачи", style: TextStyle(color: Colors.black54/*, decoration: TextDecoration.underline*/),),
                    const SizedBox(height: 5),
                      MyTreeView(key: UniqueKey(),roots: root, onTap: (id, type){
                        if(type=="m"){
                          if(appViewModel.isChanged){showOnExit(appVM);}else{
                          BlocProvider.of<NavigationBloc>(context).clearHistory();
                          appVM.cachedImages.clear();
                          appVM.startMainsphereeditScreen();
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainSphereEditScreenEvent());
                        }}else if(type=="w"){
                          if(appViewModel.isChanged){showOnExit(appVM);}else{
                          BlocProvider.of<NavigationBloc>(context).clearHistory();
                          appVM.startWishScreen(id, 0);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToWishScreenEvent());
                        }}else if(type=="a"){
                          if(appViewModel.isChanged){showOnExit(appVM);}else{
                          appVM.myNodes.clear();
                          appVM.getAim(id);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToAimEditScreenEvent(id));
                        }}else if(type=="t"){
                          if(appViewModel.isChanged){showOnExit(appVM);}else{
                          appVM.getTask(id);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToTaskEditScreenEvent(id));
                        }}
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
                          if(curWd.isActive){BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToAimCreateScreenEvent(0));}else{
                            showUneditable();
                          }
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

  Future<void> onSaveClicked(AppViewModel appViewModel) async {
    if(curWd.text.isEmpty||curWd.affirmation.isEmpty){
      showDialog(context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Необходимо заполнить все поля со знаком *'),
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
      return;
    }
    await appViewModel.updateSphereWish(WishData(id: curWd.id, prevId: curWd.prevId, nextId: curWd.nextId, parentId: curWd.parenId, text: curWd.text, description: curWd.subText, affirmation: curWd.affirmation, color: curWd.color));
    if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
    appViewModel.hint="Отлично! Теперь пришло время заполнить все сферы жизни. Ты можешь настроить состав и название сфер так, как считаешь нужным. И помни, что максимальное количество сфер ограничено и равно 13.";
    appViewModel.isChanged = false;
    showDialog(context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Сохранено'),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(c, 'OK');
              BlocProvider.of<NavigationBloc>(context)
                  .add(NavigateToMainScreenEvent());
              },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  showOnExit(AppViewModel appVM){
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
              onSaveClicked(appVM);
              },
              child: const Text('Да'),
            ),
            TextButton(
              onPressed: () { Navigator.pop(context, 'Cancel');
                appVM.isChanged=false;
              },
              child: const Text('Нет'),
            ),
          ],
        ),
      );
  }
  void showUneditable(){
    showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Чтобы редактировать 'Я' необходимо изменить статус на 'актуальное' нажав кнопку 'осознать'", maxLines: 5, textAlign: TextAlign.center,),
            SizedBox(height: 4,),
            Divider(color: AppColors.dividerGreyColor,),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async { Navigator.pop(context, 'OK'); },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

}
