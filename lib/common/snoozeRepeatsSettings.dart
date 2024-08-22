import 'package:flutter/cupertino.dart';
import 'package:wishmap/data/static.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import '../interface_widgets/sq_checkbox.dart';

class Snoozerepeatssettings extends StatefulWidget{
  int count = 1;
  Function(int count) onClose;

  Snoozerepeatssettings(this.count, this.onClose, {super.key});
  @override
  SnoozerepeatssettingsState createState() => SnoozerepeatssettingsState();
}

class SnoozerepeatssettingsState extends State<Snoozerepeatssettings>{
  final repeats = {
    0: 1,
    1: 2,
    2: 3,
    3: 4,
    4: 5,
    5: 10
  };

  @override
  Widget build(BuildContext context) {
    List<String> items = repeatCount.values.toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text("Количество повторений", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          ListView.builder(itemCount: items.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return SquareCheckbox(state: repeats[index]==widget.count, items[index], (state){setState(() {
                  widget.count = repeats[index]!;
                });});
              }),
          ColorRoundedButton("Применить", (){
            widget.onClose(widget.count);
          })
        ],
      ),
    );
  }

}