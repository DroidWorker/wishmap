import 'dart:math';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:collection/collection.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/animation_overlay.dart';
import 'package:wishmap/common/gradientText.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/dialog/bottom_sheet_colorpicker.dart';

import '../ViewModel.dart';
import '../common/EditTextOverlay.dart';
import '../common/affirmationOverlay.dart';
import '../common/bottombar.dart';
import '../common/collage.dart';
import '../common/customAutoSizeText.dart';
import '../common/treeview_widget.dart';
import '../common/treeview_widget_v2.dart';
import '../data/static.dart';
import '../data/static_affirmations_women.dart';
import '../dialog/bottom_sheet_action.dart';
import '../dialog/bottom_sheet_notify.dart';
import '../interface_widgets/colorButton.dart';
import '../interface_widgets/outlined_button.dart';
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

  static const defaultColorList = [Color(0xFF3FA600),Color(0xFFFE0000),Color(0xFFFF006A),Color(0xFFFF5C00),Color(0xFFFEE600),Color(0xFF0029FF),Color(0xFF46C7FE),Color(0xFFFEE600),Color(0xFF0029FF),Color(0xFF009989)];
  var myColors = [];

  bool isDataLoaded = false;
  ScrollController _scrollController = ScrollController();
  final GlobalKey _keyToScroll = GlobalKey();
  late GlobalKey _treeViewKey;

  TaskItem? wishTasks;
  AimItem? wishAims;

  final List<MyTreeNode> root = [];

  bool isParentChecked = false;
  bool isParentHidden = false;
  bool isParentActive = false;
  bool parentIsSphere = false;

  WishData curwish = WishData(id: -1, prevId: -1, nextId: -1, parentId: -1, text: "", description: "", affirmation: "", color: Colors.grey);

  final descriptionText = "Синтез желаний самое невероятное чудо, которое есть в руках человека.Это буквально сила нашего сознания, сила самой вселенной, сила Бога, если хотите.\n\nИ может потому нас посещают страхи, что желания наши не исполнятся, что сила, которая связана с этим явлением соль великая и мощная, что управлять ей мы не всегда умеем.";

  int prevHiddenTreeElements = 0;

  AnimationController? lottieController;

  @override
  initState(){
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
    final appViewModel = Provider.of<AppViewModel>(context);
    TextEditingController _title = TextEditingController(text: curwish.text.replaceAll("HEADERSIMPLETASKHEADER", ""));
    TextEditingController _description = TextEditingController(text: curwish.description);
    TextEditingController _affirmation = TextEditingController(text: curwish.affirmation.split("|")[0]);
    _title.addListener(() { if(_title.text!=appViewModel.wishScreenState!.wish.text&&!_title.text.contains("HEADERSIMPLETASKHEADER")&&!appViewModel.isChanged) {
        setState(() {
          appViewModel.isChanged = true;
          curwish.text = _title.text;
        });
      }
    });
   _description.addListener(() { if(_description.text!=appViewModel.wishScreenState!.wish.description)appViewModel.isChanged = true;curwish.description=_description.text;});
    _affirmation.addListener(() { });
    myColors = appViewModel.getUserColors();
    myColors.add(Colors.transparent);

    ///return true if lines count > maxLines
    bool _checkLines(int maxlines){
      final TextSpan textSpan = TextSpan(text: _description.text);
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr
      );
      textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 64);
      final int lines = textPainter.computeLineMetrics().length;
      textPainter.computeLineMetrics().forEach((e){
        print(e.lineNumber);
      });
      if(lines>maxlines){
        return true;
      }
      return false;
    }

    return  Consumer<AppViewModel>(
        builder: (context, appVM, child){
          if(appVM.wishScreenState!=null&&curwish.id==-1) {
            curwish = appVM.wishScreenState!.wish;
            _title.text = appVM.wishScreenState!.wish.text;
            _description.text = appVM.wishScreenState!.wish.description;
            _affirmation.text = appVM.wishScreenState!.wish.affirmation;
            _color = appVM.wishScreenState!.wish.color;
            isDataLoaded = appVM.wishScreenState!.isDataloaded;
            appVM.convertToMyTreeNodeFullBranch(curwish.id);
            final parentObj = appVM.mainScreenState!.allCircles.where((element) => element.id==curwish.parentId).firstOrNull;
            isParentChecked = parentObj?.isChecked??true;
            isParentActive = parentObj?.isActive??false;
            isParentHidden = parentObj?.isHidden??true;
            parentIsSphere = parentObj!=null?(parentObj.parenId<=0?true:false):false;
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
          final ids = appVM.wishScreenState?.wish.photoIds.split("|")??[];
          if(ids.firstOrNull=="")ids.clear();
          //if(appViewModel.cachedImages.length!=ids.length){
            //appViewModel.isChanged=true;
          //}
          root.clear();
          root.addAll(appVM.myNodes);

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
              if(root.isNotEmpty)appVM.needAutoScrollBottom=false;
            }
          });

          return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: SafeArea(
                  maintainBottomViewPadding: true,
                  child:Column(children:[
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
                                if(curwish.isHidden){
                                  appVM.mainCircles.clear();
                                  appViewModel.startMainScreen(appVM.mainScreenState!.moon);
                                  BlocProvider.of<NavigationBloc>(context).add(NavigateToMainScreenEvent());
                                }
                                if(!curwish.isChecked&&appViewModel.isChanged){
                                  showModalBottomSheet<void>(
                                    backgroundColor: AppColors.backgroundColor,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return ActionBS('Внимание', "Вы изменили поля но не нажали 'Сохранить'\nСохранить изменения?", "Да", 'Нет',
                                          onOk: () async { Navigator.pop(context, 'OK');
                                          onSaveClicked(appVM, true, _title, _description, _affirmation);
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
                                appViewModel.backPressedCount++;
                                if(appViewModel.backPressedCount==appViewModel.settings.quoteupdateFreq){
                                  appViewModel.backPressedCount=0;
                                  appViewModel.hint=quoteBack[Random().nextInt(367)];
                                }
                              }
                          ),
                          Text(curwish.text.replaceAll("HEADERSIMPLETASKHEADER", ""), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                                    return ActionBS('Внимание', (curwish.childAims.isEmpty&&!appVM.hasChildWishes(curwish.id))?"Объект будет удален":(curwish.parentId > 1)?"Если в данном желании создавались желания, цели и задачи, то они также будут удалены":
                                    "Если в данной сфере\n создавались желания,\n цели и задачи, то они\n также будут удалены", "Да", 'Нет',
                                        onOk: () {
                                        Navigator.pop(context, 'OK');
                                        appViewModel.deleteSphereWish(appVM.wishScreenState!.wish.id, curwish.prevId, curwish.nextId);
                                        showModalBottomSheet<void>(
                                          backgroundColor: AppColors.backgroundColor,
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return NotifyBS('Удалено', "", 'OK',
                                                onOk: () { Navigator.pop(context, 'OK');}
                                            );
                                          },
                                        );
                                        var moon = appVM.mainScreenState!.moon;
                                        appViewModel.mainScreenState = null;
                                        appViewModel.mainCircles.clear();
                                        appViewModel.startMainScreen(moon);
                                        BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                        },
                                        onCancel: () { Navigator.pop(context, 'Cancel');});
                                  },
                                );
                              },
                            icon: SvgPicture.asset("assets/icons/trash.svg", width: 28, height: 28),
                          )
                      ],),
                    ),
                    Expanded(child:SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            !curwish.isActive&&!curwish.isChecked?ColorRoundedButton("Представить", () {
                              if(appVM.settings.actualizeFullBranch){
                                appVM.activateBranchFrom(curwish.id, 'w');
                                setState(() {
                                  appViewModel.mainCircles.where((element) => element.id == curwish.id).firstOrNull?.isActive = true;
                                  curwish.isActive = true;
                                });
                                return;
                              }
                              if(isParentActive||appVM.settings.wishActualizingMode==1||parentIsSphere) {
                                if(appVM.settings.sphereActualizingMode==1||appVM.isParentSphereActive(curwish.id)||curwish.parentId==0){
                                  appViewModel.activateSphereWish(curwish.id, true);
                                  setState(() {
                                    appViewModel.mainCircles.where((element) =>
                                    element.id == curwish.id).firstOrNull?.isActive = true;
                                    curwish.isActive = true;
                                  });
                                  if(curwish.parentId==0) {
                                    if(appVM.settings.animationEnabled)showOverlayedAnimations(context, 'assets/lottie/aktualizaciyasfery.json', fillBackground: true);
                                  } else {
                                    if(appVM.settings.animationEnabled)showOverlayedAnimations(context, 'assets/lottie/aktualizaciyazhelaniya.json', fillBackground: true);
                                  }
                                } else{
                                  showUnavailable("Чтобы представить это желание необходимо сначала представить вышестоящиую сферу");
                                }
                              } else{
                                showUnavailable("Чтобы представить это желание необходимо сначала представить вышестоящий объект");
                              }
                            },
                            ):const SizedBox(),
                            if(curwish.parentId > 1&&curwish.isActive&&!curwish.text.contains("HEADERSIMPLETASKHEADER"))Row(children: [
                              Expanded(
                                child: OutlinedGradientButton("Исполнено", filledButtonColor: curwish.isChecked?AppColors.greenButtonBack:null, () async {
                                  if(isParentChecked) {
                                    showCantChangeStatus();
                                  } else if(curwish.isHidden){
                                    showUnavailable("Чтобы изменить статус 'исполнено' необходимо отменить статус 'скрыто'");
                                  } else {
                                    if(appVM.isChanged) {
                                      showModalBottomSheet<void>(
                                        backgroundColor: AppColors.backgroundColor,
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext mcontext) {
                                          return ActionBS('Внимание', "Вы изменили поля но не нажали 'Сохранить'\nСохранить изменения?", "Да", 'Нет',
                                              onOk: () async { Navigator.pop(context, 'OK');
                                              final result = await onSaveClicked(appVM, false, _title, _description, _affirmation);
                                              if(result){
                                                changeStatus(appVM);
                                              }
                                              },
                                              onCancel: () async {
                                                Navigator.pop(mcontext, 'Cancel');
                                                final wishid = curwish.id;
                                                curwish=WishData(id: -1, prevId: -1, nextId: -1, parentId: -1, text: "", description: "", affirmation: "", color: Colors.red);
                                                final retWish = await appVM.startWishScreen(wishid, curwish.parentId, false, isUpdateScreen: true);
                                                curwish = retWish;
                                                changeStatus(appVM);
                                              });
                                        },
                                      );
                                    }
                                    else {

                                      changeStatus(appVM);
                                    }
                                  }
                                }),
                              ),
                              if(curwish.isChecked)const SizedBox(width: 16),
                              if(curwish.isChecked)Container(
                                width: 45,
                                height: 45,
                                decoration:  const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(22)),
                                    gradient: LinearGradient(
                                        colors: [AppColors.gradientStart, AppColors.gradientEnd]
                                    )
                                ),
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white), onPressed: () async {
                                    if(isParentHidden){
                                      showUnavailable("Чтобы изменить статус необходимо отменить статус 'скрыто' для вышестоящего желания");
                                    } else if(curwish.isHidden&&appVM.getShowedCirclesCount(curwish.parentId)>=12){
                                      showModalBottomSheet<void>(
                                        backgroundColor: AppColors.backgroundColor,
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return NotifyBS('Внимание', "Превышено количество 'Желаний на орбите'. Максимальное количество желаний на орбите 12 шт. Вы можете скрыть или удалить другие желания, чтобы освободить место для демонстрации данного желания на орбите", 'OK',
                                              onOk: () => Navigator.pop(context, 'OK'));
                                        },
                                      );
                                    }else {
                                      showModalBottomSheet<void>(
                                        backgroundColor: AppColors.backgroundColor,
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return ActionBS('Внимание', curwish.childAims.isEmpty&&appVM.mainScreenState!.allCircles.where((element) => element.parenId==curwish.id).isEmpty?(curwish.isHidden
                                              ? "Отобразить?" : "Скрыть?"):curwish.isHidden?"Если в данном желании создавались другие желания то они не будут отображены. Отобразить?":
                                          "Если в данном желании создавались другие желания, цели и задачи, то они также будут скрыты. Скрыть?", "Да", 'Нет',
                                              onOk: () {
                                                Navigator.pop(context, 'OK');
                                                setState(() {
                                                  curwish.isHidden =
                                                  !curwish.isHidden;
                                                  appViewModel.hideSphereWish(
                                                      curwish.id,
                                                      curwish.isHidden, true);
                                                });
                                                showModalBottomSheet<void>(
                                                  backgroundColor: AppColors.backgroundColor,
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (BuildContext context) {
                                                    return NotifyBS(curwish.isHidden?'скрыто':"не скрыто", "", 'OK',
                                                        onOk: () => Navigator.pop(context, 'OK'));
                                                  },
                                                );
                                              },
                                              onCancel: () {
                                                Navigator.pop(
                                                    context, 'Cancel');
                                              });
                                        },
                                      );
                                    }
                                  },
                                  ),
                                ),
                              )
                            ]),
                            const SizedBox(height: 16),
                            Stack(children:[
                              Column(children:[
                                TextField(
                                  controller: _title,
                                  onTap: (){
                                    if(curwish.isChecked&&!curwish.isActive) {showUnavailable("Желание исполнено в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале желаний в разделах 'исполненные' и 'все цели', а также в иерархии желания.\n\nВы можете удалить желание. Если вам нужна подобная, просто создайте новую.");}
                                    else if(curwish.text.contains("HEADERSIMPLETASKHEADER")){showUnavailable("Это желание содержит простые задачи. Его невозможно изменить");}
                                    else if(curwish.isChecked)showUnavailable("Чтобы редактировать желание необходимо перевести в статус \nна 'не исполнено'");
                                    else if(!curwish.isActive)showUneditable();
                                  },
                                  showCursor: true,
                                  readOnly: curwish.isChecked||!curwish.isActive||curwish.text.contains("HEADERSIMPLETASKHEADER")?true:false,
                                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                                    filled: true,
                                    suffixIconConstraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 2,
                                    ),
                                    suffixIcon: const Text("*", style: TextStyle(fontSize: 30, color: AppColors.greytextColor)),
                                    fillColor: curwish.isChecked?AppColors.fieldLockColor:!curwish.isActive?AppColors.fieldLockColor:Colors.white,
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
                                  controller: _affirmation,
                                  readOnly: true,
                                  showCursor: false,
                                  onTap: () async {
                                    if(curwish.isChecked){
                                      showUnavailable("Чтобы редактировать желание необходимо сменить статус \nна 'не выполнено'");
                                      return;
                                    }else if(!curwish.isActive){
                                      showUneditable();
                                    }else{
                                      final affirmationsStr = curwish.affirmation==""?
                                      await showOverlayedAffirmations(context, defaultAffirmations, false, curwish.shuffle, onShuffleClick: (value){
                                        curwish.shuffle=value;
                                      }):
                                      await showOverlayedAffirmations(context, appVM.wishScreenState!.wish.affirmation.split("|"), true, curwish.shuffle, onShuffleClick: (value){
                                        curwish.shuffle=value;
                                      });
                                      if(curwish.shuffle) curwish.lastShuffle = "|${DateTime.now().weekday.toString()}";
                                      _affirmation.text=affirmationsStr?.split("|")[0]??"";
                                      if(affirmationsStr!=curwish.affirmation)appViewModel.isChanged =true;
                                      curwish.affirmation=affirmationsStr??"";
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
                                    fillColor: curwish.isChecked?AppColors.fieldLockColor:!curwish.isActive?AppColors.fieldLockColor:Colors.white,
                                    hintText: 'Выбери аффирмацию', // Базовый текст
                                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  maxLength: 260,
                                  minLines: 1,
                                  maxLines: 5,
                                  controller: _description,
                                  showCursor: false,
                                  readOnly: true,
                                  onTap: () async {
                                    if(curwish.isChecked)
                                    {
                                      if(curwish.isChecked&&!curwish.isActive) {showUnavailable("Желание исполнено в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале желаний в разделах 'исполненные' и 'все цели', а также в иерархии желания.\n\nВы можете удалить желание. Если вам нужна подобная, просто создайте новую.");}
                                      else if(curwish.isChecked)showUnavailable("Чтобы редактировать желание необходимо перевести в статус \nна 'не исполнено'");else if(!curwish.isActive)showUneditable();
                                    }
                                    else if(!curwish.isActive){showUneditable();}
                                    else {
                                      final newText = await showOverlayedEdittext(context, _description.text, (curwish.isActive&&!curwish.isChecked))??"";
                                      if(newText!=_description.text)appViewModel.isChanged= true;
                                      setState(() {
                                        _description.text = newText;
                                      });
                                    }
                                  },
                                  style: const TextStyle(color: Colors.black), // Черный текст ввода
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    counterText: "",
                                    filled: true, // Заливка фона
                                    fillColor: curwish.isChecked?AppColors.fieldLockColor:!curwish.isActive?AppColors.fieldLockColor:Colors.white,
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
                                          if(curwish.isChecked)
                                          {
                                            if(curwish.isChecked&&!curwish.isActive) {showUnavailable("Желание исполнено в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале желаний в разделах 'исполненные' и 'все цели', а также в иерархии желания.\n\nВы можете удалить желание. Если вам нужна подобная, просто создайте новую.");}
                                            else if(curwish.isChecked)showUnavailable("Чтобы редактировать желание необходимо перевести в статус \nна 'не исполнено'");else if(!curwish.isActive)showUneditable();
                                          }
                                          else if(!curwish.isActive){showUneditable();}
                                          else {
                                            final newText = await showOverlayedEdittext(context, _description.text, (curwish.isActive&&!curwish.isChecked))??"";
                                            if(newText!=_description.text)appViewModel.isChanged= true;
                                            _description.text = newText;
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
                                if(curwish.parentId > 1)
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
                                                return buildSingle(fullWidth, e.first, appVM.isinLoading, !curwish.isActive);
                                              } else if(e.length==2) return buildTwin(leftWidth, rightWidth, em, appVM.isinLoading, !curwish.isActive);
                                              else if(imagesSet.indexOf(e)%2!=0) return buildTriple(leftWidth, rightWidth, em, appVM.isinLoading, !curwish.isActive);
                                              else return buildTripleReverce(leftWidth, rightWidth, em, appVM.isinLoading, !curwish.isActive);
                                            }).toList()
                                          ]);
                                    },
                                  ),
                                const SizedBox(height: 24),
                                if(curwish.parentId > 1)OutlinedGradientButton(" Добавить фото", () {
                                  appViewModel.photoUrls.clear();
                                  curwish.isChecked?showUnavailable("Чтобы редактировать желание необходимо сменить статус \nна 'не выполнено'"):!curwish.isActive?showUneditable():BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToGalleryScreenEvent());
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
                                            border: Border.all(color: _color??Colors.white, width: 2),
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
                                              if(_color!=defaultColorList[index])appViewModel.isChanged=true;
                                              _color=defaultColorList[index];
                                              curwish.color=defaultColorList[index];
                                            });
                                          },
                                          child: SizedBox(
                                            width: 34.0,
                                            height: 34.0,
                                            child: _color==defaultColorList[index]?const Icon(Icons.check, color: Colors.white, size: 20,):const SizedBox(),
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
                                              if(_color!=myColors[index])appViewModel.isChanged=true;
                                              _color=myColors[index];
                                              curwish.color=myColors[index];
                                            });
                                          },
                                          child: SizedBox(
                                            width: 34.0,
                                            height: 34.0,
                                            child: _color==myColors[index]?const Icon(Icons.check, color: Colors.white, size: 20,):const SizedBox(),
                                          ),
                                        ),
                                      ):InkWell(
                                        onTap: (){
                                          final shotColor = _color?.value;
                                          curwish.isChecked?showUnavailable("Чтобы редактировать желание необходимо сменить статус \nна 'не выполнено'"):!curwish.isActive?showUneditable():showModalBottomSheet(
                                              backgroundColor: AppColors.backgroundColor,context: context, isScrollControlled: true, builder: (BuildContext context){
                                            return ColorPickerBS(_color??Colors.white, (c){
                                              setState(() {
                                                if(shotColor!=c.value)appViewModel.isChanged=true;
                                                _color=c;
                                                curwish.color=c;
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
                                const SizedBox(height: 24),
                                if(curwish.parentId > 1&&curwish.isActive&&!curwish.isChecked)OutlinedGradientButton("Добавить цель", () {
                                  if(curwish.isChecked&&!curwish.isActive) {showUnavailable("Желание исполнено в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале желаний в разделах 'исполненные' и 'все цели', а также в иерархии желания.\n\nВы можете удалить желание. Если вам нужна подобная, просто создайте новую.");}
                                  else if(curwish.isChecked)showUnavailable("Чтобы редактировать желание необходимо перевести в статус \nна 'не исполнено'");
                                  else if(!curwish.isActive)showUneditable();
                                  else{
                                    if(appVM.mainScreenState!.allCircles.where((element) => element.id==appVM.wishScreenState!.wish.id).isNotEmpty) {
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToAimCreateScreenEvent(
                                          appVM.wishScreenState!.wish.id));
                                    }else{
                                      showModalBottomSheet<void>(
                                        backgroundColor: AppColors.backgroundColor,
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return NotifyBS('Необходимо сохранить желание', "", 'OK',
                                              onOk: () => Navigator.pop(context, 'OK'));
                                        },
                                      );
                                    }}
                                }),
                                const SizedBox(height: 8),
                                if(curwish.isActive&&!curwish.isChecked)OutlinedGradientButton(curwish.parentId==0?"Добавить желание":"Добавить поджелание", ()async {
                                  if(appVM.mainScreenState!.allCircles.where((element) => element.parenId==curwish.id).toList().length>=12){
                                    showUnavailable("Достигнуто максимальноке количество желаний на орбите. Вы можете скрть или удалить другие желания, чтобы освободить место для демонстрации данной желания на орбите");
                                  }else{
                                    appVM.cachedImages.clear();
                                    final childlastid = appViewModel.mainScreenState?.allCircles.where((element) => element.parenId==curwish.id&&element.nextId==-1).firstOrNull?.id??-1;
                                    int wishid = appViewModel.mainScreenState!.allCircles.isNotEmpty?appViewModel.mainScreenState!.allCircles.map((circle) => circle.id).reduce((value, element) => value > element ? value : element)+1:-101;
                                    await appViewModel.createNewSphereWish(WishData(id: wishid, prevId: childlastid, nextId: -1, parentId: curwish.id, text: "Новое желание", description: "", affirmation: (defaultAffirmations.join("|").toString()), color: Colors.red), true, true);
                                    BlocProvider.of<NavigationBloc>(context)
                                        .clearHistory();
                                    appVM.wishScreenState = null;
                                    isDataLoaded=false;
                                    final parentid = curwish.id;
                                    curwish=WishData(id: -1, prevId: -1, nextId: -1, parentId: -1, text: "text", description: "description", affirmation: "affirmation", color: Colors.grey);
                                    appViewModel.startWishScreen(wishid, parentid, false);
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigateToWishScreenEvent());
                                  }
                                },
                                ),
                                const SizedBox(height: 8),
                                if(curwish.isActive&&!curwish.isChecked)OutlinedGradientButton("Создать общую задачу", () {
                                  if(curwish.isChecked&&!curwish.isActive) {showUnavailable("Желание исполнено в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале желаний в разделах 'исполненные' и 'все цели', а также в иерархии желания.\n\nВы можете удалить желание. Если вам нужна подобная, просто создайте новую.");}
                                  else if(curwish.isChecked)showUnavailable("Чтобы редактировать желание необходимо перевести в статус \nна 'не исполнено'");
                                  else if(!curwish.isActive)showUneditable();
                                  else{
                                    if(appVM.mainScreenState!.allCircles.where((element) => element.id==appVM.wishScreenState!.wish.id).isNotEmpty) {
                                      appVM.myNodes.clear();
                                      BlocProvider.of<NavigationBloc>(context).add(NavigateToTaskCreateScreenEvent(curwish.id, isSimple: true, type: curwish.parentId > 1?'w':'s'));
                                    }else{
                                      showModalBottomSheet<void>(
                                        backgroundColor: AppColors.backgroundColor,
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return NotifyBS('Необходимо сохранить желание', "", 'OK',
                                              onOk: () => Navigator.pop(context, 'OK'));
                                        },
                                      );
                                    }}
                                }),
                              ]),
                              if(!curwish.isActive||curwish.isChecked)Positioned.fill(
                                child: Container(
                                  color: AppColors.backgroundColor.withOpacity(0.8),
                                )
                              )
                            ]),
                            const SizedBox(height: 24),
                            if(curwish.id > 0)
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                  SizedBox(key: _keyToScroll, height: 5),
                                  appVM.settings.treeView==0?MyTreeView(key: _treeViewKey,roots: root, currentId: curwish.id, onTap: (id, type) => onTreeItemTap(appVM, id, type, _title, _description, _affirmation)):
                                  TreeViewWidgetV2(key: UniqueKey(), root: root.firstOrNull??MyTreeNode(id: -1, type: "a", title: "title", isChecked: true), idToOpen: curwish.id, onTap: (id,type) => onTreeItemTap(appVM, id, type, _title, _description, _affirmation)),
                                  const SizedBox(height: 82),
                                ],),
                              )                ],
                        ),),
                    )),
                  ])),
            bottomSheet: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MediaQuery.of(context).viewInsets.bottom!=0? Row(
                    children: [
                      !curwish.isActive&&curwish.isChecked||!appVM.isChanged?const Spacer():Expanded(
                        child: ColorRoundedButton("Сохранить", () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if(_title.text.isEmpty||_affirmation.text.isEmpty){
                            await showModalBottomSheet<void>(
                              backgroundColor: AppColors.backgroundColor,
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return NotifyBS('Необходимо заполнить все поля со знаком *', "", 'OK',
                                    onOk: () => Navigator.pop(context, 'OK'));
                              },
                            );
                          }else {
                            appVM.wishScreenState!.wish
                              ..text = _title.text
                              ..description = _description.text
                              ..affirmation = curwish.affirmation
                              ..color = _color!;
                            await appViewModel.createNewSphereWish(
                                appVM.wishScreenState!.wish, false,true);
                            appViewModel.isChanged = false;
                            showModalBottomSheet<void>(
                              backgroundColor: AppColors.backgroundColor,
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return NotifyBS('сохранено', "", 'OK',
                                    onOk: () {
                                      Navigator.pop(context, 'OK');
                                      setState(() {
                                        appVM.convertToMyTreeNodeFullBranch(
                                            curwish.id);
                                      });
                                    }
                                );
                              },
                            );
                          }
                        },),
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
                      if(!curwish.text.contains("HEADERSI"))FloatingActionButton(
                        onPressed: (){
                          appViewModel.createMainScreenSpherePath(curwish.id, MediaQuery.of(context).size.width);
                          BlocProvider.of<NavigationBloc>(context).clearHistory();
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToMainScreenEvent());
                        },
                        backgroundColor: curwish.isActive?curwish.color:const Color.fromARGB(255, 217, 217, 217),
                        shape: const CircleBorder(),
                        child: Stack(children: [
                          Center(child: WordWrapWidget(text: curwish.text, minTextSize: 4, maxTextSize: 12, style: const TextStyle(color: Colors.white))),
                          if(curwish.isChecked)Align(alignment: Alignment.topRight, child: Image.asset('assets/icons/wish_done.png', width: 20, height: 20),)
                        ],),
                      ),
                      const SizedBox(width: 16),
                      !curwish.isActive&&curwish.isChecked||!appVM.isChanged?const SizedBox():Expanded(
                        child: ColorRoundedButton("Сохранить", () async {
                          if(_title.text.isEmpty||_affirmation.text.isEmpty){
                            await showModalBottomSheet<void>(
                              backgroundColor: AppColors.backgroundColor,
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return NotifyBS('Необходимо заполнить все поля со знаком *', "", 'OK',
                                    onOk: () => Navigator.pop(context, 'OK'));
                              },
                            );
                          }else {
                            appVM.wishScreenState!.wish
                              ..text = _title.text
                              ..description = _description.text
                              ..affirmation = curwish.affirmation
                              ..color = _color!;
                            await appViewModel.createNewSphereWish(
                                appVM.wishScreenState!.wish, false,true);
                            appViewModel.isChanged = false;
                            showModalBottomSheet<void>(
                              backgroundColor: AppColors.backgroundColor,
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return NotifyBS('сохранено', "", 'OK',
                                    onOk: () {
                                      Navigator.pop(context, 'OK');
                                      setState(() {
                                        appVM.convertToMyTreeNodeFullBranch(
                                            curwish.id);
                                      });
                                    }
                                    );
                              },
                            );
                          }
                        },),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
        }
        );
  }

  void changeStatus(AppViewModel appVM){
    if(appVM.wishScreenState!.wish.childAims.isNotEmpty||appVM.mainScreenState?.allCircles.firstWhereOrNull((element) => element.parenId==appVM.wishScreenState!.wish.id)!=null) {
      showModalBottomSheet<void>(
        backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return ActionBS('Внимание', (!curwish.isChecked)?"Если в данном желании создавались другие желания, цели и задачи, то они также получат статус 'исполнена' / 'достигнута' / 'выполнена'. Исполнено?":
          "Если в данном желании создавались другие желания, цели и задачи, то они останутся в статусе 'исполнена' / 'достигнута' / 'выполнена'. Не исполнено?", "Да", 'Нет',
              onOk: () {
                Navigator.pop(context, 'OK');
                curwish.isChecked =
                !curwish.isChecked;
                if(curwish.isChecked&&appVM.settings.animationEnabled)showOverlayedAnimations(context, 'assets/lottie/vypolneniezhelaniya.json', fillBackground: true, onControllerCreated: (controller){lottieController = controller;});
                appVM.updateWishStatus(
                    appVM.wishScreenState!.wish
                        .id, curwish.isChecked);
                showModalBottomSheet<void>(
                  backgroundColor: AppColors.backgroundColor,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return NotifyBS(curwish.isChecked?'исполнено':'не исполнено', "", 'OK',
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
              onCancel: () {
                Navigator.pop(
                    context, 'Cancel');
              });
        },
      );
    }else{
      curwish.isChecked =
      !curwish.isChecked;
      if(curwish.isChecked&&appVM.settings.animationEnabled)showOverlayedAnimations(context, 'assets/lottie/vypolneniezhelaniya.json', fillBackground: true, onControllerCreated: (controller){lottieController = controller;});
      appVM.updateWishStatus(
          appVM.wishScreenState!.wish
              .id, curwish.isChecked);
      showModalBottomSheet<void>(
        backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return NotifyBS(curwish.isChecked ?'исполнено':'не исполнено', "", 'OK',
              onOk: () => Navigator.pop(context, 'OK'));
        },
      );
    }
  }

  Future<bool> onSaveClicked(AppViewModel appVM, bool isExit, TextEditingController title, TextEditingController description, TextEditingController affirmation) async {
    if(title.text.isEmpty||affirmation.text.isEmpty){
      await showModalBottomSheet<void>(
        backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return NotifyBS('Необходимо заполнить все поля со знаком *', "", 'OK',
              onOk: () => Navigator.pop(context, 'OK'));
        },
      );
      return false;
    }
    appVM.wishScreenState!.wish
      ..text=title.text
      ..description=description.text
      ..affirmation=curwish.affirmation
      ..color = _color!;
    await appVM.createNewSphereWish(appVM.wishScreenState!.wish, false, true);
    appVM.isChanged=false;
    appVM.convertToMyTreeNodeFullBranch(curwish.id);
    showModalBottomSheet<void>(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NotifyBS('Сохранено', "", 'OK',
            onOk: () {
              Navigator.pop(context, 'OK');
              if(isExit) {
                BlocProvider.of<NavigationBloc>(context)
                    .handleBackPress();
              }
            }
            );
      },
    );
    return true;
  }

  Future<bool?> showOnExit(AppViewModel appVM, TextEditingController title, TextEditingController description, TextEditingController affirmation) async {
    return await showModalBottomSheet<bool>(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ActionBS('Внимание', "Вы изменили поля но не нажали 'Сохранить'\nСохранить изменения?", "Да", 'Нет',
            onOk: () async {
              Navigator.pop(context, true);
              await onSaveClicked(appVM, true, title, description, affirmation);
            },
            onCancel: () { Navigator.pop(context, true);
            appVM.isChanged=false;
        });
      },
    );
  }
  void showUnavailable(String text){
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
  void showUneditable() {
    showModalBottomSheet<void>(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NotifyBS("Чтобы редактировать необходимо изменить статус на 'актуальное' нажав кнопку 'осознать'", "", 'OK',
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
        return NotifyBS('Внимание', "Статус желания не может быть изменен на 'не исполнено' пока вышестоящее желание не будет переведено в статус 'не исполнено'", 'OK',
            onOk: () => Navigator.pop(context, 'OK'));
      },
    );
  }
  Future onTreeItemTap(AppViewModel appVM, int id, String type, TextEditingController title, TextEditingController description, TextEditingController affirmation) async {
    if(type=="m"){
      if(appVM.isChanged){if(await showOnExit(appVM, title, description, affirmation)==false) return;}
      BlocProvider.of<NavigationBloc>(context).clearHistory();
      appVM.cachedImages.clear();
      appVM.startMainsphereeditScreen();
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigateToMainSphereEditScreenEvent());
    }else if(type=="w"||type=="s"){
      if(appVM.isChanged){if(await showOnExit(appVM, title, description, affirmation)==false) return;}
      curwish=WishData(id: -1, prevId: -1, nextId: -1, parentId: -1, text: "text", description: "description", affirmation: "affirmation", color: Colors.transparent);
      appVM.startWishScreen(id, 0, true);
    }else if(type=="a"){
      if(appVM.isChanged){if(await showOnExit(appVM, title, description, affirmation)==false) return;}
      appVM.getAim(id);
      appVM.myNodes.clear();
      BlocProvider.of<NavigationBloc>(context).add(NavigateToAimEditScreenEvent(id));
    }else if(type=="t"){
      if(appVM.isChanged){if(await showOnExit(appVM, title, description, affirmation)==false) return;}
      appVM.myNodes.clear();
      appVM.currentAim = null;
      appVM.currentTask = null;
      appVM.getTask(id);
      BlocProvider.of<NavigationBloc>(context).add(NavigateToTaskEditScreenEvent(id));
    }
  }
}
