import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../ViewModel.dart';
import '../../common/switch_widget.dart';
import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class SoundsSettings extends StatefulWidget{

  @override
  SoundsSettingsState createState() => SoundsSettingsState();
}

class SoundsSettingsState extends State<SoundsSettings>{
    @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    if(appViewModel.audioList.isEmpty) {
      appViewModel.loadCachedTrackNames();
      appViewModel.getAudioList();
      appViewModel.getAudio();
    }
      return Consumer<AppViewModel>(
          builder: (context, appViewModel, child) {
            return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
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
                                  BlocProvider.of<NavigationBloc>(context).handleBackPress();
                                }
                            ),
                            const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Звуки", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                Text("Загрузите терки для плей-листа", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.greytextColor),)
                              ],
                            ),
                            const SizedBox(width: 28),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        appViewModel.audioList.isEmpty?const Text("Loading..."):
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: appViewModel.audioList.length,
                          itemBuilder: (context, index) {
                            final name = appViewModel.audioList.keys.toList()[index];
                            if(appViewModel.inProgress.keys.firstWhere((element) => element.contains(name), orElse: () => "")!="")print("aaaaaooooaaaa${appViewModel.inProgress[appViewModel.inProgress.keys.firstWhere((element) => element.contains(name))]?.toDouble()}");
                            return Row(children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: AppColors.oceanBgColor),
                                child: SvgPicture.asset("assets/icons/music.svg"),
                              ),
                              const SizedBox(width: 10),
                              Text(name),
                              const Spacer(),
                              IconButton(onPressed: () async {
                                final loadId = await appViewModel.cacheTrack(name,appViewModel.audioList[name]!);
                                setState(() {
                                  if(loadId!=null)appViewModel.inProgress[name+loadId] = 0;
                                });
                              }, icon: appViewModel.inProgress.keys.where((element) => element.contains(name)).isNotEmpty? CircularProgressIndicator(value: appViewModel.inProgress[appViewModel.inProgress.keys.firstWhere((element) => element.contains(name))]!.toDouble()/100,) : appViewModel.audios.keys.contains(name)? const Icon(Icons.check): const Icon(Icons.download))
                            ],);
                          },
                        ),
                      ],
                    ),
                  )
              ),
            );
          }
          );
    }
  }

  Widget buildSettingItem(String title, String subtitle, bool isActive, Function(bool changed) onChanged){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, color: Colors.black),),
            Text(subtitle, maxLines: 2, style: const TextStyle(fontSize: 14, color: AppColors.greytextColor),)
          ],
        )),
        MySwitch(
            value: isActive,
            onChanged: (changed){onChanged(changed);}
        )
      ],);
}