import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../ViewModel.dart';
import '../common/EditTextOverlay.dart';
import '../common/treeview_widget_v2.dart';
import '../data/models.dart';
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

  bool isTextSetted = false;

  @override
  Widget build(BuildContext context) {
    text.addListener(() { if(ai?.text!=text.text)isChanged = true;});
    description.addListener(() { if(ai?.description!=description.text)isChanged = true;});
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          if(ai==null||ai!.id==-1)ai = appVM.currentAim??AimData(id: -1, parentId: -1, text: 'объект не найден', description: "", isChecked: false);
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_left, size: 30,),
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
                                        onPressed: () async {
                                          Navigator.pop(context, 'OK');
                                          onSaveClick(appVM);
                                          if(text.text.isNotEmpty&&description.text.isNotEmpty)BlocProvider.of<NavigationBloc>(context)
                                              .handleBackPress();
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
                              },
                            ),
                            const Spacer(),
                            if(ai!.isActive)TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: ai!.isChecked?AppColors.pinkButtonTextColor:AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  if(ai!=null){
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
                                                Text("Сохранить изменения перед достижением цели?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () async { Navigator.pop(context, 'OK');
                                                  onSaveClick(appVM);
                                                  if (ai!.childTasks.isNotEmpty) {
                                                  showDialog(context: context,
                                                    builder: (BuildContext context) =>
                                                        AlertDialog(
                                                          contentPadding: EdgeInsets
                                                              .zero,
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(
                                                                  Radius.circular(
                                                                      32.0))),
                                                          title: const Text('Внимание',
                                                            textAlign: TextAlign
                                                                .center,),
                                                          content: Column(
                                                            mainAxisSize: MainAxisSize
                                                                .min,
                                                            children: [
                                                              (!ai!.isChecked)
                                                                  ? const Text(
                                                                "Если в данной цели создавались задачи, то они также получат статус 'выполнена'",
                                                                maxLines: 6,
                                                                textAlign: TextAlign
                                                                    .center,)
                                                                  :
                                                              const Text(
                                                                "Если в данной цели создавались другие задачи, то они останутся в статусе 'выполнена'",
                                                                maxLines: 6,
                                                                textAlign: TextAlign
                                                                    .center,),
                                                              const SizedBox(
                                                                height: 4,),
                                                              const Divider(
                                                                color: AppColors
                                                                    .dividerGreyColor,),
                                                              const SizedBox(
                                                                height: 4,),
                                                              (ai!.isChecked)
                                                                  ? const Text(
                                                                "Не Достигнута?",
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    fontSize: 18),)
                                                                  :
                                                              const Text("Достигнута?",
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    fontSize: 18),)
                                                            ],
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context, 'OK');
                                                                  ai!.isChecked = !ai!.isChecked;
                                                                  appVM.updateAimStatus(ai!.id, ai!.isChecked);
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (
                                                                      BuildContext context) =>
                                                                      AlertDialog(
                                                                        title: ai!
                                                                            .isChecked
                                                                            ? const Text(
                                                                            'Достигнута')
                                                                            : const Text(
                                                                            'не Достигнута'),
                                                                        shape: const RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius
                                                                                .all(
                                                                                Radius
                                                                                    .circular(
                                                                                    32.0))),
                                                                        actions: <
                                                                            Widget>[
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator
                                                                                  .pop(
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
                                                }else {
                                                    ai!.isChecked = !ai!.isChecked;
                                                    appVM.updateAimStatus(ai!.id, ai!.isChecked);
                                                }
                                                },
                                                child: const Text('Да'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context, 'Cancel');
                                                  if (ai!.childTasks.isNotEmpty) {
                                                    showDialog(context: context,
                                                      builder: (BuildContext context) =>
                                                          AlertDialog(
                                                            contentPadding: EdgeInsets
                                                                .zero,
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(
                                                                    Radius.circular(
                                                                        32.0))),
                                                            title: const Text('Внимание',
                                                              textAlign: TextAlign
                                                                  .center,),
                                                            content: Column(
                                                              mainAxisSize: MainAxisSize
                                                                  .min,
                                                              children: [
                                                                (!ai!.isChecked)
                                                                    ? const Text(
                                                                  "Если в данной цели создавались задачи, то они также получат статус 'выполнена'",
                                                                  maxLines: 6,
                                                                  textAlign: TextAlign
                                                                      .center,)
                                                                    :
                                                                const Text(
                                                                  "Если в данной цели создавались другие задачи, то они останутся в статусе 'выполнена'",
                                                                  maxLines: 6,
                                                                  textAlign: TextAlign
                                                                      .center,),
                                                                const SizedBox(
                                                                  height: 4,),
                                                                const Divider(
                                                                  color: AppColors
                                                                      .dividerGreyColor,),
                                                                const SizedBox(
                                                                  height: 4,),
                                                                (ai!.isChecked)
                                                                    ? const Text(
                                                                  "Не Достигнута?",
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight
                                                                          .bold,
                                                                      fontSize: 18),)
                                                                    :
                                                                const Text("Достигнута?",
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight
                                                                          .bold,
                                                                      fontSize: 18),)
                                                              ],
                                                            ),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                onPressed: () async {
                                                                  Navigator.pop(
                                                                      context, 'OK');
                                                                  ai!.isChecked = !ai!
                                                                      .isChecked;
                                                                  await appVM.updateAimStatus(
                                                                      ai!.id, ai!.isChecked);
                                                                  await appVM.getAim(ai!.id);
                                                                  text.text =
                                                                      appVM.currentAim!.text;
                                                                  description.text =
                                                                      appVM.currentAim!
                                                                          .description;
                                                                  isChanged = false;
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (
                                                                        BuildContext context) =>
                                                                        AlertDialog(
                                                                          title: ai!
                                                                              .isChecked
                                                                              ? const Text(
                                                                              'Достигнута')
                                                                              : const Text(
                                                                              'не Достигнута'),
                                                                          shape: const RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius
                                                                                  .all(
                                                                                  Radius
                                                                                      .circular(
                                                                                      32.0))),
                                                                          actions: <
                                                                              Widget>[
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator
                                                                                    .pop(
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
                                                  }else {
                                                    ai!.isChecked = !ai!
                                                        .isChecked;
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
                                                  },
                                                child: const Text('Нет'),
                                              ),
                                            ],
                                          )
                                        );
                                      }else {
                                        if (ai!.childTasks.isNotEmpty) {
                                          showDialog(context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                                  contentPadding: EdgeInsets
                                                      .zero,
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .all(
                                                          Radius.circular(
                                                              32.0))),
                                                  title: const Text('Внимание',
                                                    textAlign: TextAlign
                                                        .center,),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min,
                                                    children: [
                                                      (!ai!.isChecked)
                                                          ? const Text(
                                                        "Если в данной цели создавались задачи, то они также получат статус 'выполнена'",
                                                        maxLines: 6,
                                                        textAlign: TextAlign
                                                            .center,)
                                                          :
                                                      const Text(
                                                        "Если в данной цели создавались другие задачи, то они останутся в статусе 'выполнена'",
                                                        maxLines: 6,
                                                        textAlign: TextAlign
                                                            .center,),
                                                      const SizedBox(
                                                        height: 4,),
                                                      const Divider(
                                                        color: AppColors
                                                            .dividerGreyColor,),
                                                      const SizedBox(
                                                        height: 4,),
                                                      (ai!.isChecked)
                                                          ? const Text(
                                                        "Не Достигнута?",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            fontSize: 18),)
                                                          :
                                                      const Text("Достигнута?",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            fontSize: 18),)
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, 'OK');
                                                        ai!.isChecked = !ai!
                                                            .isChecked;
                                                        appVM.updateAimStatus(
                                                            ai!.id,
                                                            ai!.isChecked);
                                                        showDialog(
                                                          context: context,
                                                          builder: (
                                                              BuildContext context) =>
                                                              AlertDialog(
                                                                title: ai!
                                                                    .isChecked
                                                                    ? const Text(
                                                                    'Достигнута')
                                                                    : const Text(
                                                                    'не Достигнута'),
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius
                                                                        .all(
                                                                        Radius
                                                                            .circular(
                                                                            32.0))),
                                                                actions: <
                                                                    Widget>[
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator
                                                                          .pop(
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
                                        } else {
                                          ai!.isChecked = !ai!
                                              .isChecked;
                                          appVM.updateAimStatus(
                                              ai!.id, ai!.isChecked);
                                          showDialog(context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                                  title: ai!.isChecked
                                                      ? const Text(
                                                      'Достигнута')
                                                      : const Text(
                                                      'не Достигнута'),
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .all(Radius
                                                          .circular(
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
                                    }
                                  }
                                },
                                child: const Text("Достигнута",style: TextStyle(color: Colors.black, fontSize: 12),)
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
                                          Text(ai!.childTasks.isNotEmpty?"Если в данной цели создавались задачи, то они также будут удалены":"Цель будет удалена", maxLines: 4, textAlign: TextAlign.center,),
                                          const SizedBox(height: 4,),
                                          const Divider(color: AppColors.dividerGreyColor,),
                                          const SizedBox(height: 4,),
                                          const Text("Удалить?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () { Navigator.pop(context, 'OK');
                                          appVM.deleteAim(widget.aimId, ai!.parentId);
                                          BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                          showDialog(context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              title: const Text('Удалено'),
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
                                child: const Text("Удалить",style: TextStyle(color: Colors.black, fontSize: 12))
                            ),
                            const SizedBox(width: 3,),
                            ai!=null&&!ai!.isActive&&!ai!.isChecked?TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  if(isParentActive) {
                                    setState(() {
                                      appVM.activateAim(ai!.id, true);
                                      ai!.isActive = true;
                                    });
                                  }else{
                                    showUnavailable("Чтобы актуализировать цели и задачи необходимо актуализировать вышестоящее желание нажав кнопку 'воплотить'");
                                  }
                                },
                                child: const Text("Актуализировать",
                                    style: TextStyle(color: AppColors.blueTextColor, fontSize: 12))
                            ): ai!=null&&!ai!.isActive&&ai!.isChecked?const SizedBox():
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  if(ai!=null&&!ai!.isChecked) {
                                    onSaveClick(appVM);
                                  } else{
                                    showUneditable(text: "Невозможноо сохранить цель в статусе 'достигнута'");
                                  }
                                },
                                child: const Text("Cохранить цель",
                                  style: TextStyle(color: AppColors.blueTextColor, fontSize: 12))
                            ),
                          ],
                        ),

                        const Divider(
                          height: 3,
                          color: AppColors.dividerGreyColor,
                          indent: 5,
                          endIndent: 5,
                        ),
                      ],
                    ),
                    Expanded(child:SingleChildScrollView(
                      child: Column(children:[
                        const SizedBox(height: 15,),
                        TextField(
                          onTap: (){
                            if(ai!.isChecked&&!ai!.isActive) {showUnavailable("3адача выполнена в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале задач в разделах 'выполненные' и 'все задачи', а также в иерархии цели и желания.\n\nВы можете удалить задачу. Если вам нужна подобная, просто создайте новую задачу.");}
                            else if(ai!.isChecked) {showUnavailable("Чтобы редактировать цель необходимо сменить статус \nна 'не выполнена'");}
                            else if(!ai!.isActive) {showUnavailable("Невозможно изменить неактуализированную задачу");}
                          },
                          controller: text,
                          showCursor: true,
                          readOnly: ai!=null?(ai!.isChecked||!ai!.isActive?true:false):false,
                          style: const TextStyle(color: Colors.black), // Черный текст ввода
                          decoration: InputDecoration(
                            filled: true,
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 7,
                              minHeight: 2,
                            ),
                            suffixIcon: const Text("*"),
                            fillColor: ai!=null?(ai!.isChecked?AppColors.fieldLockColor:!ai!.isActive?AppColors.fieldInactive:AppColors.fieldFillColor):AppColors.fieldFillColor,
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
                        const SizedBox(height: 15,),
                        TextField(
                          minLines: 4,
                          maxLines: 7,
                          controller: description,
                          onTap: () async {
                            if(ai!.isChecked){
                              if(ai!.isChecked&&!ai!.isActive) {showUnavailable("3адача выполнена в прошлой карте. Изменению не подлежит. Вы можете видеть ее в журнале задач в разделах 'выполненные' и 'все задачи', а также в иерархии цели и желания.\n\nВы можете удалить задачу. Если вам нужна подобная, просто создайте новую задачу.");}
                              else if(ai!.isChecked) {showUnavailable("Чтобы редактировать цель необходимо сменить статус \nна 'не выполнена'");}
                              else if(!ai!.isActive) {showUnavailable("Невозможно изменить неактуализированную задачу");}
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
                            fillColor: ai!=null?(ai!.isChecked?AppColors.fieldLockColor:!ai!.isActive?AppColors.fieldInactive:AppColors.fieldFillColor):AppColors.fieldFillColor,
                            hintText: 'Описание', // Базовый текст
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                          ),
                        ),
                        const SizedBox(height: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.fieldFillColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // <-- Radius
                                  ),
                                ),
                                onPressed: () {
                                  if(ai!=null){
                                    if(!ai!.isActive){
                                      showUnavailable("Чтобы создать задачу необходимо сменить статус на 'aктуальная'");
                                      return;
                                    }
                                    else if(ai!.isChecked){
                                      showUnavailable("Чтобы создать задачу необходимо сменить статус на 'не достигнута'");
                                      return;
                                    }

                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigateToTaskCreateScreenEvent(ai!.id));
                                  }
                                },
                                child: const Text("Создать задачу",
                                  style: TextStyle(color: AppColors.greytextColor),)
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Укажи задачу дня для достижения цели. Помни! Задача актуальна 24 часа",
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.greytextColor),)
                          ],
                        ),
                        const SizedBox(height: 15,),
                        appVM.settings.treeView==0?MyTreeView(key: UniqueKey(),roots: roots, onTap: (id, type) => onTreeItemTap(appVM, id, type)):
                        TreeViewWidgetV2(key: UniqueKey(), root: roots.firstOrNull??MyTreeNode(id: -1, type: "a", title: "title", isChecked: true), onTap: (id,type) => onTreeItemTap(appVM, id, type),)
                      ]),
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
                      ])
            ));
    });
  }

  Future<bool> onSaveClick(AppViewModel appVM) async {
    if(ai!=null){
      if(text.text.isEmpty||description.text.isEmpty){
        await showDialog(context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Заполните поля'),
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
        ai!.text = text.text;
        ai!.description = description.text;
      }
      appVM.updateAim(ai!);
      setState(() {
        roots.clear();
        appVM.aimItems[appVM.aimItems.indexWhere((element) => element.id==ai!.id)]=AimItem(id: ai!.id, parentId: ai!.parentId, text: ai!.text, isChecked: ai!.isChecked, isActive: ai!.isActive);
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
    }
    return true;
  }
  Future<bool> showOnExit(AppViewModel appVM) async {
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
              await onSaveClick(appVM);
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
        contentPadding: const EdgeInsets.all(5),
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
  void showUneditable({String text = "Чтобы редактировать необходимо изменить статус на 'актуальное' нажав кнопку 'осознать'"}) {
    showDialog(context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  maxLines: 5, textAlign: TextAlign.center,),
                const SizedBox(height: 4,),
                const Divider(color: AppColors.dividerGreyColor,),
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
        contentPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: const Text("Внимание", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Статус цели не может быть изменен на 'не достигнута' пока вышестоящее желание не будет переведено в статус 'не исполнено'", maxLines: 5, textAlign: TextAlign.center,),
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
      appVM.startWishScreen(id, 0);
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
