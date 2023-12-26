import 'dart:typed_data';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/data/models.dart';

import '../ViewModel.dart';
import '../common/EditTextOverlay.dart';
import '../common/affirmationOverlay.dart';
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

  bool isParentChecked = false;

  WishData curwish = WishData(id: -1, parentId: -1, text: "", description: "", affirmation: "", color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    TextEditingController _title = TextEditingController(text: curwish.text);
    TextEditingController _description = TextEditingController(text: curwish.description);
    TextEditingController _affirmation = TextEditingController(text: curwish.affirmation);
    _title.addListener(() { curwish.text=_title.text;if(curwish.text!=appViewModel.wishScreenState!.wish.text)appViewModel.isChanged = true;});
    _description.addListener(() { curwish.description=_description.text;if(curwish.text!=appViewModel.wishScreenState!.wish.text)appViewModel.isChanged = true;});
    _affirmation.addListener(() { curwish.affirmation=_affirmation.text;if(curwish.text!=appViewModel.wishScreenState!.wish.text)appViewModel.isChanged = true;});

    return  Consumer<AppViewModel>(
        builder: (context, appVM, child){
          print("ggggggggggggggg${appVM.isChanged}");
          if(appVM.wishScreenState!=null&&curwish.id==-1) {
            curwish = appVM.wishScreenState!.wish;
            _title.text = appVM.wishScreenState!.wish.text;
            _description.text = appVM.wishScreenState!.wish.description;
            _affirmation.text = appVM.wishScreenState!.wish.affirmation;
            _color = appVM.wishScreenState!.wish.color;
            isDataLoaded = appVM.wishScreenState!.isDataloaded;
            //appViewModel.getAimsForCircles(appVM.wishScreenState!.wish.id);
            appVM.convertToMyTreeNodeFullBranch(curwish.id);
            isParentChecked = appVM.mainScreenState!.allCircles.where((element) => element.id==curwish.parentId).first.isChecked;
            if(appVM.wishScreenState!.wish.photoIds.isNotEmpty&&!isDataLoaded){
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
            appViewModel.wishScreenState!.isDataloaded = true;
          }
          root.clear();
          root.addAll(appVM.myNodes);

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
                            if(!curwish.isChecked&&appViewModel.isChanged){showDialog(context: context,
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
                                    onPressed: () async { Navigator.pop(context, 'OK');
                                    appVM.wishScreenState!.wish
                                      ..text=_title.text
                                      ..description=_description.text
                                      ..affirmation=_affirmation.text
                                      ..color = _color!;
                                    await appViewModel.createNewSphereWish(appVM.wishScreenState!.wish);
                                    BlocProvider.of<NavigationBloc>(context)
                                        .handleBackPress();
                                    showDialog(context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: const Text('Сохранено'),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'OK');
                                            },
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
                                        .handleBackPress();
                                    },
                                    child: const Text('Нет'),
                                  ),
                                ],
                              ),
                            );
                            }else{
                              BlocProvider.of<NavigationBloc>(context)
                                  .handleBackPress();
                            }}
                      ),
                      const Expanded(child: SizedBox(),),
                      if(curwish.id > 899)
                        TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: curwish.isChecked?AppColors.pinkButtonTextColor:AppColors.greyBackButton,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            onPressed: () async {
                              if(isParentChecked) {
                                showCantChangeStatus();
                              } else if(curwish.isHidden){
                                showUnavailable("Чтобы изменить статус 'исполнено' необходимо отменить статус 'скрыто'");
                              } else {
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
                              }
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
                                    (curwish.id > 899)?const Text("Если в данном желании создавались желания, цели и задачи, то они также будут удалены", maxLines: 4, textAlign: TextAlign.center,):
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
                      if(curwish.isActive&&!curwish.isChecked)TextButton(
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
                            appViewModel.isChanged = false;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('сохранено'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'OK');
                                        setState(() {appVM.convertToMyTreeNodeFullBranch(curwish.id);});
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text("Cохранить",
                            style: TextStyle(color: AppColors.blueTextColor, fontSize: 12),)
                      )else if(!curwish.isActive)
                      TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.greyBackButton,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              appViewModel.activateSphereWish(curwish.id, true);
                              appViewModel.mainCircles.where((element) => element.id==curwish.id).first.isActive=true;
                              curwish.isActive=true;
                            });
                          },
                          child: const Text("Представить",
                            style: TextStyle(color: AppColors.redTextColor),)
                      )
                      else if(curwish.isChecked&&curwish.id > 899)
                          TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: curwish.isHidden?AppColors.pinkButtonTextColor:AppColors.greyBackButton,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  curwish.isHidden = !curwish.isHidden;
                                  appViewModel.hideSphereWish(curwish.id, curwish.isHidden);
                                });
                              },
                              child: const Text("Скрыть",
                                style: TextStyle(color: AppColors.redTextColor),)
                          ),
                      const SizedBox(width: 15,)
                    ],),
                    Expanded(child:SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            TextField(
                              controller: _title,
                              onTap: (){if(curwish.isChecked)showUnavailable("Чтобы редактировать желание необходимо перевести в статус \nна 'не исполнено'");else if(!curwish.isActive)showUneditable();},
                              showCursor: true,
                              readOnly: curwish.isChecked||!curwish.isActive?true:false,
                              style: const TextStyle(color: Colors.black), // Черный текст ввода
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                filled: true, // Заливка фона
                                fillColor: curwish.isActive?AppColors.fieldFillColor:AppColors.fieldInactive, // Серый фон с полупрозрачностью
                                hintText: 'Запиши желание', // Базовый текст
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              minLines: 4,
                              maxLines: 7,
                              controller: _description,
                              onTap: () async {
                                if(curwish.isChecked){showUnavailable("Чтобы редактировать желание необходимо сменить статус \nна 'не выполнено'");}
                                else if(!curwish.isActive){showUneditable();}
                                else {
                                  _description.text = await showOverlayedEdittext(context, _description.text, (curwish.isActive&&!curwish.isChecked))??"";
                                  appViewModel.isChanged= true;
                                }
                                },
                              showCursor: false,
                              readOnly: true,
                              style: const TextStyle(color: Colors.black), // Черный текст ввода
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                filled: true, // Заливка фона
                                fillColor: curwish.isActive?AppColors.fieldFillColor:AppColors.fieldInactive, // Серый фон с полупрозрачностью
                                hintText: 'Опиши подробно свое желание', // Базовый текст
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                              ),
                            ),
                            const SizedBox(height: 10),
                            if(curwish.id > 899)
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
                                            Container(width: leftWidth, height: leftWidth, color: curwish.isActive?AppColors.fieldFillColor:AppColors.fieldInactive,
                                              child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                                child: LinearCappedProgressIndicator(
                                                  backgroundColor: Colors.black26,
                                                  color: Colors.black,
                                                  cornerRadius: 0,
                                                ),): appViewModel.cachedImages.isNotEmpty?Image.memory(appViewModel.cachedImages.first, fit: BoxFit.cover):Container(),
                                            ),
                                            const SizedBox(width: 2),
                                            Column(children: [
                                              Container(width: rightWidth, height: leftWidth/2-2, color: curwish.isActive?AppColors.fieldFillColor:AppColors.fieldInactive,
                                                child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                                  child: LinearCappedProgressIndicator(
                                                    backgroundColor: Colors.black26,
                                                    color: Colors.black,
                                                    cornerRadius: 0,
                                                  ),): appViewModel.cachedImages.length>1?Image.memory(appViewModel.cachedImages[1], fit: BoxFit.cover):Container(),
                                              ),
                                              const SizedBox(height: 2),
                                              Container(width: rightWidth, height: leftWidth/2-1, color: curwish.isActive?AppColors.fieldFillColor:AppColors.fieldInactive,
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
                                          if(e.length==1) return buildSingle(fullWidth, e.first, appVM.isinLoading, !curwish.isActive);
                                          else if(e.length==2) return buildTwin(leftWidth, rightWidth, e, appVM.isinLoading, !curwish.isActive);
                                          else if(imagesSet.indexOf(e)%2!=0) return buildTriple(leftWidth, rightWidth, e, appVM.isinLoading, !curwish.isActive);
                                          else return buildTripleReverce(leftWidth, rightWidth, e, appVM.isinLoading, !curwish.isActive);
                                        }).toList()
                                      ]);
                                },
                              ),
                            const SizedBox(height: 5),
                            if(curwish.id > 899)
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.fieldFillColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), // <-- Radius
                                    ),
                                  ),
                                  onPressed: (){
                                    appViewModel.isChanged = true;
                                    curwish.isChecked?showUnavailable("Чтобы редактировать желание необходимо сменить статус \nна 'не выполнено'"):!curwish.isActive?showUneditable():BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigateToGalleryScreenEvent());
                                  },
                                  child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor),)
                              ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _affirmation,
                              readOnly: true,
                              onTap: () async {
                                if(curwish.isChecked){
                                  showUnavailable("Чтобы редактировать желание необходимо сменить статус \nна 'не выполнено'");
                                  return;
                                }else if(!curwish.isActive){
                                  showUneditable();
                                }else{
                                final affirmationsStr = curwish.affirmation==""?
                                await showOverlayedAffirmations(context, ["Я счастлив и спокоен", "Я благословенный и умиротворенный", "Я радостный и свободный", "Я смотрю на мир с любовью", "Я успешный и счастливый", "Я безмятежный и радостный", "Я полон любви и благодати", "Я достигший своих заветных целей", "Я Люблю свое тело и люблю свою душу", "Я в изобилии и наслаждении", "Я энергичный и эйфоричный", "Я умиротворенный и благодарный", "Я ликующий и сверкающий", "Я востроженный и наслаждающийся жизнью", "Я бееззаботный и радужный", "Я вдохновенный и преисполненный", "Я озаренный и благодарный", "Я принимааю и ценю себя таким какой я есть", "Я умиротворенный и свободный от тревоги", "Я ликующий и счастливый до глубины души", "Я благодарный и удовлетворенный", "Я влюбленный и исполненный милости", "Я гармоничный и исполненный радости", "Я радостный и восорженный в каждом мгновении"], false):
                                await showOverlayedAffirmations(context, curwish.affirmation.split("|"), true);

                                _affirmation.text=affirmationsStr?.split("|")[0]??"";
                                curwish.affirmation=affirmationsStr??"";
                                appViewModel.isChanged =true;
                                }
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
                                filled: true, // Заливка фона
                                fillColor: curwish.isActive?AppColors.fieldFillColor:AppColors.fieldInactive, // Серый фон с полупрозрачностью
                                hintText: 'Выбери аффирмацию', // Базовый текст
                                helperText: "Выберите аффирмацию или напишите свою",
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                              ),
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
                                    curwish.isChecked?showUnavailable("Чтобы редактировать желание необходимо сменить статус \nна 'не выполнено'"):!curwish.isActive?showUneditable():showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ColorPickerWidget(initColor: _color, onColorSelected: (Color c){setState(() {_color=c;curwish.color=c;appViewModel.isChanged=true;});});
                                      },
                                    );
                                  },
                                )),
                            if(curwish.id > 0)
                              Align(
                                alignment: Alignment.center,
                                child: Column(children: [
                                  const Text("Цели и задачи", style: TextStyle(color: Colors.black54),),
                                  const SizedBox(height: 5),
                                  MyTreeView(key: UniqueKey(),roots: root, onTap: (id, type){
                                    if(type=="m"){
                                      BlocProvider.of<NavigationBloc>(context).clearHistory();
                                      appVM.cachedImages.clear();
                                      appVM.startMainsphereeditScreen();
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToMainSphereEditScreenEvent());
                                    }else if(type=="w"){
                                      curwish=WishData(id: -1, parentId: -1, text: "text", description: "description", affirmation: "affirmation", color: Colors.transparent);
                                      appVM.startWishScreen(id, 0);
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
                                  const SizedBox(height: 5),
                                  if(curwish.id > 899)
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.fieldFillColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10), // <-- Radius
                                          ),
                                        ),
                                        onPressed: (){
                                          if(curwish.isChecked) showUnavailable("Чтобы редактировать желание необходимо сменить статус \nна 'не выполнено'"); else if(!curwish.isActive)showUneditable(); else{
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
                                          }}
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
  void showUnavailable(String text){
    showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.all(10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, maxLines: 5, textAlign: TextAlign.center,),
            const SizedBox(height: 4,),
            const Divider(color: AppColors.dividerGreyColor,),
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
  void showUneditable() {
    showDialog(context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            contentPadding: const EdgeInsets.all(10),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Чтобы редактировать необходимо изменить статус на 'актуальное' нажав кнопку 'осознать'",
                  maxLines: 5, textAlign: TextAlign.center,),
                SizedBox(height: 4,),
                Divider(color: AppColors.dividerGreyColor,),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, 'OK');
                },
                child: const Text('Ok'),
              ),
            ],
          ),
    );
  }
  void showCantChangeStatus(){
    showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.all(10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: const Text("Внимание", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Статус желания не может быть изменен на 'не исполнено' пока вышестоящее желание не будет переведено в статус 'не исполнено'", maxLines: 5, textAlign: TextAlign.center,),
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
