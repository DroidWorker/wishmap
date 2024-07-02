import 'dart:math';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:dotted_border/dotted_border.dart';
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
import '../common/treeview_widget_v2.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../dialog/bottom_sheet_action.dart';
import '../dialog/bottom_sheet_colorpicker.dart';
import '../dialog/bottom_sheet_notify.dart';
import '../interface_widgets/colorButton.dart';
import '../interface_widgets/outlined_button.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class MainSphereEditScreen extends StatefulWidget{

  const MainSphereEditScreen({super.key});

  @override
  _MainSphereEditScreenState createState() => _MainSphereEditScreenState();
}

class _MainSphereEditScreenState extends State<MainSphereEditScreen> with SingleTickerProviderStateMixin{
  Color circleColor = Colors.black12;
  CircleData curWd = CircleData(id: -1, prevId: -1, nextId: -1, text: "", color: Colors.black12, parenId: -1);
  Color? shotColor;

  static const defaultColorList = [Color(0xFF3FA600),Color(0xFFFE0000),Color(0xFFFF006A),Color(0xFFFF5C00),Color(0xFFFEE600),Color(0xFF0029FF),Color(0xFF46C7FE),Color(0xFFFEE600),Color(0xFF0029FF),Color(0xFF009989)];
  var myColors = [];


  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    myColors = appViewModel.getUserColors();
    myColors.add(Colors.transparent);
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
    final ids = curWd.photosIds.split("|")??[];
    if(ids.firstOrNull=="")ids.clear();
    if(appViewModel.cachedImages.length!=ids.length){
      appViewModel.isChanged=true;
    }
    TextEditingController text = TextEditingController(text: curWd.text);
    TextEditingController affirmation = TextEditingController(text: curWd.affirmation.split("|")[0]);
    circleColor = curWd.color;
    text.addListener(() {
      if(text.text!=curWd.text){
          if(appViewModel.isChanged==false){
            appViewModel.isChanged = true;

          }
      }
      curWd.text=text.text;
    });

