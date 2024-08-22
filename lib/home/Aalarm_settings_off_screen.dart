import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import '../import_extension/custom_string_picker.dart';
import '../res/colors.dart';

class AlarmSettingsOffScreen extends StatelessWidget{
  final Function(int type, Map<String, String> params) onClose;
  final List<int> offMods;
  AlarmSettingsOffScreen(this.onClose, this.offMods, {super.key});

  int type = -1;
  Map<String, String> params = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                onPressed: () {
                  onClose(-1, {});
                }
            ),
            const Text("Отключение будильника", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(width: 40, height: 40,)
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(offMods.contains(0))InkWell(
                    onTap: () async {
                      final p = await _showBottomSheet(context, 0);
                      if(p==null) return;
                      params.addAll(p);
                      type = 0;
                      onClose(type, params);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                            margin: const EdgeInsets.all(13),
                            child: SvgPicture.asset('assets/icons/tablerswipe.svg', height: 20, width: 20),
                          ),
                          const Text("Свайп желаний")
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if(offMods.contains(1))InkWell(
                    onTap: () async {
                      final p = await _showBottomSheet(context, 1);
                      if(p==null) return;
                      params.addAll(p);
                      type = 1;
                      onClose(type, params);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                            margin: const EdgeInsets.all(13),
                            child: SvgPicture.asset('assets/icons/fluenttasklist.svg', height: 20, width: 20),
                          ),
                          const Text("Разделение задач")
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final p = await _showBottomSheet(context, 2);
                      if(p==null) return;
                      params.addAll(p);
                      type = 2;
                      onClose(type, params);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                            margin: const EdgeInsets.all(13),
                            child: SvgPicture.asset('assets/icons/magemessage.svg', height: 20, width: 20),
                          ),
                          const Text("Выбор аффирмаций дня")
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<Map<String, String>?> _showBottomSheet(BuildContext context, int offType) async{
    const swipesCount = ["5", "10", "20", "30", "40", "50","все", "", "", ""];
    Map<String, String> resultParams = offType==1?{"TaskSwipesCount": "10"}:offType==0?{"WishSwipesCount": "10"}:{};
    return await showModalBottomSheet(backgroundColor: AppColors.backgroundColor,
        context: context,
        isScrollControlled: true,
        builder: (buildContext){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          offType==0?
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black])),
                      child: Image.asset('assets/icons/vodopad.png', fit: BoxFit.fitWidth,),
                    ),
                    const SizedBox(height: 16,),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.lightGrey),
                        child: Stack(
                          children: [
                            Center(
                              child: StringPicker(minValue: 0, maxValue: 6, value: 1, text: swipesCount, onChanged: (v){
                                resultParams["WishSwipesCount"] = swipesCount[v];
                              }),
                            ),
                            const Positioned(
                              right: 40,
                              bottom: 0,
                              top: 0,
                              child: Align(
                                alignment: Alignment.centerRight,
                                  child: Text("Свайпов", style: TextStyle(fontSize: 12))
                              ),
                            )
                          ]
                        )
                    )
                  ],
                ),
              )
              :offType==1?
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset('assets/icons/incorrectgradient.png', fit: BoxFit.fitWidth),
                const SizedBox(height: 16,),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.lightGrey),
                  child: Stack(
                      children: [
                        Center(
                          child: StringPicker(minValue: 0, maxValue: 6, value: 1, text: swipesCount, onChanged: (v){
                            resultParams["TaskSwipesCount"] = swipesCount[v];
                          }),
                        ),
                        const Positioned(
                          right: 40,
                          bottom: 0,
                          top: 0,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Text("Свайпов", style: TextStyle(fontSize: 12))
                          ),
                        )
                      ]
                  ),
                )
              ],
            ),
          ):
          Padding(
              padding: const EdgeInsets.all(16),
            child: Image.asset('assets/icons/affirmationsoffscreen.png', fit: BoxFit.fitWidth),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ColorRoundedButton("Сохранить", (){
              print("hhhhhhhffffffffffffffffff${resultParams}");
              Navigator.pop(context, resultParams);
            }),
          )
        ],
      );
    });
  }
}