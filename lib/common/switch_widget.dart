import 'package:flutter/cupertino.dart';

import '../res/colors.dart';

class MySwitch extends StatefulWidget {
  bool value = false;
  Function(bool state) onChanged;
  MySwitch({super.key, required this.onChanged, this.value = false});
  @override
  _MyCustomSwitchState createState() => _MyCustomSwitchState();
}

class _MyCustomSwitchState extends State<MySwitch> {
  late bool switchValue;

  @override
  void initState() {
    switchValue = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              switchValue = !switchValue;
              widget.onChanged(switchValue);
            });
          },
          child: Container(
            width: 50.0, // Adjust the width of the switch
            height: 30.0, // Adjust the height of the switch
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: switchValue ? AppColors.pinkButtonTextColor : AppColors.greyBackButton,
            ),
            child: Row(
              mainAxisAlignment: switchValue
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Container(
                  width: 28.0, // Adjust the width of the thumb
                  height: 28.0, // Adjust the height of the thumb
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}