    return Consumer<AppViewModel>(

        builder: (context, appVM, child){
          shotColor = curWd.color;
          final aims = appVM.aimItems.where((element) => element.parentId==0).toList();
          List<int> aimsids = aims.map((e) => e.id).toList();
          final tasks = appVM.taskItems.where((element) => aimsids.contains(element.parentId)).toList();
          List<MyTreeNode> root = [];
          for (var element in aims) {
            final childTasks = tasks.where((e) => e.parentId==element.id).toList();
            root.add(MyTreeNode(id: element.id, type: 'a', title: element.text, isChecked: element.isChecked, isActive: element.isActive, children: childTasks.map((item) => MyTreeNode(id: item.id, type: 't', title: item.text, isChecked: item.isChecked, isActive: item.isActive)).toList()));
          }
          if(root.isNotEmpty)root = [MyTreeNode(id: 0, type: 'm', title: curWd.text, isChecked: false, children: root)..noClickable=true];
          return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          maintainBottomViewPadding: true,
            child: Column(
              children: [
                Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 10, 0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: const ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                              ),
                              icon: const Icon(Icons.keyboard_arrow_left, size: 32, color: AppColors.gradientStart),
                              onPressed: () {
                                if(appViewModel.isChanged){
                                  showModalBottomSheet<void>(
                                    backgroundColor: AppColors.backgroundColor,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return ActionBS('Внимание', "Вы изменили поля но не нажали 'Сохранить'\nСохранить изменения?", "Да", 'Нет',
                                          onOk: () async { Navigator.pop(context, 'OK');
                                          onSaveClicked(appVM);
                                          },
                                          onCancel: () { Navigator.pop(context, 'Cancel');
                                          appViewModel.mainCircles.clear();
                                          appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                                          BlocProvider.of<NavigationBloc>(context)
                                              .add(NavigateToMainScreenEvent());});
                                    },
                                  );
                                }else{
                                  appViewModel.mainCircles.clear();
                                  appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToMainScreenEvent());
                                }
                                appViewModel.backPressedCount++;
                                if(appViewModel.backPressedCount==appViewModel.settings.quoteupdateFreq){
                                  appViewModel.backPressedCount=0;
                                  appViewModel.hint=quoteBack[Random().nextInt(367)];
                                }
                              }
                          ),
                          Text(curWd.text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(width: 30)
                        ],),
                    ),
                Expanded(
                  child: SingleChildScrollView(
                      child:Padding(padding: const EdgeInsets.all(16), child: Column(
                    children: [
                      if(!curWd.isActive)ColorRoundedButton("Осознать", () async {
                        await appViewModel.activateSphereWish(curWd.id, true);
                        if(appVM.mainScreenState!=null)appViewModel.startMainScreen(appVM.mainScreenState!.moon);
                        curWd.isActive = true;
                        appVM.mainCircles.firstOrNull?.isActive=true;
                      },
                      ),
                const SizedBox(height: 16),
                TextField(
                  controller: text,
                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                  onTap: (){if(!curWd.isActive)showUneditable();},
                  showCursor: true,
                  readOnly: curWd.isActive?false:true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    filled: true,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 2,
                    ),
                    suffixIcon: const Text("*", style: TextStyle(fontSize: 30, color: AppColors.greytextColor)),
                    fillColor: Colors.white,
                    hintText: 'Название',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ),
                ),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: null,
                    controller: affirmation,
                    readOnly: true,
                    showCursor: false,
                    onTap: () async {
                      if(curWd.isActive) {
                        final affirmationsStr = curWd.affirmation==""?
                        await showOverlayedAffirmations(context, defaultAffirmations, false, curWd.shuffle, onShuffleClick: (value){curWd.shuffle=value;}):
                        await showOverlayedAffirmations(context, curWd.affirmation.split("|"), true, curWd.shuffle, onShuffleClick: (value){curWd.shuffle=value;});
                        if(curWd.shuffle) curWd.lastShuffle = "|${DateTime.now().weekday.toString()}";
                        affirmation.text=affirmationsStr?.split("|")[0]??"";
                        curWd.affirmation=affirmationsStr??"";
                        appViewModel.isChanged =true;
                      }else{
                        showUneditable();
                      }
                      },
                    style: const TextStyle(color: Colors.black), // Черный текст ввода
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      suffix: const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.black45),
                      filled: true, // Заливка фона
                      fillColor: !curWd.isActive?AppColors.fieldLockColor:Colors.white,
                      hintText: 'Выбери аффирмацию', // Базовый текст
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                    ),
                  ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.grey, height: 2,),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double fullWidth = constraints.maxWidth-9;
                          double leftWidth = (constraints.maxWidth /2)-9;
                          double rightWidth = constraints.maxWidth - leftWidth - 9;
                          List<List<Uint8List>> imagesSet = [];
                          for (var element in appViewModel.cachedImages) {if(imagesSet.isNotEmpty&&imagesSet.last.length<3){imagesSet.last.add(element);}else{imagesSet.add([element]);}}
                          if(imagesSet.isNotEmpty)imagesSet.removeAt(0);
                          return Column(
                              mainAxisSize: MainAxisSize.min,
                              children:[
                                Row(
                                  children: [
                                    SizedBox(width: leftWidth, height: leftWidth*1.5,
                                      child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                        child: LinearCappedProgressIndicator(
                                          backgroundColor: Colors.black26,
                                          color: Colors.black,
                                          cornerRadius: 0,
                                        ),): appViewModel.cachedImages.isNotEmpty?Image.memory(appViewModel.cachedImages.first, fit: BoxFit.cover):DottedBorder(color: AppColors.darkGrey, dashPattern: const [5, 3], borderType: BorderType.RRect, radius: const Radius.circular(10), child: const Center(child: Icon(Icons.photo_camera_outlined, size: 38, color: AppColors.darkGrey,))),
                                    ),
                                    const SizedBox(width: 9),
                                    Column(children: [
                                      SizedBox(width: rightWidth, height: leftWidth*1.5/2-9,
                                        child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                          child: LinearCappedProgressIndicator(
                                            backgroundColor: Colors.black26,
                                            color: Colors.black,
                                            cornerRadius: 0,
                                          ),): appViewModel.cachedImages.length>1?Image.memory(appViewModel.cachedImages[1], fit: BoxFit.cover):DottedBorder(color: AppColors.darkGrey, dashPattern: const [5, 3], borderType: BorderType.RRect, radius: const Radius.circular(10), child: const Center(child: Icon(Icons.photo_camera_outlined, size: 38, color: AppColors.darkGrey,))),
                                      ),
                                      const SizedBox(height: 9),
                                      SizedBox(width: rightWidth, height: leftWidth*1.5/2-1,
                                        child: appViewModel.isinLoading? const Align(alignment: Alignment.bottomCenter,
                                          child: LinearCappedProgressIndicator(
                                            backgroundColor: Colors.black26,
                                            color: Colors.black,
                                            cornerRadius: 0,
                                          ),): appViewModel.cachedImages.length>2?Image.memory(appViewModel.cachedImages[2], fit: BoxFit.cover):DottedBorder(color: AppColors.darkGrey, dashPattern: const [5, 3], borderType: BorderType.RRect, radius: const Radius.circular(10), child: const Center(child: Icon(Icons.photo_camera_outlined, size: 38, color: AppColors.darkGrey,))),
                                      ),
                                    ],)
                                  ],
                                ),
                                ...imagesSet.map((e) {
                                  Map<Uint8List, int?> em = Map.fromIterable(e, key: (v)=>v, value: (v)=>null);
                                  if(e.length==1) {
                                    return buildSingle(fullWidth, e.first, appVM.isinLoading, !curWd.isActive);
                                  } else if(e.length==2) return buildTwin(leftWidth, rightWidth, em, appVM.isinLoading, !curWd.isActive);
                                  else if(imagesSet.indexOf(e)%2!=0) return buildTriple(leftWidth, rightWidth, em, appVM.isinLoading, !curWd.isActive);
                                  else return buildTripleReverce(leftWidth, rightWidth, em, appVM.isinLoading, !curWd.isActive);
                                }).toList()
                              ]);
                        },
                      ),
                      const SizedBox(height: 24),
                      OutlinedGradientButton(" Добавить фото", (){
                        if(curWd.isActive) {
                          appViewModel.photoUrls.clear();
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToGalleryScreenEvent());
                        }else{
                          showUneditable();
                        }
                      },
                          widgetBeforeText: const Icon(Icons.add_circle_outline_sharp, size: 20,)
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.grey, height: 2,),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.center,
                        child:
                        Column(children: [
                          const Text("Выберите цвет", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                          const SizedBox(height: 10),
                          Container(
                              width: 64.0, // Ширина круга
                              height: 64.0, // Высота круга
                              decoration: BoxDecoration(
                                  border: Border.all(color: shotColor??Colors.white, width: 2),
                                  shape: BoxShape.circle,
                                  color: Colors.white
                              )
                          )
                        ],),
                      ),
                      const SizedBox(height: 24),
                      const Align(alignment: Alignment.centerLeft, child: Text("По умолчанию", style: TextStyle(fontWeight: FontWeight.w500))),
                      const SizedBox(height: 13),
                      SizedBox(
                        height: 40.0,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List.generate(10, (int index) {
                            return Card(
                              color: defaultColorList[index],
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    if(shotColor!=defaultColorList[index])appViewModel.isChanged=true;
                                    shotColor=defaultColorList[index];
                                    curWd.color=defaultColorList[index];
                                  });
                                },
                                child: SizedBox(
                                  width: 34.0,
                                  height: 34.0,
                                  child: shotColor==defaultColorList[index]?const Icon(Icons.check, color: Colors.white, size: 20,):const SizedBox(),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 21),
                      const Align(alignment: Alignment.centerLeft, child: Text("Свой цвет", style: TextStyle(fontWeight: FontWeight.w500))),
                      const SizedBox(height: 13),
                      SizedBox(
                        height: 40.0,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List.generate(myColors.length, (int index) {
                            return myColors[index]!=Colors.transparent?Card(
                              color: myColors[index],
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    if(shotColor!=myColors[index])appViewModel.isChanged=true;
                                    shotColor=myColors[index];
                                    curWd.color=myColors[index];
                                  });
                                },
                                child: SizedBox(
                                  width: 34.0,
                                  height: 34.0,
                                  child: shotColor==myColors[index]?const Icon(Icons.check, color: Colors.white, size: 20,):const SizedBox(),
                                ),
                              ),
                            ):InkWell(
                              onTap: (){
                                final _color = shotColor?.value;
                                !curWd.isActive?showUneditable():showModalBottomSheet(context: context, isScrollControlled: true, builder: (BuildContext context){
                                  return ColorPickerBS(shotColor??Colors.white, (c){
                                    setState(() {
                                      if(_color!=c.value)appViewModel.isChanged=true;
                                      shotColor=c;
                                      curWd.color=c;
                                      appViewModel.saveUserColor(c);
                                    });
                                    Navigator.pop(context);
                                  });
                                });
                              },
                              child: Center(
                                child: Container(
                                  width: 34.0,
                                  height: 34.0,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                                      border: Border.all(color: AppColors.darkGrey)
                                  ),
                                  child: const Icon(Icons.add, color: AppColors.darkGrey, size: 14),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.grey, height: 2,),
                      if(curWd.isActive)OutlinedGradientButton("Добавить цель", (){
                        if(curWd.isActive){BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToAimCreateScreenEvent(0));}else{
                          showUneditable();
                        }
                      },),
                      const SizedBox(height: 8),
                      if(curWd.isActive)OutlinedGradientButton("Добавить сферу", () async {
                        if(appVM.mainScreenState?.allCircles.where((element) => element.parenId==0).toList().length==12){
                          showModalBottomSheet<void>(
                            backgroundColor: AppColors.backgroundColor,
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return NotifyBS('Достигнуто максимальноке количество сфер на орбите. Вы можете скрть или удалить другие сферы, чтобы освободить место для демонстрации данной сферы на орбите', "", 'OK',
                                  onOk: () => Navigator.pop(context, 'OK'));
                            },
                          );
                        }else {
                          final childlastid = appViewModel.mainScreenState?.allCircles.where((element) =>
                          element.parenId == 1 && element.nextId == -1).firstOrNull?.id ?? -1;
                          int wishid = appViewModel.mainScreenState!.allCircles.isNotEmpty ? appViewModel.mainScreenState!.allCircles.map((circle) => circle.id).reduce((value, element) => value > element ? value : element) + 1 : -101;
                          await appViewModel.createNewSphereWish(WishData(id: wishid, prevId: childlastid, nextId: -1, parentId: curWd.id, text: "Новое сфера", description: "", affirmation: (defaultAffirmations.join("|").toString()), color: Colors.red), true).then((value) {
                            BlocProvider.of<NavigationBloc>(context)
                                .clearHistory();
                            appVM.cachedImages.clear();
                            appVM.wishScreenState = null;
                            appViewModel.startWishScreen(wishid, 1, false);
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToWishScreenEvent());
                          }
                          );
                        }
                      },
                      ),
                      const SizedBox(height: 8),
                      if(curWd.isActive)OutlinedGradientButton("Создать общую задачу", () {
                        if(!appVM.isChanged) {
                          BlocProvider.of<NavigationBloc>(context).add(NavigateToTaskCreateScreenEvent(0, isSimple: true, type: 'm'));
                        }else{
                          showModalBottomSheet<void>(
                            backgroundColor: AppColors.backgroundColor,
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return NotifyBS('Необходимо сохранить сферу', "", 'OK',
                                  onOk: () => Navigator.pop(context, 'OK'));
                            },
                          );
                        }
                      },
                      ),
                      const SizedBox(height: 12),
                      Align(
                          alignment: Alignment.center,
                          child: Column(children: [
                            appVM.settings.treeView==0?MyTreeView(key: UniqueKey(),roots: root, onTap: (id, type) => onTreeItemTap(appVM, id, type)):
                            TreeViewWidgetV2(key: UniqueKey(), root: root.firstOrNull??MyTreeNode(id: -1, type: "a", title: "title", isChecked: true), idToOpen: 0, onTap: (id,type) => onTreeItemTap(appVM, id, type),),
                            const SizedBox(height: 16)
                          ])
                      ),
                    ]
                      ))
                  )
                ),
              ],
            ),
            ),
            bottomSheet: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MediaQuery.of(context).viewInsets.bottom!=0? Align(
                    alignment: Alignment.topRight,
                    child: Container(height: 50, width: 50,
                        margin: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ), child:
                        GestureDetector(
                          onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                          child: const Icon(Icons.keyboard_hide_sharp, size: 30, color: AppColors.darkGrey,),
                        )
                    ),
                  ) :Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: (){
                          appViewModel.mainCircles.clear();
                          appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainScreenEvent());
                        },
                        backgroundColor: curWd.isActive?curWd.color:const Color.fromARGB(255, 217, 217, 217),
                        shape: const CircleBorder(),
                        child: const Stack(children: [
                          Center(child: AutoSizeText("Я", textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, ),)),
                        ],),
                      ),
                      const SizedBox(width: 16),
                      curWd.isActive&&appVM.isChanged?Expanded(
                        child: ColorRoundedButton("Сохранить", () async {
                              if(appViewModel.isChanged){
                                onSaveClicked(appVM);
                              }else {
                                await appViewModel.updateSphereWish(WishData(
                                    id: curWd.id,
                                    prevId: curWd.prevId,
                                    nextId: curWd.nextId,
                                    parentId: curWd.parenId,
                                    text: curWd.text,
                                    description: curWd.subText,
                                    affirmation: curWd.affirmation,
                                    color: curWd.color));
                                if (appViewModel.mainScreenState != null) await appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                                appViewModel.hint =
                                "Отлично! Теперь пришло время заполнить все сферы жизни. Ты можешь настроить состав и название сфер так, как считаешь нужным. И помни, что максимальное количество сфер ограничено и равно 1.";
                                appViewModel.isChanged = false;
                                showModalBottomSheet<void>(
                                  backgroundColor: AppColors.backgroundColor,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return NotifyBS('Сохранено', "", 'OK',
                                        onOk: () => Navigator.pop(context, 'OK'));
                                  },
                                );
                              }
                            }),
                      ):const SizedBox(),
                    ],
                  )
                ],
              ),
            ),
    );
        });
  }

  Future<void> onSaveClicked(AppViewModel appViewModel) async {
    if(curWd.text.isEmpty||curWd.affirmation.isEmpty){
      showModalBottomSheet<void>(
        backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return NotifyBS('Необходимо заполнить все поля со знаком *', "", 'OK',
              onOk: () => Navigator.pop(context, 'OK'));
        },
      );
      return;
    }
    await appViewModel.updateSphereWish(WishData(id: curWd.id, prevId: curWd.prevId, nextId: curWd.nextId, parentId: curWd.parenId, text: curWd.text, description: curWd.subText, affirmation: curWd.affirmation, color: curWd.color));
    if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
    appViewModel.hint="Отлично! Теперь пришло время заполнить все сферы жизни. Ты можешь настроить состав и название сфер так, как считаешь нужным. И помни, что максимальное количество сфер ограничено и равно 13.";
    appViewModel.isChanged = false;
    showModalBottomSheet<void>(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NotifyBS('Сохранено', "", 'OK',
            onOk: () {
              Navigator.pop(context, 'OK');
              appViewModel.mainCircles.clear();
              appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
              BlocProvider.of<NavigationBloc>(context)
                  .add(NavigateToMainScreenEvent());
            });
      },
    );
  }

  showOnExit(AppViewModel appVM){
    showModalBottomSheet<void>(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ActionBS('Внимание', "Вы изменили поля но не нажали 'Сохранить'\nСохранить изменения?", "Да", 'Нет',
            onOk: () {
            Navigator.pop(context, 'OK');
            onSaveClicked(appVM);
            },
            onCancel: () { Navigator.pop(context, 'Cancel');
            appVM.isChanged=false;
            });
      },
    );
  }
  void showUneditable(){
    showModalBottomSheet<void>(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NotifyBS("Чтобы редактировать 'Я' необходимо изменить статус на 'актуальное' нажав кнопку 'осознать'", "", 'OK',
            onOk: () => Navigator.pop(context, 'OK'));
      },
    );
  }
   void onTreeItemTap(AppViewModel appVM, int id, String type){
     if(type=="m"){
       if(appVM.isChanged){showOnExit(appVM);}else{
         BlocProvider.of<NavigationBloc>(context).clearHistory();
         appVM.cachedImages.clear();
         appVM.startMainsphereeditScreen();
         BlocProvider.of<NavigationBloc>(context)
             .add(NavigateToMainSphereEditScreenEvent());
       }}else if(type=="w"||type=="s"){
       if(appVM.isChanged){showOnExit(appVM);}else{
         BlocProvider.of<NavigationBloc>(context).clearHistory();
         appVM.startWishScreen(id, 0, true);
         BlocProvider.of<NavigationBloc>(context)
             .add(NavigateToWishScreenEvent());
       }}else if(type=="a"){
       if(appVM.isChanged){showOnExit(appVM);}else{
         appVM.myNodes.clear();
         appVM.getAim(id);
         BlocProvider.of<NavigationBloc>(context)
             .add(NavigateToAimEditScreenEvent(id));
       }}else if(type=="t"){
       if(appVM.isChanged){showOnExit(appVM);}else{
         appVM.getTask(id);
         BlocProvider.of<NavigationBloc>(context)
             .add(NavigateToTaskEditScreenEvent(id));
       }}
   }
}
