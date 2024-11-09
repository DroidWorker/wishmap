import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../ViewModel.dart';
import '../common/EditTextOverlay.dart';
import '../common/animation_overlay.dart';
import '../common/bottombar.dart';
import '../common/customAutoSizeText.dart';
import '../common/gradientText.dart';
import '../common/treeview_widget_v2.dart';
import '../data/models.dart';
import '../data/static.dart';
import '../dialog/bottom_sheet_action.dart';
import '../dialog/bottom_sheet_notify.dart';
import '../interface_widgets/colorButton.dart';
import '../interface_widgets/outlined_button.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AimEditScreen extends StatefulWidget {
  int aimId = 0;

  AimEditScreen({super.key, required this.aimId});
  @override
  AimEditScreenState createState() => AimEditScreenState();
}

class AimEditScreenState extends State<AimEditScreen>{

  List<MyTreeNode> roots = [];
  final text = TextEditingController();
  final description = TextEditingController();
  AimData? ai;
  var isChanged = false;
  var isParentChecked = false;
  var isParentActive = false;

  ScrollController _scrollController = ScrollController();
  final GlobalKey _keyToScroll = GlobalKey();
  late GlobalKey _treeViewKey;
  int prevHiddenTreeElements = 0;

  bool isTextSetted = false;

  bool HEADERSIMPLETASKHEADER = false;

  AnimationController? lottieController;

