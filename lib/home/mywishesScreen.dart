import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/wishItem_widget.dart';
import '../ViewModel.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class WishesScreen extends StatefulWidget {
  WishesScreen({super.key});

  @override
  _WishesScreenState createState() => _WishesScreenState();
}

class _WishesScreenState extends State<WishesScreen>{
  bool page = false;//false - Исполнено true - Все желания
  List<WishItem> allWishList = [];
  List<WishItem> filteredWishList = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          allWishList = appVM.wishItems;
          filteredWishList = appVM.wishItems;
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(child: Padding(
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
                      child: !page
                          ? const Text("Все желания",
                          style: TextStyle(decoration: TextDecoration.underline))
                          : const Text("Все желания"),
                      onTap: () {
                        setState(() {
                          page = !page;
                          filterAims(!page);
                        });
                      },
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      child: page
                          ? const Text("Исполнено",
                          style: TextStyle(decoration: TextDecoration.underline))
                          : const Text("Исполнено"),
                      onTap: () {
                        setState(() {
                          page = !page;
                          filterAims(!page);
                        });
                      },
                    )
                  ],),
                  Expanded(child:
                  ListView.builder(
                      itemCount: filteredWishList.length,
                      itemBuilder: (context, index) {
                        return WishItemWidget(ti: filteredWishList[index],
                          onClick: onItemClick,
                          onDelete: onItemDelete,);
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
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToMainScreenEvent());
                      },
                      child: const Text("Добавить",
                          style: TextStyle(color: AppColors.greytextColor))
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
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigateToAimsScreenEvent());
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
                          onPressed: () {

                          },
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
    });
  }
  filterAims(bool isAll){
    setState(() {
      !isAll?filteredWishList = allWishList.where((element) => element.isChecked).toList():
      filteredWishList = allWishList;
    });
  }

  onItemClick(int id){
    setState((){
      filteredWishList.where((element) => element.id==id).forEach((element) {element.isChecked=!element.isChecked;});
    });
  }
  onItemDelete(int id){
    setState(() {
      filteredWishList.removeWhere((element) => element.id==id);
    });
  }
}
