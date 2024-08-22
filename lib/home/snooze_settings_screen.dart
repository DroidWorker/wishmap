import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/data/static.dart';

import '../common/snoozeRepeatsSettings.dart';
import '../common/switch_widget.dart';
import '../interface_widgets/sq_checkbox.dart';
import '../res/colors.dart';

class SnoozeSettingsScreen extends StatefulWidget{
  String snooze;
  Function(String snooze) onClose;
  SnoozeSettingsScreen(this.snooze, this.onClose, {super.key});

  @override
  SnoozeSettingsScreenState createState() => SnoozeSettingsScreenState();
}

class SnoozeSettingsScreenState extends State<SnoozeSettingsScreen>{
  int repCount = 0;
  int interval = 0;
  bool isOn = true;

  @override
  initState(){
    super.initState();

    if(widget.snooze.isNotEmpty){
      final sn = widget.snooze.split("|");
      interval = int.parse(sn[0]);
      repCount = int.parse(sn[1]);
    }
  }

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
                  widget.onClose(isOn?"$interval|$repCount":"");
                }
            ),
            const Text("Отложить", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Отложить"),
                          MySwitch(
                              value: isOn,
                              onChanged: (changed){isOn=!isOn;}
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            await showModalBottomSheet<void>(
                                backgroundColor: AppColors.backgroundColor,
                                context: context,
                                isScrollControlled: true,
                              builder: (BuildContext context) {
                                return Snoozerepeatssettings(repCount, (count){
                                  setState(() {
                                    repCount = count;
                                  });
                                  Navigator.pop(context);
                                });
                              }
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Text("Сколько раз"),
                                const Spacer(),
                                Text(repeatCount[repCount]??"$repCount pаз"),
                                const Icon(Icons.arrow_forward_ios)
                              ],
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.grey, indent: 5.0, endIndent: 5.0,),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: repeatInterval.length,
                            itemBuilder: (context, index) {
                              return SquareCheckbox(state: index==interval, repeatInterval[index], (state){setState(() {
                                interval = index;
                              });
                              }
                              );}
                        )
                      ],
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
}