  @override
  void initState(){
    super.initState();
    _scrollController.addListener(() {
      MyTreeViewState? treeViewState = _treeViewKey.currentState as MyTreeViewState;

      RenderBox? renderBox = _keyToScroll.currentContext?.findRenderObject() as RenderBox?;
      Offset? widgetOffset = renderBox?.localToGlobal(Offset.zero);

      if(widgetOffset?.dy!=null&&widgetOffset!.dy<300){
        if(prevHiddenTreeElements!=(prevHiddenTreeElements=(widgetOffset.dy-300) * -1 ~/ 20)) {
          treeViewState.changePadding(prevHiddenTreeElements);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _treeViewKey = GlobalKey();
    text.addListener(() { if(ai?.text!=text.text&&!isChanged) {
      setState(() {
        isChanged = true;
      });
    }});
    description.addListener(() { if(ai?.description!=description.text)isChanged = true;});
    ///return true if lines count > maxLines
    bool _checkLines(int maxlines){
      final TextSpan textSpan = TextSpan(text: description.text);
      final TextPainter textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr
      );
      textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 64);
      final int lines = textPainter.computeLineMetrics().length;
      if(lines>maxlines){
        return true;
      }
      return false;
    }

    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          if(ai==null||ai!.id==-1)ai = appVM.currentAim??AimData(id: -1, parentId: -1, text: 'объект не найден', description: "", isChecked: false);
          if(ai!.text.contains("HEADERSIMPLETASKHEADER")) {
            ai!.text = ai!.text.replaceAll("HEADERSIMPLETASKHEADER", "");
            HEADERSIMPLETASKHEADER = true;
          }
          if(roots.isEmpty&&ai!=null&&ai!.id!=-1)appVM.convertToMyTreeNode(CircleData(id: ai!.id, prevId: -1, nextId: -1, text: ai!.text, color: Colors.transparent, parenId: ai!.parentId, isChecked: ai!.isChecked, isActive: ai!.isActive));
          roots = appVM.myNodes;
          final parentObj = ai!.id!=-1?appVM.mainScreenState!.allCircles.where((element) => element.id ==ai!.parentId).firstOrNull:null;
          isParentChecked = parentObj?.isChecked??false;
          isParentActive = parentObj?.isActive??false;
          if(!isTextSetted&&ai!.id!=-1){
            text.text = ai?.text??"Загрузка...";
            description.text = ai?.description??"";
            isTextSetted=true;
          }

          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (appVM.needAutoScrollBottom) {
              final RenderObject? renderObject = _keyToScroll.currentContext?.findRenderObject();
              if (renderObject != null) {
                final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
                final double dy = viewport.getOffsetToReveal(renderObject, 0.0).offset;
                _scrollController.animateTo(
                  dy,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              }
              if(roots.isNotEmpty)appVM.needAutoScrollBottom=false;
            }
          });

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
                maintainBottomViewPadding: true,
                child:   Column(children:[ Expanded(child:Padding(
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
                                  showModalBottomSheet<void>(
                                    backgroundColor: AppColors.backgroundColor,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return ActionBS('Внимание', "Вы изменили поля но не нажали 'Сохранить'\nСохранить изменения?", "Да", 'Нет',
                                          onOk: () async {
                                            Navigator.pop(context, 'OK');
                                            onSaveClick(appVM);
                                            if(text.text.isNotEmpty&&description.text.isNotEmpty) {
                                              BlocProvider.of<NavigationBloc>(context)
                                                .handleBackPress();
                                            }
                                          },
                                          onCancel: () { Navigator.pop(context, 'Cancel');
                                          BlocProvider.of<NavigationBloc>(context)
                                              .handleBackPress();
                                          });
                                    },
                                  );
                                }else{
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
                                  showModalBottomSheet<void>(
                                    backgroundColor: AppColors.backgroundColor,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return ActionBS('Внимание', ai!.childTasks.isNotEmpty?"Если в данной цели создавались задачи, то они также будут удалены":"Цель будет удалена", "Да", 'Нет',
                                          onOk: () async { Navigator.pop(context, 'OK');
                                          appVM.deleteAim(widget.aimId, ai!.parentId);
                                          BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                          showModalBottomSheet<void>(
                                            backgroundColor: AppColors.backgroundColor,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return NotifyBS('Удалено', "", 'OK',
                                                  onOk: () => Navigator.pop(context, 'OK'));
                                            },
                                          );
                                          },
                                          onCancel: () { Navigator.pop(context, 'Cancel');}
                                      );
                                    },
                                  );
                                },
                                icon: SvgPicture.asset("assets/icons/trash.svg", width: 28, height: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(child:SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(children:[
                        const SizedBox(height: 16),
                        /*ai!=null&&!ai!.isActive&&!ai!.isChecked?ColorRoundedButton("Представить", () {
                          if(appVM.settings.actualizeFullBranch){
                            appVM.activateBranchFrom(ai!.id, "a");
                            setState(() {
                              ai!.isActive = true;
                            });
                            return;
                          }
                            if(isParentActive) {
                              setState(() {
                                appVM.activateAim(ai!.id, true);
                                ai!.isActive = true;
                              });
                            }else{
                              showUneditable(text: "Чтобы актуализировать цели и задачи необходимо актуализировать вышестоящее желание нажав кнопку 'воплотить'");
                            }
                          }
                        ):const SizedBox(),*/
                        if(ai!.isActive&&!HEADERSIMPLETASKHEADER)OutlinedGradientButton("Достигнуто", filledButtonColor: ai!.isChecked?AppColors.greenButtonBack:null, () async {
                          if(ai!=null){
                            if(isParentChecked) {
                              showCantChangeStatus();
                            } else {
                              if(isChanged) {
                                showModalBottomSheet<void>(
                                  backgroundColor: AppColors.backgroundColor,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return ActionBS('Внимание', "Вы изменили поля но не нажали 'Сохранить'\nСохранить изменения перед достижением цели?", "Да", 'Нет',
                                        onOk: () async { Navigator.pop(context, 'OK');
                                        onSaveClick(appVM);
                                        if (ai!.childTasks.isNotEmpty) {
                                          showModalBottomSheet<void>(
                                            backgroundColor: AppColors.backgroundColor,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return ActionBS('Внимание', (!ai!.isChecked)?"Если в данной цели создавались задачи, то они также получат статус 'выполнена'. Достигнута?":"Если в данной цели создавались другие задачи, то они останутся в статусе 'выполнена'. Не Достигнута?", "Да", 'Нет',
                                                  onOk: () {
                                                    Navigator.pop(
                                                        context, 'OK');
                                                    ai!.isChecked = !ai!.isChecked;
                                                    if(ai!.isChecked&&appVM.settings.animationEnabled)showOverlayedAnimations(context, 'assets/lottie/dostizhenieceli.json', fillBackground: true, onControllerCreated: (controller){lottieController = controller;});
                                                    appVM.updateAimStatus(ai!.id, ai!.isChecked);
                                                    showModalBottomSheet<void>(
                                                      backgroundColor: AppColors.backgroundColor,
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (BuildContext context) {
                                                        return NotifyBS(ai!.isChecked?'Достигнута':'не Достигнута', "", 'OK',
                                                            onOk: (){
                                                          Navigator.pop(context, 'OK');
                                                          try {
                                                            lottieController?.reset();
                                                            lottieController=null;
                                                          } catch (ex){}
                                                            });
                                                      },
                                                    );
                                                  },
                                                  onCancel: () {
                                                    Navigator.pop(
                                                        context, 'Cancel');
                                                  });
                                            },
                                          );
                                        }else {
                                          ai!.isChecked = !ai!.isChecked;
                                          if(ai!.isChecked&&appVM.settings.animationEnabled)showOverlayedAnimations(context, 'assets/lottie/dostizhenieceli.json', fillBackground: true, onControllerCreated: (controller){lottieController = controller;});
                                          appVM.updateAimStatus(ai!.id, ai!.isChecked);
                                        }
                                        },
                                        onCancel: () async {
                                          Navigator.pop(context, 'Cancel');
                                          if (ai!.childTasks.isNotEmpty) {
                                            showModalBottomSheet<void>(
                                              backgroundColor: AppColors.backgroundColor,
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (BuildContext context) {
                                                return ActionBS('Внимание', (!ai!.isChecked)?"Если в данной цели создавались задачи, то они также получат статус 'выполнена'":"Если в данной цели создавались другие задачи, то они останутся в статусе 'выполнена'", "Да", 'Нет',
                                                    onOk: () async {
                                                      Navigator.pop(
                                                          context, 'OK');
                                                      ai!.isChecked = !ai!
                                                          .isChecked;
                                                      if(ai!.isChecked&&appVM.settings.animationEnabled)showOverlayedAnimations(context, 'assets/lottie/dostizhenieceli.json', fillBackground: true, onControllerCreated: (controller){lottieController = controller;});
                                                      await appVM.updateAimStatus(
                                                          ai!.id, ai!.isChecked);
                                                      await appVM.getAim(ai!.id);
                                                      text.text =
                                                          appVM.currentAim!.text;
                                                      description.text =
                                                          appVM.currentAim!
                                                              .description;
                                                      isChanged = false;
                                                      showModalBottomSheet<void>(
                                                        backgroundColor: AppColors.backgroundColor,
                                                        context: context,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context) {
                                                          return NotifyBS((ai!.isChecked)?'Достигнута':'не Достигнута', "", 'OK',
                                                              onOk: () {
                                                                try {
                                                                  lottieController?.reset();
                                                                  lottieController=null;
                                                                } catch (ex){}
                                                                Navigator.pop(context, 'OK');
                                                          });
                                                        },
                                                      );
                                                    },
                                                    onCancel: () { Navigator.pop(context, 'Cancel');
                                                    });
                                              },
                                            );
                                          }else {
                                            ai!.isChecked = !ai!
                                                .isChecked;
                                            if(ai!.isChecked&&appVM.settings.animationEnabled==true)showOverlayedAnimations(context, 'assets/lottie/dostizhenieceli.json', fillBackground: true, onControllerCreated: (controller){lottieController = controller;});
                                            await appVM.updateAimStatus(
                                                ai!.id, ai!.isChecked);
                                            await appVM.getAim(ai!.id);
                                            text.text =
                                                appVM.currentAim!.text;
                                            description.text =
                                                appVM.currentAim!
                                                    .description;
                                            isChanged = false;
                                          }
                                        });
                                  },
                                );
                              }else {
                                if (ai!.childTasks.isNotEmpty) {
                                  showModalBottomSheet<void>(
                                    backgroundColor: AppColors.backgroundColor,
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                    return ActionBS('Внимание', (!ai!.isChecked)?"Если в данной цели создавались задачи, то они также получат статус 'выполнена'":"Если в данной цели создавались другие задачи, то они останутся в статусе 'выполнена'", "Да", 'Нет',
                                        onOk: () {
                                          Navigator.pop(
                                              context, 'OK');
                                          ai!.isChecked = !ai!
                                              .isChecked;
                                          if(ai!.isChecked&&appVM.settings.animationEnabled)showOverlayedAnimations(context, 'assets/lottie/dostizhenieceli.json', fillBackground: true, onControllerCreated: (controller){lottieController = controller;});
                                          appVM.updateAimStatus(
                                              ai!.id,
                                              ai!.isChecked);
                                          showModalBottomSheet<void>(
                                            backgroundColor: AppColors.backgroundColor,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return NotifyBS(ai!.isChecked?'Достигнута':'не Достигнута', "", 'OK',
                                                  onOk: (){
                                                    try {
                                                      lottieController?.reset();
                                                      lottieController=null;
                                                    } catch (ex){}
                                                    Navigator.pop(context, 'OK');
                                              });
                                            },
                                          );
                                        },
                                        onCancel: () { Navigator.pop(context, 'Cancel');
                                        });
                                  },
                                  );
                                } else {
                                  ai!.isChecked = !ai!
                                      .isChecked;
                                  if(ai!.isChecked&&appVM.settings.animationEnabled)showOverlayedAnimations(context, 'assets/lottie/dostizhenieceli.json', fillBackground: true, onControllerCreated: (controller){lottieController = controller;});
                                  appVM.updateAimStatus(
                                      ai!.id, ai!.isChecked);
                                  showModalBottomSheet<void>(
                                    backgroundColor: AppColors.backgroundColor,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return NotifyBS(ai!.isChecked?'Достигнута':'не Достигнута', "", 'OK',
                                          onOk: () {
                                            try {
                                              lottieController?.reset();
                                              lottieController=null;
                                            } catch (ex){}
                                            Navigator.pop(context, 'OK');
                                      });
                                    },
                                  );
                                }
                              }
                            }
                          }
                        }),
                        const SizedBox(height: 16),
                        Stack(children: [
                          Column(children: [
                            TextField(
                              onTap: (){
                                if(HEADERSIMPLETASKHEADER) return;
                                if(ai!.isChecked&&!ai!.isActive) {showUneditable(text: "3адача выполнена в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале задач в разделах 'выполненные' и 'все задачи', а также в иерархии цели и желания.\n\nВы можете удалить задачу. Если вам нужна подобная, просто создайте новую задачу.");}
                                else if(ai!.isChecked) {showUneditable(text: "Чтобы редактировать цель необходимо сменить статус \nна 'не выполнена'");}
                                else if(!ai!.isActive) {showUneditable(text: "Невозможно изменить неактуализированную задачу");}
                              },
                              controller: text,
                              showCursor: true,
                              readOnly: ai!=null?(ai!.isChecked||!ai!.isActive||HEADERSIMPLETASKHEADER?true:false):false,
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
                              maxLength: 260,
                              minLines: 1,
                              maxLines: 5,
                              controller: description,
                              showCursor: false,
                              readOnly: true,
                              onTap: () async {
                                if(ai!.isChecked){
                                  if(ai!.isChecked&&!ai!.isActive) {showUneditable(text: "3адача выполнена в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале задач в разделах 'выполненные' и 'все задачи', а также в иерархии цели и желания.\n\nВы можете удалить задачу. Если вам нужна подобная, просто создайте новую задачу.");}
                                  else if(ai!.isChecked) {showUneditable(text: "Чтобы редактировать цель необходимо сменить статус \nна 'не выполнена'");}
                                  else if(!ai!.isActive) {showUneditable(text: "Невозможно изменить неактуализированную задачу");}
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
                              style: const TextStyle(color: Colors.black), // Черный текст ввода
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                border:  OutlineInputBorder(
                                  borderRadius: _checkLines(5)?const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)):BorderRadius.all(Radius.circular(10)),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                counterText: "",
                                filled: true, // Заливка фона
                                fillColor: ai!=null?(ai!.isChecked?AppColors.fieldLockColor:!ai!.isActive?AppColors.fieldLockColor:Colors.white):Colors.white,
                                hintText: 'Описание', // Базовый текст
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                              ),
                            ),
                            if(_checkLines(5))Container(
                              height: 40,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                    border: Border(
                                      top: BorderSide(width: 1.0, color: AppColors.grey),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      if(ai!.isChecked){
                                        if(ai!.isChecked&&!ai!.isActive) {showUneditable(text: "3адача выполнена в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале задач в разделах 'выполненные' и 'все задачи', а также в иерархии цели и желания.\n\nВы можете удалить задачу. Если вам нужна подобная, просто создайте новую задачу.");}
                                        else if(ai!.isChecked) {showUneditable(text: "Чтобы редактировать цель необходимо сменить статус \nна 'не выполнена'");}
                                        else if(!ai!.isActive) {showUneditable(text: "Невозможно изменить неактуализированную задачу");}
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
                                    child: const Row(
                                      children: [
                                        GradientText("Показать все", gradient: LinearGradient(
                                            colors: [AppColors.gradientStart, AppColors.gradientEnd]
                                        ),
                                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),),
                                        Spacer(),
                                        Icon(Icons.arrow_forward_ios, color: AppColors.gradientEnd, size: 18,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: AppColors.grey, height: 2,),
                            const SizedBox(height: 16),
                            if(!ai!.isActive&&ai!.isChecked)const SizedBox() else OutlinedGradientButton(
                              "Создать задачу",
                                  () {
                                if(ai!=null){
                                  if(!ai!.isActive){
                                    showUneditable(text: "Чтобы создать задачу необходимо сменить статус на 'aктуальная'");
                                    return;
                                  }
                                  else if(ai!.isChecked){
                                    showUneditable(text: "Чтобы создать задачу необходимо сменить статус на 'не достигнута'");
                                    return;
                                  }

                                  HEADERSIMPLETASKHEADER?BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToTaskCreateScreenEvent(ai!.parentId, isSimple: true, type: "w")):BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToTaskCreateScreenEvent(ai!.id));
                                }
                              },
                              widgetBeforeText: const Icon(Icons.add_circle_outline_rounded),
                            ),
                          ],),
                          if(ai?.isActive==false||ai?.isChecked==true||HEADERSIMPLETASKHEADER)Positioned.fill(
                              child: Container(
                                color: AppColors.backgroundColor.withOpacity(0.8),
                              )
                          )
                        ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(key: _keyToScroll, height: 15,),
                        appVM.settings.treeView==0?MyTreeView(key: _treeViewKey = GlobalKey(),roots: roots, colors: appVM.nodesColors, currentId: ai?.id, onTap: (id, type) => onTreeItemTap(appVM, id, type)):
                        TreeViewWidgetV2(key: UniqueKey(), root: roots.firstOrNull??MyTreeNode(id: -1, type: "a", title: "title", isChecked: true), idToOpen: ai?.id??0, onTap: (id,type) => onTreeItemTap(appVM, id, type),),
                        const SizedBox(height: 50,)
                      ]),
                    ))
                  ]
              ),
            )),
                      ])
            ),
            bottomSheet: Padding(
              padding: const EdgeInsets.all(16.0),
                  child: MediaQuery.of(context).viewInsets.bottom!=0? Row(
                    children: [
                      ai!=null&&(!ai!.isActive&&ai!.isChecked||!isChanged)?const Spacer():Expanded(
                        child: ColorRoundedButton("Сохранить", () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if(ai!=null&&!ai!.isChecked) {
                            onSaveClick(appVM);
                          } else{
                            showUneditable(text: "Невозможно сохранить цель в статусе 'достигнута'");
                          }
                        }),
                      ),
                      Container(height: 50, width: 50,
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
                    ],
                  ):Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if(!HEADERSIMPLETASKHEADER)FloatingActionButton(
                    onPressed: (){
                      if(ai!=null) {
                        appVM.createMainScreenSpherePath(ai!.parentId, MediaQuery.of(context).size.width);
                        BlocProvider.of<NavigationBloc>(context).clearHistory();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      }
                    },
                    backgroundColor: parentObj?.isActive==true?parentObj?.color:const Color.fromARGB(255, 217, 217, 217),
                    shape: const CircleBorder(),
                    child: Stack(children: [
                      Center(child: WordWrapWidget(text: parentObj?.text??"", minTextSize: 4, maxTextSize: 12, style: const TextStyle(fontSize: 13,color: Colors.white))),
                      if(parentObj?.isChecked==true)Align(alignment: Alignment.topRight, child: Image.asset('assets/icons/wish_done.png', width: 20, height: 20),)
                    ],),
                  ),
                  const SizedBox(width: 16),
                  ai!=null&&(!ai!.isActive&&ai!.isChecked||!isChanged)?const SizedBox():Expanded(
                    child: ColorRoundedButton("Сохранить", () {
                      if(ai!=null&&!ai!.isChecked) {
                        onSaveClick(appVM);
                      } else{
                        showUneditable(text: "Невозможно сохранить цель в статусе 'достигнута'");
                      }
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

  Future<bool> onSaveClick(AppViewModel appVM) async {
    if(ai!=null){
      if(text.text.isEmpty){
        await showModalBottomSheet<void>(
          backgroundColor: AppColors.backgroundColor,
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return NotifyBS('Заполните поля', "", 'OK',
                onOk: () => Navigator.pop(context, 'OK'));
          },
        );
        return false;
      }else{
        ai!.text = text.text;
        ai!.description = description.text;
      }
      if(HEADERSIMPLETASKHEADER)ai!.text = "HEADERSIMPLETASKHEADER${ai!.text}";
      appVM.updateAim(ai!);
      setState(() {
        roots.clear();
        appVM.aimItems[appVM.aimItems.indexWhere((element) => element.id==ai!.id)]=AimItem(id: ai!.id, parentId: ai!.parentId, text: ai!.text, isChecked: ai!.isChecked, isActive: ai!.isActive);
        isChanged = false;
      });
      showModalBottomSheet<void>(
        backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return NotifyBS('сохраненa', "", 'OK',
              onOk: () => Navigator.pop(context, 'OK'));
        },
      );
    }
    return true;
  }
  Future<bool?> showOnExit(AppViewModel appVM) async {
    return await showModalBottomSheet<bool>(
      backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return ActionBS('Внимание', "Вы изменили поля но не нажали 'Сохранить'\nСохранить изменения?", "Да", 'Нет',
              onOk: () async {
                Navigator.pop(context, true);
                await onSaveClick(appVM);
              },
              onCancel: () { Navigator.pop(context, true);
              appVM.isChanged=false;}
          );
        },
    );
  }

  void showUneditable({String text = "Чтобы редактировать необходимо изменить статус на 'актуальное' нажав кнопку 'осознать'"}) {
    showModalBottomSheet<void>(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NotifyBS('', text, 'OK',
            onOk: () => Navigator.pop(context, 'OK'));
      },
    );
  }
  void showCantChangeStatus(){
    showModalBottomSheet<void>(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NotifyBS('Внимание', "Статус цели не может быть изменен на 'не достигнута' пока вышестоящее желание не будет переведено в статус 'не исполнено'", 'OK',
            onOk: () => Navigator.pop(context, 'OK'));
      },
    );
  }
  Future onTreeItemTap(AppViewModel appVM, int id, String type)async {
    if(type=="m"){
      if(isChanged){if(await showOnExit(appVM)==false) return;}
      BlocProvider.of<NavigationBloc>(context).clearHistory();
      appVM.cachedImages.clear();
      appVM.startMainsphereeditScreen();
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToMainSphereEditScreenEvent());
    }else if(type=="w"||type=="s"){
      if(isChanged){if(await showOnExit(appVM)==false) return;}
      BlocProvider.of<NavigationBloc>(context).clearHistory();
      appVM.wishScreenState = null;
      appVM.startWishScreen(id, 0, true);
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToWishScreenEvent());
    }else if(type=="a"&&widget.aimId!=id){
      if(isChanged){if(await showOnExit(appVM)==false) return;}
      appVM.getAim(id);
      appVM.myNodes.clear();
      BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToAimEditScreenEvent(id));
    }else if(type=="t"){
      if(isChanged){if(await showOnExit(appVM)==false) return;}
      appVM.getTask(id);
      appVM.myNodes.clear();
      BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToTaskEditScreenEvent(id));
    }
  }
}
