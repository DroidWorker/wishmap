import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/common/aimitem_widget.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AimsScreen extends StatefulWidget {
  AimsScreen({super.key, required this.aimsList});

  @override
  _AimsScreenState createState() => _AimsScreenState();

  List<AimItem> aimsList;
}

class _AimsScreenState extends State<AimsScreen>{
  bool page = false;//false - Исполнено true - Все желания
  late List<AimItem> filteredAimList;

  @override
  void initState() {
    filteredAimList = widget.aimsList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(child:Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  iconSize: 30,
                  onPressed: () {},
                ),
                const Spacer(),
                const Text("Мои желания", style: TextStyle(fontSize: 18),),
                const Spacer(),
              ],
              ),
              const SizedBox(height: 20),
              Row(children: [
                GestureDetector(
                  child: !page ? const Text("Все цели", style: TextStyle(decoration: TextDecoration.underline)) : const Text("Все цели"),
                  onTap: (){
                    setState(() {
                      page = !page;
                      filterAims(!page);
                    });
                  },
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  child: page ? const Text("Достигнуты", style: TextStyle(decoration: TextDecoration.underline)) : const Text("Достигнуты"),
                  onTap: (){
                    setState(() {
                      page = !page;
                      filterAims(!page);
                    });
                  },
                )
              ],),
              Expanded(child:
              ListView.builder(
                  itemCount: filteredAimList.length,
                  itemBuilder: (context, index){
                    return AimItemWidget(ai: filteredAimList[index], onClick: onItemClick, onDelete: onItemDelete);
                  }
              ),),
              const SizedBox(height: 10),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.fieldFillColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // <-- Radius
                    ),
                  ),
                  onPressed: (){
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigateToAimCreateScreenEvent());
                  },
                  child: const Text("Добавить", style: TextStyle(color: AppColors.greytextColor),)
              ),
              const SizedBox(height: 20),
              const Divider(
                height: 10,
                thickness: 5,
                indent: 0,
                endIndent: 0,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/icons/checklist2665651.png'),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToTasksScreenEvent());
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/goal6002764.png'),
                      iconSize: 30,
                      onPressed: () {

                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/wheel2526426.png'),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToAimsScreenEvent());
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/notelove1648387.png'),
                      iconSize: 30,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Image.asset('assets/icons/notepad2725914.png'),
                      iconSize: 30,
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToProfileScreenEvent());
                      },
                    )
                  ],
                ),)
            ],
          ),
        )
    ));
  }

  filterAims(bool isAll){
    setState(() {
      !isAll?filteredAimList = widget.aimsList.where((element) => element.isChecked).toList():
        filteredAimList = widget.aimsList;
    });
  }

  onItemClick(int id){
    setState((){
      filteredAimList.where((element) => element.id==id).forEach((element) {element.isChecked=!element.isChecked;});
    });
  }
  onItemDelete(int id){
    setState(() {
      filteredAimList.removeWhere((element) => element.id==id);
    });
  }
}
