import 'package:emoji_choose/emoji_choose.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../ViewModel.dart';
import '../data/models.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class DiaryEditScreen extends StatefulWidget {
  int diaryId = 0;
  DiaryEditScreen({super.key, required this.diaryId});
  @override
  DiaryEditScreenState createState()=>DiaryEditScreenState();
}

class DiaryEditScreenState extends State<DiaryEditScreen>{
  var isDataloaded = false;
  String currentEmoji = "❤️";
  String currentTitle = "Благодарность";
  String currentSubtitle = "";
  String currentdescription = "";
  final tec = TextEditingController();
  final tectitle = TextEditingController();
  final tecsubtitle = TextEditingController();
  final tecdescription = TextEditingController();
  @override
  Widget build(BuildContext context) {
    tec.addListener(() { currentEmoji = tec.text; });
    tectitle.addListener(() { currentTitle = tectitle.text; });
    tecsubtitle.addListener(() { currentSubtitle = tecsubtitle.text; });
    tecdescription.addListener(() { currentdescription = tecdescription.text; });
     return Consumer<AppViewModel>(
        builder: (context, appVM, child){
          CardData diaryItem=appVM.diaryItems.firstWhere((element) => element.id == widget.diaryId, orElse: ()=>CardData(id: -1, emoji: "", title: "", description: "", text: "", color: Colors.transparent));
          if(diaryItem.id!=-1&&!isDataloaded){
            currentEmoji = diaryItem.emoji;
            currentTitle = diaryItem.title;
            currentSubtitle = diaryItem.description;
            currentdescription = diaryItem.text;
            isDataloaded=true;
          }
          tec.text =currentEmoji;
          tectitle.text =currentTitle;
          tecsubtitle.text =currentSubtitle;
          tecdescription.text =currentdescription;
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(child:
            Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        child: const Text("<Назад", style: TextStyle(color: AppColors.greytextColor, fontSize: 16),),
                        onTap: (){
                          appVM.updateDiary(CardData(id: diaryItem.id, emoji: currentEmoji, title: currentTitle, description: currentSubtitle, text: currentdescription, color: diaryItem.color));
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigateToDiaryScreenEvent());
                        },
                      ),),
                  ),
                  GestureDetector(
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return EmojiChoose(
                              rows: 7,
                              columns: 7,
                              buttonMode: ButtonMode.MATERIAL,
                              recommendKeywords: const ["gratitude", "target", "laughter", "cup", "dream", "fear", "wish"],
                              numRecommended: 20,
                              onEmojiSelected: (emoji, category) {
                                setState(() {
                                  currentEmoji=emoji.emoji;
                                });
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          currentEmoji,
                          style: const TextStyle(fontSize: 50),
                        ),
                      )
                  ),
                  TextField(
                    controller: tectitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.greytextColor, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: currentTitle,
                    ),
                  ),
                  TextField(
                    controller: tecsubtitle,
                    maxLines: 3,
                    minLines: 3,
                    style: const TextStyle(color:  AppColors.greytextColor, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: currentTitle,
                    ),
                  ),
                  TextField(
                    controller: tecdescription,
                    maxLines: 10,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: currentTitle,
                    ),
                  ),
                ],
              ),
            )
            ),
          );
    });
  }

}