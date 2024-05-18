import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/interface_widgets/outlined_button.dart';
import '../ViewModel.dart';
import '../common/EditTextOverlay.dart';
import '../common/bottombar.dart';
import '../common/treeview_widget_v2.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class TaskEditScreen extends StatefulWidget {

  int aimId = 0;

  TaskEditScreen({super.key, required this.aimId});

  @override
  TaskEditScreenState createState() => TaskEditScreenState();
}

class TaskEditScreenState extends State<TaskEditScreen>{
  List<MyTreeNode> roots = [];
  TaskData? ai;

  final text = TextEditingController();
  final description = TextEditingController();
  var isChanged = false;
  var isParentChecked = false;
  var isParentActive = false;

  bool isTextSetted = false;

  CircleData? parentSphere;

  @override
  Widget build(BuildContext context) {
    text.addListener(() { if(ai?.text!=text.text)isChanged = true;});
    description.addListener(() { if(ai?.text!=text.text)isChanged = true;});
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          if(appVM.currentTask?.id!=ai?.id){
            isTextSetted=false;
            roots.clear();
          }
          ai = appVM.currentTask??TaskData(id: -1, parentId: -1, text: 'объект не найден', description: "", isChecked: false);
          if(appVM.currentAim!=null) {
            AimData ad = appVM.currentAim!;
            parentSphere = ad.id!=-1?appVM.mainScreenState!.allCircles.where((element) => element.id ==ad.parentId).firstOrNull:null;
            isParentChecked = ad.isChecked;
            isParentActive = ad.isActive;
            var childNodes = MyTreeNode(id: ad.id, type: 'a', title: ad.text, isChecked: ad.isChecked, isActive: ad.isActive , children: []);
            if(roots.isEmpty&&ai!=null&&ai?.id!=-1)appVM.convertToMyTreeNodeIncludedAimsTasks(childNodes, ai!.id, ad.parentId);
          }else {
            if(ai!.parentId!=-1)appVM.getAim(ai!.parentId);
          }
          roots=appVM.myNodes;
          if(!isTextSetted&&ai!.id!=-1) {
            text.text = ai!.text;
            description.text = ai!.description;
            isTextSetted=true;
          }
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
                maintainBottomViewPadding: true,
                child: Column(children:[Expanded(child:Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: const ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                              ),
                              icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                              onPressed: () {
                                if(ai!=null&&!ai!.isChecked&&isChanged){
                                  showDialog(context: context,
                                    builder: (BuildContext context) => AlertDialog(
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
                                          onSaveClicked(appVM, ai!);
                                          if(text.text.isNotEmpty) {
                                            BlocProvider.of<NavigationBloc>(context)
                                              .handleBackPress();
                                          }
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
                                  );}else{
                                  BlocProvider.of<NavigationBloc>(context)
                                      .handleBackPress();
                                }
                              },
                            ),
                            Text(ai?.text??"", style: const TextStyle(fontWeight: FontWeight.w600)),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                                style: TextButton.styleFrom(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                                ),
                                onPressed: () async {
                                  showDialog(context: context,
                                    builder: (BuildContext c) => AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                      title: const Text('Внимание', textAlign: TextAlign.center,),
                                      content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Задача будет удалена", maxLines: 4, textAlign: TextAlign.center,),
                                          SizedBox(height: 4,),
                                          Divider(color: AppColors.dividerGreyColor,),
                                          SizedBox(height: 4,),
                                          Text("Удалить?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () { Navigator.pop(context, 'OK');
                                          appVM.deleteTask(ai!.id ,ai!.parentId);
                                          showDialog(context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              title: const Text('Удалена'),
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () { Navigator.pop(context, 'OK');
                                                  BlocProvider.of<NavigationBloc>(context).handleBackPress();},
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          ).then((value) {
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
                                icon: Image.asset("assets/icons/trash.png", width: 28, height: 28),
                            )
                          ],
                        ),
                      ],
                    ),
                    Expanded(child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          ai!=null&&!ai!.isActive&&!ai!.isChecked?ColorRoundedButton("Представить", () {
                              if(isParentActive) {
                                setState(() {
                                  appVM.activateTask(ai!.id, true);
                                  ai!.isActive = true;
                                });
                              }else{
                                showUnavailable(text: "Чтобы актуализировать задачу необходимо актуализировать вышестоящее желание");
                              }
                            },
                          ):const SizedBox(),
                          if(ai!.isActive)OutlinedGradientButton("Выполнена", filledButtonColor: ai!.isChecked?AppColors.greenButtonBack:null, () async {
                            if(isParentChecked) {
                              showCantChangeStatus();
                            } else {
                              if(isChanged) {
                                showDialog(context: context,
                                  builder: (BuildContext context) => AlertDialog(
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
                                        Text("Сохранить изменения перед выполнением задачи?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async { Navigator.pop(context, 'OK');
                                        if(await onSaveClicked(appVM, ai!)) {
                                          appVM.updateTaskStatus(
                                              ai!.id, !ai!.isChecked);
                                        }
                                        },
                                        child: const Text('Да'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context, 'Cancel');
                                          await appVM.updateTaskStatus(
                                              ai!.id, !ai!.isChecked);
                                          await appVM.getTask(ai?.id??0);
                                          text.text=appVM.currentTask!.text;
                                          description.text=appVM.currentTask!.text;
                                        },
                                        child: const Text('Нет'),
                                      ),
                                    ],
                                  ),
                                );

                              }else {
                                appVM.updateTaskStatus(
                                    ai!.id, !ai!.isChecked);
                                showDialog(context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: ai!.isChecked ? const Text(
                                            'выполнена') : const Text(
                                            ' не выполнена'),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius
                                                .all(
                                                Radius.circular(32.0))),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context, 'OK');
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            }
                          }),
                          const SizedBox(height: 16),
                          TextField(
                            onTap: (){
                              if(ai!.isChecked&&!ai!.isActive) showUnavailable(text : "3адача выполнена в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале задач в разделах 'выполненные' и 'все задачи', а также в иерархии цели и желания.\n\nВы можете удалить задачу. Если вам нужна подобная, просто создайте новую задачу.");
                              else if(ai!.isChecked) {showUnavailable();}
                              else if(!ai!.isActive) {showUnavailable(text : "Невозможно изменить неактуализированную задачу");}
                              },
                            controller: text,
                            showCursor: true,
                            readOnly: ai!=null?(ai!.isChecked||!ai!.isActive?true:false):false,
                            style: const TextStyle(color: Colors.black), // Черный текст ввода
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 19),
                              filled: true,
                              suffixIconConstraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 2,
                              ),
                              suffixIcon: const Text("*", style: TextStyle(fontSize: 30, color: AppColors.greytextColor)),
                              fillColor: ai!=null?(ai!.isChecked?AppColors.fieldLockColor:!ai!.isActive?AppColors.fieldLockColor:Colors.white):Colors.white,
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
                            minLines: 4,
                            maxLines: 7,
                            controller: description,
                            onTap: () async {
                              if(ai!.isChecked){
                                if(ai!.isChecked&&!ai!.isActive) showUnavailable(text : "3адача выполнена в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале задач в разделах 'выполненные' и 'все задачи', а также в иерархии цели и желания.\n\nВы можете удалить задачу. Если вам нужна подобная, просто создайте новую задачу.");
                                else if(ai!.isChecked) {showUnavailable();}
                                else if(!ai!.isActive) {showUnavailable(text : "Невозможно изменить неактуализированную задачу");}
                              }
                              else if(!ai!.isActive){showUneditable();}
                              else {
                                final returnedText = await showOverlayedEdittext(context, description.text, (ai!.isActive&&!ai!.isChecked))??"";
                                if(returnedText!=description.text) {
                                  description.text = returnedText;
                                  isChanged = true;
                                }
                              }
                            },
                            showCursor: false,
                            readOnly: true,
                            style: const TextStyle(color: Colors.black), // Черный текст ввода
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 19),
                              suffixIconConstraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 100
                              ),
                              suffixIcon: const Text("*", style: TextStyle(fontSize: 30, color: AppColors.greytextColor)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true, // Заливка фона
                              fillColor: ai!=null?(ai!.isChecked?AppColors.fieldLockColor:!ai!.isActive?AppColors.fieldLockColor:Colors.white):Colors.white,
                              hintText: 'Описание', // Базовый текст
                              hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.grey, height: 2,),
                          const SizedBox(height: 16),
                          appVM.settings.treeView==0?MyTreeView(key: UniqueKey(),roots: roots, onTap: (id,type) => onTreeItemTap(appVM, id, type)):
                          TreeViewWidgetV2(key: UniqueKey(), root: roots.firstOrNull??MyTreeNode(id: -1, type: "a", title: "title", isChecked: true), idToOpen: ai?.id??0, onTap: (id,type) => onTreeItemTap(appVM, id, type),),
                        ],
                      ),
                    ))
                  ]
              ),
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
            ])),
            bottomSheet: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: (){
                      if(parentSphere!=null) {
                        appVM.createMainScreenSpherePath(parentSphere?.id??0, MediaQuery.of(context).size.width);
                        BlocProvider.of<NavigationBloc>(context).clearHistory();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      }
                    },
                    elevation: 0,
                    backgroundColor: parentSphere?.isActive==true?parentSphere?.color:const Color.fromARGB(255, 217, 217, 217),
                    shape: const CircleBorder(),
                    child: Stack(children: [
                      Center(child: Text(parentSphere?.text??"", style: const TextStyle(color: Colors.white),)),
                      if(parentSphere?.isChecked==true)Align(alignment: Alignment.topRight, child: Image.asset('assets/icons/wish_done.png', width: 20, height: 20),)
                    ],),
                  ),
                  const SizedBox(width: 16),
                  ai!=null&&!ai!.isActive&&ai!.isChecked?const SizedBox():Expanded(
                    child: ColorRoundedButton("Сохранить", () => {
                      (!ai!.isChecked)?onSaveClicked(appVM, ai!):showUnavailable()
                    }),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomBar(
              onAimsTap: (){
                appVM.startMyAimsScreen();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToAimsScreenEvent());
              },
              onTasksTap: (){
                appVM.startMyTasksScreen();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToTasksScreenEvent());
              },
              onMapTap: (){
                if(appVM.mainScreenState!=null){
                  appVM.mainCircles.clear();
                  appVM.startMainScreen(appVM.mainScreenState!.moon);
                }
                final pressNum = appVM.getHintStates()["wheelClickNum"]??0;
                if(pressNum>5){
                  appVM.backPressedCount++;
                  if(appVM.backPressedCount==appVM.settings.quoteupdateFreq){
                    appVM.backPressedCount=0;
                    appVM.hint=quoteBack[Random().nextInt(367)];
                  }
                }else{
                  appVM.hint = "Кнопка “карта” возвращает вас на верхний уровень карты “желаний”. Сейчас вы уже здесь!";
                }
                appVM.setHintState("wheelClickNum", (pressNum+1));
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToMainScreenEvent());
              },
              onWishesTap: (){
                appVM.startMyWishesScreen();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToWishesScreenEvent());
              },
              onDiaryTap: (){
                appVM.getDiary();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToDiaryScreenEvent());
              },
            ),
    );
  });
  }

  Future<bool> onSaveClicked(AppViewModel appVM, TaskData ai) async {
    if(text.text.isEmpty){
      await showDialog(context: context,
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
      return false;
    }else{
      ai.text = text.text;
      ai.description = description.text;
    }
    appVM.updateTask(ai);
    setState(() {
      roots.clear();
      isChanged = false;
    });
    showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('сохраненa'),
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
    return true;
  }

  Future<bool> showOnExit(AppViewModel appVM, TaskData ai) async {
    return await showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
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
            onPressed: () async {
              Navigator.pop(context, true);
              await onSaveClicked(appVM, ai);
            },
            child: const Text('Да'),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context, true);
            appVM.isChanged=false;},
            child: const Text('Нет'),
          ),
        ],
      ),
    );
  }

  void showUneditable() {
    showDialog(context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            contentPadding: EdgeInsets.zero,
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

  void showUnavailable({text = "Чтобы редактировать задачу необходимо сменить статус \nна 'не выполнена'"}){
    showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, maxLines: 10, textAlign: TextAlign.center,),
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

  void showCantChangeStatus(){
    showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: const Text("Внимание", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Статус задачи не может быть изменен на 'не выполнена' пока вышестоящая цель не будет переведена в статус 'не достигнута'", maxLines: 5, textAlign: TextAlign.center,),
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
  Future onTreeItemTap(AppViewModel appVM, int id, String type)async {
    if (type == "m") {
      if (isChanged) {
        if (await showOnExit(appVM, ai!) == false) return;
      }
      BlocProvider.of<NavigationBloc>(context).clearHistory();
      appVM.cachedImages.clear();
      appVM.startMainsphereeditScreen();
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToMainSphereEditScreenEvent());
    } else if (type == "w" || type == "s") {
      if (isChanged) {
        if (await showOnExit(appVM, ai!) == false) return;
      }
      BlocProvider.of<NavigationBloc>(context).clearHistory();
      appVM.cachedImages.clear();
      appVM.wishScreenState = null;
      appVM.startWishScreen(id, 0, true);
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToWishScreenEvent());
    } else if (type == "a") {
      if (isChanged) {
        if (await showOnExit(appVM, ai!) == false) return;
      }
      appVM.myNodes.clear();
      appVM.getAim(id);
      BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToAimEditScreenEvent(id));
    } else if (type == "t" && ai!.id != id) {
      if (isChanged) {
        if (await showOnExit(appVM, ai!) == false) return;
      }
      appVM.getTask(id);
      BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToTaskEditScreenEvent(id));
    }
  }
}
