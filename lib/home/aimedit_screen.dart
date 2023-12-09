import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/treeview_widget.dart';
import '../ViewModel.dart';
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

  @override
  Widget build(BuildContext context) {
    text.addListener(() { if(ai?.text!=text.text)isChanged = true;});
    description.addListener(() { if(ai?.description!=description.text)isChanged = true;});
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          ai ??= appVM.currentAim??AimData(id: -1, parentId: -1, text: 'объект не найден', description: "", isChecked: false);
          if(roots.isEmpty&&ai!=null)appVM.convertToMyTreeNode(CircleData(id: ai!.id, text: ai!.text, color: Colors.transparent, parenId: ai!.parentId, isChecked: ai!.isChecked));
          roots = appVM.myNodes;
          text.text = ai?.text??"Загрузка...";
          description.text = ai?.description??"";
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
                maintainBottomViewPadding: true,
                child: LayoutBuilder(
                    builder: (context, constraints) {
                      return  Column(children:[ Expanded(child:Padding(
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
                                if(text.text.isNotEmpty&&description.text.isNotEmpty&&isChanged){
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
                                  if(ai!=null){
                                    showDialog(context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        contentPadding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                        title: const Text('Внимание', textAlign: TextAlign.center,),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            (!ai!.isChecked)?const Text("Если в данной цели создавались задачи, то они также получат статус 'выполнена'", maxLines: 6, textAlign: TextAlign.center,):
                                            const Text("Если в данной цели создавались другие задачи, то они останутся в статусе 'выполнена'", maxLines: 6, textAlign: TextAlign.center,),
                                            const SizedBox(height: 4,),
                                            const Divider(color: AppColors.dividerGreyColor,),
                                            const SizedBox(height: 4,),
                                            (ai!.isChecked)?const Text("Не Достигнута?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),):
                                            const Text("Достигнута?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () { Navigator.pop(context, 'OK');
                                            ai!.isChecked=!ai!.isChecked;
                                            appVM.updateAimStatus(ai!.id, ai!.isChecked);
                                            showDialog(context: context,
                                              builder: (BuildContext context) => AlertDialog(
                                                title: ai!.isChecked?const Text('Достигнута'):const Text('не Достигнута'),
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
                                      content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Если в данной цели создавались задачи, то они также будут удалены", maxLines: 4, textAlign: TextAlign.center,),
                                          SizedBox(height: 4,),
                                          Divider(color: AppColors.dividerGreyColor,),
                                          SizedBox(height: 4,),
                                          Text("Удалить?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () { Navigator.pop(context, 'OK');
                                          appVM.deleteAim(widget.aimId);
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
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.greyBackButton,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () async {
                                  onSaveClick(appVM);
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
                    const SizedBox(height: 15,),
                    TextField(
                      controller: text,
                      style: const TextStyle(color: Colors.black), // Черный текст ввода
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fieldFillColor,
                          hintText: 'Название',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                          border: InputBorder.none
                      ),
                    ),
                    const SizedBox(height: 15,),
                    TextField(
                      controller: description,
                      style: const TextStyle(color: Colors.black), // Черный текст ввода
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fieldFillColor,
                          hintText: 'Описание',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                          border: InputBorder.none
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
                    MyTreeView(key: UniqueKey(),roots: roots, onTap: (id, type){
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
                      }else if(type=="a"&&widget.aimId!=id){
                        appVM.getAim(id);
                        BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToAimEditScreenEvent(id));
                      }else if(type=="t"){
                        appVM.currentTask=null;
                        appVM.getTask(id);
                        BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToTaskEditScreenEvent(id));
                      }
                    },),
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
                    ),)]);})
            ));
    });
  }

  void onSaveClick(AppViewModel appVM){
    if(ai!=null){
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
        ai!.text = text.text;
        ai!.description = description.text;
      }
      appVM.updateAim(ai!);
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
  }
}
