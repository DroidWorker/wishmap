import 'dart:math';
import 'dart:typed_data';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:collection/collection.dart';
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
import '../common/treeview_widget_v2.dart';
import '../data/static.dart';
import '../data/static_affirmations_women.dart';
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
  bool isParentHidden = false;
  bool isParentActive = false;
  bool parentIsSphere = false;

  WishData curwish = WishData(id: -1, prevId: -1, nextId: -1, parentId: -1, text: "", description: "", affirmation: "", color: Colors.grey);

  final descriptionText = "Синтез желаний самое невероятное чудо, которое есть в руках человека.Это буквально сила нашего сознания, сила самой вселенной, сила Бога, если хотите.\n\nИ может потому нас посещают страхи, что желания наши не исполнятся, что сила, которая связана с этим явлением соль великая и мощная, что управлять ей мы не всегда умеем.";

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    TextEditingController _title = TextEditingController(text: curwish.text);
    TextEditingController _description = TextEditingController(text: curwish.description);
    TextEditingController _affirmation = TextEditingController(text: curwish.affirmation.split("|")[0]);
    _title.addListener(() { if(_title.text!=appViewModel.wishScreenState!.wish.text)appViewModel.isChanged = true;curwish.text=_title.text;});
    _description.addListener(() { if(_description.text!=appViewModel.wishScreenState!.wish.description)appViewModel.isChanged = true;curwish.description=_description.text;});
    _affirmation.addListener(() { });

    return  Consumer<AppViewModel>(
        builder: (context, appVM, child){
          if(appVM.wishScreenState!=null&&curwish.id==-1) {
            curwish = appVM.wishScreenState!.wish;
            _title.text = appVM.wishScreenState!.wish.text;
            _description.text = appVM.wishScreenState!.wish.description;
            _affirmation.text = appVM.wishScreenState!.wish.affirmation;
            _color = appVM.wishScreenState!.wish.color;
            isDataLoaded = appVM.wishScreenState!.isDataloaded;
            //appViewModel.getAimsForCircles(appVM.wishScreenState!.wish.id);
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
          if(appViewModel.cachedImages.length!=ids.length){
            appViewModel.isChanged=true;
          }else {
            appViewModel.isChanged=false;
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
                          icon: const Icon(Icons.keyboard_arrow_left, size: 30,),
                          onPressed: () {
                            if(curwish.isHidden){
                              appVM.mainCircles.clear();
                              appViewModel.startMainScreen(appVM.mainScreenState!.moon);
                              BlocProvider.of<NavigationBloc>(context).add(NavigateToMainScreenEvent());
                            }
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
                                    onSaveClicked(appVM, true, _title, _description, _affirmation);
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
                            }
                            appViewModel.backPressedCount++;
                            if(appViewModel.backPressedCount==appViewModel.settings.quoteupdateFreq){
                              appViewModel.backPressedCount=0;
                              appViewModel.hint=quoteBack[Random().nextInt(367)];
                            }
                          }
                      ),
                      const Expanded(child: SizedBox(),),
                      if(curwish.parentId > 1&&curwish.isActive)
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
                                if(appVM.isChanged) {
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
                                          final result = await onSaveClicked(appVM, false, _title, _description, _affirmation);
                                          if(result)changeStatus(appVM);
                                          },
                                          child: const Text('Да'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context, 'Cancel');
                                            final wishid = curwish.id;
                                            curwish=WishData(id: -1, prevId: -1, nextId: -1, parentId: -1, text: "", description: "", affirmation: "", color: Colors.red);
                                            final retWish = await appVM.startWishScreen(wishid, curwish.parentId, isUpdateScreen: true);
                                            curwish = retWish;
                                            changeStatus(appVM);
                                            },
                                          child: const Text('Нет'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                else {
                                  changeStatus(appVM);
                                }
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
                                    (curwish.childAims.isEmpty&&!appVM.hasChildWishes(curwish.id))?const Text("Объект будет удален"):(curwish.parentId > 1)?const Text("Если в данном желании создавались желания, цели и задачи, то они также будут удалены", maxLines: 4, textAlign: TextAlign.center,):
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
                                    appViewModel.deleteSphereWish(appVM.wishScreenState!.wish.id, curwish.prevId, curwish.nextId);
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
                            if(_title.text.isEmpty||_affirmation.text.isEmpty){
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
                            }else {
                              appVM.wishScreenState!.wish
                                ..text = _title.text
                                ..description = _description.text
                                ..affirmation = curwish.affirmation
                                ..color = _color!;
                              await appViewModel.createNewSphereWish(
                                  appVM.wishScreenState!.wish, false);
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
                                          setState(() {
                                            appVM.convertToMyTreeNodeFullBranch(
                                                curwish.id);
                                          });
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: const Text("Cохранить",
                            style: TextStyle(color: AppColors.blueTextColor, fontSize: 12),)
                      )else if(!curwish.isActive&&!curwish.isChecked)
                      TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.greyBackButton,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          onPressed: () {
                            if(isParentActive||appVM.settings.wishActualizingMode==1||parentIsSphere) {
                              if(appVM.settings.sphereActualizingMode==1||appVM.isParentSphereActive(curwish.id)||curwish.parentId==0){
                                appViewModel.activateSphereWish(curwish.id, true);
                                setState(() {
                                  appViewModel.mainCircles.where((element) =>
                                  element.id == curwish.id).firstOrNull?.isActive = true;
                                  curwish.isActive = true;
                                });
                              } else{
                                showUnavailable("Чтобы представить это желание необходимо сначала представить вышестоящиую сферу");
                              }
                            } else{
                              showUnavailable("Чтобы представить это желание необходимо сначала представить вышестоящий объект");
                            }
                          },
                          child: const Text("Представить",
                            style: TextStyle(color: AppColors.redTextColor),)
                      )
                      else if(curwish.isChecked&&curwish.parentId > 1)
                          TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: curwish.isHidden?AppColors.pinkButtonTextColor:AppColors.greyBackButton,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              onPressed: () async {
                                if(isParentHidden){
                                showUnavailable("Чтобы изменить статус необходимо отменить статус 'скрыто' для вышестоящего желания");
                                } else if(curwish.isHidden&&appVM.getShowedCirclesCount(curwish.parentId)>=12){
                                  showDialog(context: context, builder: (BuildContext context) =>
                                    AlertDialog(
                                        contentPadding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32.0))),
                                        title: const Text('Внимание',
                                          textAlign: TextAlign.center,),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(height: 10,),
                                            Text("Превышено количество 'Желаний на орбите'. Максимальное количество желаний на орбите 12 шт. Вы можете скрть или удалитьдругие желания, чтобы освободить место для демонстрации данного желания на орбите")
                                          ],
                                        ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {Navigator.pop(context, 'OK');},
                                          child: const Text('Ок'),
                                        )
                                      ],
                                    )
                                  );
                                }else {
                                  showDialog(context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          contentPadding: EdgeInsets.zero,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.0))),
                                          title: const Text('Внимание',
                                            textAlign: TextAlign.center,),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              curwish.childAims.isEmpty&&appVM.mainScreenState!.allCircles.where((element) => element.parenId==curwish.id).isEmpty
                                                  ? const Text("")
                                                  : curwish.isHidden ? const Text("Если в данном желании создавались другие желания то они не будут отображены", maxLines: 6, textAlign: TextAlign.center,)
                                                  : const Text(
                                                "Если в данном желании создавались другие желания, цели и задачи, то они также будут скрыты",
                                                maxLines: 6,
                                                textAlign: TextAlign.center,),
                                              const SizedBox(height: 4,),
                                              const Divider(color: AppColors
                                                  .dividerGreyColor,),
                                              const SizedBox(height: 4,),
                                              Text(curwish.isHidden
                                                  ? "Отобразить?"
                                                  : "Скрыть?",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),)
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, 'OK');
                                                setState(() {
                                                  curwish.isHidden =
                                                  !curwish.isHidden;
                                                  appViewModel.hideSphereWish(
                                                      curwish.id,
                                                      curwish.isHidden, true);
                                                });
                                                showDialog(context: context,
                                                  builder: (
                                                      BuildContext context) =>
                                                      AlertDialog(
                                                        title: curwish.isHidden
                                                            ? const Text(
                                                            'скрыто')
                                                            : const Text(
                                                            'не скрыто'),
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    32.0))),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context,
                                                                  'OK');
                                                            },
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                              },
                                              child: const Text('Да'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, 'Cancel');
                                              },
                                              child: const Text('Нет'),
                                            ),
                                          ],
                                        ),
                                  );
                                }
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
                              onTap: (){
                                if(curwish.isChecked&&!curwish.isActive) {showUnavailable("Желание исполнено в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале желаний в разделах 'исполненные' и 'все цели', а также в иерархии желания.\n\nВы можете удалить желание. Если вам нужна подобная, просто создайте новую.");}
                                else if(curwish.isChecked)showUnavailable("Чтобы редактировать желание необходимо перевести в статус \nна 'не исполнено'");
                                else if(!curwish.isActive)showUneditable();
                              },
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
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 7,
                                  minHeight: 2,
                                ),
                                suffixIcon: const Text("*"),
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
                                hintText: descriptionText, // Базовый текст
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 10), // Полупрозрачный черный базовый текст
                              ),
                            ),
                            const SizedBox(height: 10),
                            if(curwish.parentId > 1)
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
                                                ),): appViewModel.cachedImages.isNotEmpty?Image.memory(appViewModel.cachedImages.first, fit: BoxFit.cover):Stack(children: [Container(padding: const EdgeInsets.all(8), child: const Center(child: Text("Добавьте образы вашего 'Я' - это важно!\n Чем ближе будут образы вашему представлению, тем сильнее будет визуализация вашего желания.", style: TextStyle(color: AppColors.greytextColor),))), const Align(alignment: Alignment.topRight, child: Text("*  "),)],),
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
                            const SizedBox(height: 5),
                            if(curwish.parentId > 1)
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.fieldFillColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), // <-- Radius
                                    ),
                                  ),
                                  onPressed: (){
                                    //appViewModel.isChanged = true;
                                    appViewModel.photoUrls.clear();
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
                                  final shotColor = _color?.value;
                                    curwish.isChecked?showUnavailable("Чтобы редактировать желание необходимо сменить статус \nна 'не выполнено'"):!curwish.isActive?showUneditable():showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ColorPickerWidget(initColor: _color, onColorSelected: (Color c){setState(() {
                                          if(shotColor!=c.value)appViewModel.isChanged=true;
                                          _color=c;
                                          curwish.color=c;
                                        });
                                        });
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
                                  appVM.settings.treeView==0?MyTreeView(key: UniqueKey(),roots: root, onTap: (id, type) => onTreeItemTap(appVM, id, type, _title, _description, _affirmation)):
                                  TreeViewWidgetV2(key: UniqueKey(), root: root.firstOrNull??MyTreeNode(id: -1, type: "a", title: "title", isChecked: true), onTap: (id,type) => onTreeItemTap(appVM, id, type, _title, _description, _affirmation)),
                                  const SizedBox(height: 5),
                                  if(curwish.parentId > 1)
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.fieldFillColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10), // <-- Radius
                                          ),
                                        ),
                                        onPressed: (){
                                          if(curwish.isChecked&&!curwish.isActive) {showUnavailable("Желание исполнено в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале желаний в разделах 'исполненные' и 'все цели', а также в иерархии желания.\n\nВы можете удалить желание. Если вам нужна подобная, просто создайте новую.");}
                                          else if(curwish.isChecked)showUnavailable("Чтобы редактировать желание необходимо перевести в статус \nна 'не исполнено'");
                                          else if(!curwish.isActive)showUneditable();
                                          else{
                                          if(appVM.mainScreenState!.allCircles.where((element) => element.id==appVM.wishScreenState!.wish.id).isNotEmpty) {
                                            BlocProvider.of<NavigationBloc>(context)
                                                .add(NavigateToAimCreateScreenEvent(
                                                appVM.wishScreenState!.wish.id));
                                          }else{
                                            showDialog(context: context,
                                              builder: (BuildContext context) => AlertDialog(
                                                title: const Text('Необходимо сохранить желание'),
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
                                          }}
                                        },
                                        child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor))
                                    ),
                                  if(curwish.isActive&&!curwish.isChecked)ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.fieldFillColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10), // <-- Radius
                                        ),
                                      ),
                                      onPressed: () async {
                                    final childlastid = appViewModel.mainScreenState?.allCircles.where((element) => element.parenId==curwish.id&&element.nextId==-1).firstOrNull?.id??-1;
                                    int wishid = appViewModel.mainScreenState!.allCircles.isNotEmpty?appViewModel.mainScreenState!.allCircles.map((circle) => circle.id).reduce((value, element) => value > element ? value : element)+1:-101;
                                    await appViewModel.createNewSphereWish(WishData(id: wishid, prevId: childlastid, nextId: -1, parentId: curwish.id, text: "Новое желание", description: "", affirmation: (defaultAffirmations.join("|").toString()), color: Colors.red), true);
                                    root.clear();
                                    appVM.convertToMyTreeNodeFullBranch(curwish.id);
                                  },
                                      child: const Text("Добавить желание", style: TextStyle(color: AppColors.greytextColor))
                                  )
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

  void changeStatus(AppViewModel appVM){
    if(appVM.wishScreenState!.wish.childAims.isNotEmpty||appVM.mainScreenState?.allCircles.firstWhereOrNull((element) => element.parenId==appVM.wishScreenState!.wish.id)!=null) {
      showDialog(context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(32.0))),
              title: const Text('Внимание',
                textAlign: TextAlign.center,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*curwish.childAims.isEmpty?const Text(""):*/(!curwish.isChecked) ? const Text(
                    "Если в данном желании создавались другие желания, цели и задачи, то они также получат статус 'исполнена' / 'достигнута' / 'выполнена'",
                    maxLines: 6,
                    textAlign: TextAlign.center,) :
                  const Text(
                    "Если в данном желании создавались другие желания, цели и задачи, то они останутся в статусе 'исполнена' / 'достигнута' / 'выполнена'",
                    maxLines: 6,
                    textAlign: TextAlign.center,),
                  const SizedBox(height: 4,),
                  const Divider(color: AppColors
                      .dividerGreyColor,),
                  const SizedBox(height: 4,),
                  (curwish.isChecked) ? const Text(
                    "Не исполнено?",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18),) :
                  const Text("Исполнено?",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18),)
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'OK');
                    curwish.isChecked =
                    !curwish.isChecked;
                    appVM.updateWishStatus(
                        appVM.wishScreenState!.wish
                            .id, curwish.isChecked);
                    showDialog(context: context,
                      builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: curwish.isChecked
                                ? const Text(
                                'исполнено')
                                : const Text(
                                'не исполнено'),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius
                                    .all(
                                    Radius.circular(
                                        32.0))),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context,
                                      'OK');
                                },
                                child: const Text(
                                    'OK'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Text('Да'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context, 'Cancel');
                  },
                  child: const Text('Нет'),
                ),
              ],
            ),
      );
    }else{
      curwish.isChecked =
      !curwish.isChecked;
      appVM.updateWishStatus(
          appVM.wishScreenState!.wish
              .id, curwish.isChecked);
      showDialog(context: context,
        builder: (
            BuildContext context) =>
            AlertDialog(
              title: curwish.isChecked
                  ? const Text(
                  'исполнено')
                  : const Text(
                  'не исполнено'),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius
                      .all(
                      Radius.circular(
                          32.0))),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context,
                        'OK');
                  },
                  child: const Text(
                      'OK'),
                ),
              ],
            ),
      );
    }
  }

  Future<bool> onSaveClicked(AppViewModel appVM, bool isExit, TextEditingController title, TextEditingController description, TextEditingController affirmation) async {
    if(title.text.isEmpty||affirmation.text.isEmpty){
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
    }
    appVM.wishScreenState!.wish
      ..text=title.text
      ..description=description.text
      ..affirmation=curwish.affirmation
      ..color = _color!;
    await appVM.createNewSphereWish(appVM.wishScreenState!.wish, false);
    appVM.isChanged=false;
    appVM.convertToMyTreeNodeFullBranch(curwish.id);
    showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Сохранено'),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              if(isExit) {
                BlocProvider.of<NavigationBloc>(context)
                  .handleBackPress();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return true;
  }

  Future<bool> showOnExit(AppViewModel appVM, TextEditingController title, TextEditingController description, TextEditingController affirmation) async {
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
              await onSaveClicked(appVM, true, title, description, affirmation);
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
  void showUnavailable(String text){
    showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.all(10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, maxLines: 5, textAlign: TextAlign.center),
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
                  maxLines: 5, textAlign: TextAlign.center),
                SizedBox(height: 4,),
                Divider(color: AppColors.dividerGreyColor),
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
      appVM.startWishScreen(id, 0);
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
