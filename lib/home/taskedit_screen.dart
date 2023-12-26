import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../ViewModel.dart';
import '../common/EditTextOverlay.dart';
import '../data/models.dart';
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

  @override
  Widget build(BuildContext context) {
    text.addListener(() { if(ai?.text!=text.text)isChanged = true;});
    description.addListener(() { if(ai?.text!=text.text)isChanged = true;});
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          ai = appVM.currentTask??TaskData(id: -1, parentId: -1, text: 'объект не найден', description: "", isChecked: false);
          if(appVM.currentAim!=null) {
            AimData ad = appVM.currentAim!;
            isParentChecked = ad.isChecked;
            var childNodes = MyTreeNode(id: ad.id, type: 'a', title: ad.text, isChecked: ad.isChecked, children: []);
            print('dddddddddddddddddddd${childNodes} ${ai!.id} ${ad.parentId}');
            if(roots.isEmpty&&ai!=null)appVM.convertToMyTreeNodeIncludedAimsTasks(childNodes, ai!.id, ad.parentId);
          }else {
            if(ai!.parentId!=-1)appVM.getAim(ai!.parentId);
          }
          roots=appVM.myNodes;
          text.text = ai!.text;
          description.text = ai!.description;
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
                child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(children:[Padding(
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
                              icon: const Icon(Icons.keyboard_arrow_left),
                              iconSize: 30,
                              onPressed: () {
                                if(ai!=null&&!ai!.isChecked&&text.text.isNotEmpty&&description.text.isNotEmpty&&isChanged){
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
                                          BlocProvider.of<NavigationBloc>(context)
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
                                  );}else{
                                  BlocProvider.of<NavigationBloc>(context)
                                      .handleBackPress();
                                }
                              },
                            ),
                            const Spacer(),
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: ai!.isChecked?AppColors.pinkButtonTextColor:AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  if(isParentChecked) {
                                    showCantChangeStatus();
                                  } else {
                                    appVM.updateTaskStatus(
                                        ai!.id, !ai!.isChecked);
                                    showDialog(context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: ai!.isChecked ? const Text(
                                                'выполнена') : const Text(
                                                ' не выполнена'),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(32.0))),
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
                                  }
                                },
                                child: const Text("Выполнена",style: TextStyle(color: Colors.black, fontSize: 12))
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
                                  appVM.deleteTask(ai!.id);
                                  showDialog(context: context,
                                    builder: (BuildContext c) => AlertDialog(
                                      title: const Text('удаленa'),
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
                                child: const Text("Удалить",style: TextStyle(color: Colors.black, fontSize: 12))
                            ),
                            const SizedBox(width: 3,),
                            ai!=null&&!ai!.isActive?
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    appVM.activateTask(ai!.id, true);
                                    ai!.isActive = true;
                                  });
                                },
                                child: const Text("Актуализировать",
                                    style: TextStyle(color: AppColors.blueTextColor, fontSize: 12))
                            ):TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  (!ai!.isChecked)?onSaveClicked(appVM, ai!):showUnavailable();
                                },
                                child: const Text("Cохранить задачу",
                                  style: TextStyle(color: AppColors.blueTextColor, fontSize: 12),)
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
                    TextField(
                      onTap: (){if(ai!.isChecked)showUnavailable();},
                      controller: text,
                      showCursor: true,
                      readOnly: ai!=null?(ai!.isChecked||!ai!.isActive?true:false):false,
                      style: const TextStyle(color: Colors.black), // Черный текст ввода
                      decoration: InputDecoration(
                          filled: true,
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
                        if(ai!.isChecked){showUnavailable();}
                        else if(!ai!.isActive){showUneditable();}
                        else {
                          description.text = await showOverlayedEdittext(context, description.text, (ai!.isActive&&!ai!.isChecked))??"";
                          appVM.isChanged= true;
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
                        fillColor: ai!=null?(ai!.isChecked?AppColors.fieldLockColor:!ai!.isActive?AppColors.fieldInactive:AppColors.fieldFillColor):AppColors.fieldFillColor,
                        hintText: 'Описание', // Базовый текст
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                      ),
                    ),
                    const SizedBox(height: 15,),
                    MyTreeView(key: UniqueKey(),roots: roots, onTap: (id,type){
                      if(type=="m"){
                        BlocProvider.of<NavigationBloc>(context).clearHistory();
                        appVM.cachedImages.clear();
                        appVM.startMainsphereeditScreen();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainSphereEditScreenEvent());
                      }else if(type=="w"){
                        BlocProvider.of<NavigationBloc>(context).clearHistory();
                        appVM.cachedImages.clear();
                        appVM.wishScreenState=null;
                        appVM.startWishScreen(id, 0);
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToWishScreenEvent());
                      }else if(type=="a"){
                        appVM.getAim(id);
                        BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToAimEditScreenEvent(id));
                      }else if(type=="t"&&ai!.id!=id){
                        appVM.getTask(id);
                        BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToTaskEditScreenEvent(id));
                      }
                    },),
                  ]
              ),
        ),
                  if(MediaQuery.of(context).viewInsets.bottom!=0) SizedBox(height: 30,
                    child: FooterLayout(
                      footer: Container(height: 30,color: Colors.white,alignment: Alignment.centerRight, child:
                      GestureDetector(
                        onTap: (){FocusManager.instance.primaryFocus?.unfocus();},
                        child: const Text("готово", style: TextStyle(fontSize: 20),),
                      )
                        ,),
                    ),)
            ]);}))
    );
  });
  }
  void onSaveClicked(AppViewModel appVM, TaskData ai){
    if(text.text.isEmpty||description.text.isEmpty){
      showDialog(context: context,
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
      return;
    }else{
      ai.text = text.text;
      ai.description = description.text;
    }
    appVM.updateTask(ai);
    isChanged = false;
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

  void showUnavailable(){
    showDialog(context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Чтобы редактировать задачу необходимо сменить статус \nна 'не выполнена'", maxLines: 5, textAlign: TextAlign.center,),
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
}
