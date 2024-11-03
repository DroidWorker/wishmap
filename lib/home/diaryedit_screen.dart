import 'package:collection/collection.dart';
import 'package:emoji_choose/emoji_choose.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../ViewModel.dart';
import '../common/bottombar.dart';
import '../common/diary_article_item.dart';
import '../common/diary_edittext_overlay.dart';
import '../data/models.dart';
import '../dialog/bottom_sheet_action.dart';
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
  var isDescripttionOver = false;

  var edittextActive = false;
  int? tappedArticleId;

  @override
  Widget build(BuildContext context) {
    tec.addListener(() { currentEmoji = tec.text; });
    tecsubtitle.addListener(() {
        currentSubtitle = tecsubtitle.text;
    });
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
          return edittextActive?
          MyDETOverlay(isActive: true, text: tappedArticleId==null?"":appVM.articles.firstWhere((article) => article.id==tappedArticleId).text, article: appVM.articles.firstWhereOrNull((article) => article.id==tappedArticleId), onClose: (text, attachmentsList, articleId){
            if(text.isNotEmpty){
              articleId==null?appVM.addDiaryArticle(text, attachmentsList, widget.diaryId):appVM.updateDiaryArticle(text, attachmentsList, articleId);
            }
            setState(() {
              edittextActive = false;
              tappedArticleId=null;
            });
          }):Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(maintainBottomViewPadding: true,
                child:Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children:[
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
                              appVM.updateDiary(CardData(id: diaryItem.id, emoji: currentEmoji, title: currentTitle, description: currentSubtitle, text: currentdescription, color: diaryItem.color));
                              BlocProvider.of<NavigationBloc>(context).handleBackPress();
                            }
                        ),
                        Expanded(
                          child: TextButton(onPressed: () async {
                            currentTitle = (await showDiaryOverlayedEdittext(context, currentTitle, null, false)).keys.firstOrNull??"";
                            setState(() {});
                          },
                              child: Text(currentTitle, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16))
                          ),
                        ),
                        if(widget.diaryId > 6)IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                          ),
                          icon: SvgPicture.asset("assets/icons/trash.svg", width: 24, height: 24),
                          onPressed: () {
                            showModalBottomSheet<bool>(
                              backgroundColor: AppColors.backgroundColor,
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return ActionBS('Удалить', "", "Да", 'Нет',
                                    onOk: () async {
                                      Navigator.pop(context, true);
                                      appVM.deleteDiary(widget.diaryId);
                                      BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                    },
                                    onCancel: () { Navigator.pop(context, true);
                                    appVM.isChanged=false;}
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: appVM.articles.length+1,
                          itemBuilder: (context, index){
                            return index==0? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet<void>(
                                        backgroundColor: AppColors.backgroundColor,
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
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 100,
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: diaryItem.color,
                                              borderRadius: const BorderRadius.all(Radius.circular(16))
                                          ),
                                          alignment: Alignment.center,
                                          child: Center(
                                            child: Text(
                                              currentEmoji,
                                              style: const TextStyle(fontSize: 50),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              height: 20, width: 20,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4),
                                                color: Colors.white,
                                              ),
                                              child: const Icon(Icons.edit, size: 10,),
                                            ))
                                      ],
                                    )
                                ),
                                const SizedBox(height: 24),
                                currentSubtitle.isNotEmpty?TextField(
                                  controller: tecsubtitle,
                                  readOnly: true,
                                  showCursor: false,
                                  onTap: () async {
                                    currentSubtitle = (await showDiaryOverlayedEdittext(context, currentSubtitle, null, false)).keys.firstOrNull??"";
                                    setState(() {});
                                  },
                                  maxLines: 3,
                                  minLines: 3,
                                  maxLength: 110,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(16,8,16,8),
                                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.etGrey)),
                                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.etGrey)),
                                    errorText: isDescripttionOver? 'максимальная длина текста 130 символов':null,
                                  ),
                                  style: const TextStyle(color:  AppColors.greytextColor, fontSize: 16),
                                ):GestureDetector(
                                  onTap: () async {
                                    currentSubtitle =
                                        (await showDiaryOverlayedEdittext(
                                            context, currentSubtitle, null,
                                            false)).keys.firstOrNull ?? "";
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 60,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.etGrey)
                                    ),
                                    child: const Text("Описание", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.etGrey),),
                                  ),
                                ),
                                const SizedBox(height: 14)
                              ],
                            ) :DiaryArticleItem(appVM.articles[index-1], onEdit: (){
                              setState(() {
                                tappedArticleId = appVM.articles[index-1].id;
                                edittextActive = true;
                              });
                            },
                            onDelete: (){
                              setState(() {
                                appVM.deleteDiaryArticle(appVM.articles[index-1].id);
                              });
                            },);
                          }
                      ),
                    )
                    ]
                  ),
                )
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                setState(() {
                  tappedArticleId=null;
                  edittextActive = true;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd])
                ),
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                ),
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
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToMainScreenEvent());
              },
              onWishesTap: (){
                appVM.startMyWishesScreen();
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToWishesScreenEvent());
              },
              onDiaryTap: (){},
            ),
          );
    });
  }

}