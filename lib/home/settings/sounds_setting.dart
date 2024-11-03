import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/gallery_widget.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/interface_widgets/outlined_button.dart';

import '../../ViewModel.dart';
import '../../common/switch_widget.dart';
import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class SoundsSettings extends StatefulWidget {
  @override
  SoundsSettingsState createState() => SoundsSettingsState();
}

class SoundsSettingsState extends State<SoundsSettings> {
  bool trashModeActive = false;
  List<int> deleteQueue = [];

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    if (appViewModel.audioList.isEmpty) {
      appViewModel.loadCachedTrackNames();
      appViewModel.getAudioList();
      appViewModel.getAudio();
    }

    return Consumer<AppViewModel>(builder: (context, appViewModel, child) {
      return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // the '2023' part
                        ),
                        icon: const Icon(Icons.keyboard_arrow_left,
                            size: 28, color: AppColors.gradientStart),
                        onPressed: () {
                          BlocProvider.of<NavigationBloc>(context)
                              .handleBackPress();
                        }),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Звуки",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(
                          "Загрузите терки для плей-листа",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greytextColor),
                        )
                      ],
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap, // the '2023' part
                      ),
                      icon: SvgPicture.asset("assets/icons/trash.svg",
                          width: 28, height: 28),
                      onPressed: () {
                        setState(() {
                          trashModeActive = !trashModeActive;
                          deleteQueue.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                appViewModel.audioList.isEmpty
                    ? const Text("Loading...")
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: appViewModel.audioList.length,
                        itemBuilder: (context, index) {
                          final name =
                              appViewModel.audioList.keys.toList()[index];
                          return InkWell(
                            onTap: trashModeActive
                                ? () {
                              if (appViewModel.inProgress.keys.where((element) => element.contains(name)).isNotEmpty) return;
                                    deleteQueue.contains(index)?deleteQueue.remove(index):deleteQueue.add(index);
                                    setState(() {});
                                  }
                                : null,
                            child: Container(
                              decoration: deleteQueue.contains(index)
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.buttonBackRed,
                                          width: 1))
                                  : null,
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: AppColors.oceanBgColor),
                                    child: Center(
                                        child: SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: SvgPicture.asset(
                                                "assets/icons/music.svg"))),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(name,
                                          overflow: TextOverflow.ellipsis)),
                                  IconButton(
                                      onPressed: () async {
                                        if (appViewModel.inProgress.keys
                                                .where((element) =>
                                                    element.contains(name))
                                                .isNotEmpty ||
                                            appViewModel.audios.keys
                                                .contains(name)) return;

                                        final loadId =
                                            await appViewModel.cacheTrack(name,
                                                appViewModel.audioList[name]!);
                                        setState(() {
                                          if (loadId != null)
                                            appViewModel
                                                .inProgress[name + loadId] = 0;
                                        });
                                      },
                                      icon: appViewModel.inProgress.keys
                                              .where((element) =>
                                                  element.contains(name))
                                              .isNotEmpty
                                          ? CircularProgressIndicator(
                                              value: appViewModel
                                                      .inProgress[appViewModel
                                                          .inProgress.keys
                                                          .firstWhere((element) =>
                                                              element.contains(
                                                                  name))]!
                                                      .toDouble() /
                                                  100,
                                            )
                                          : appViewModel.audios.keys
                                                  .contains(name)
                                              ? const Icon(Icons.check)
                                              : const Icon(Icons.download))
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 22),
                OutlinedGradientButton("Добавить трек", () async {
                  appViewModel.allowSkipAuth = true;
                  final path = await _pickAudio();
                  if (path != null) {
                    await appViewModel.saveLocalTrack(path);
                    setState(() {});
                  }
                })
              ],
            ),
          )),
          bottomNavigationBar: trashModeActive
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ColorRoundedButton("Удалить", c: AppColors.buttonBackRed, () {
                  appViewModel.deleteTracks(appViewModel.audioList.keys.toList().whereIndexed((i, e)=>deleteQueue.contains(i)).toList());
                    deleteQueue.clear();
                    setState(() {
                      trashModeActive = false;
                    });
                  }),
              )
              : null);
    });
  }

  Future<String?> _pickAudio() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      String? filepath = result.files.single.path;
      if (filepath != null) {
        return filepath;
      }
    }
    return null;
  }
}

Widget buildSettingItem(String title, String subtitle, bool isActive,
    Function(bool changed) onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          Text(
            subtitle,
            maxLines: 2,
            style:
                const TextStyle(fontSize: 14, color: AppColors.greytextColor),
          )
        ],
      )),
      MySwitch(
          value: isActive,
          onChanged: (changed) {
            onChanged(changed);
          })
    ],
  );
}
