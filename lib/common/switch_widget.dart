import 'package:flutter/cupertino.dart';

import '../res/colors.dart';

  class MySwitch extends StatefulWidget {
  bool value = false;
  bool enabled = true;
  Function(bool state) onChanged;
  MySwitch({super.key, required this.onChanged, this.value = false, this.enabled = true});
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
  void didUpdateWidget(MySwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      switchValue = widget.value;
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 2),
            width: 50.0, // Adjust the width of the switch
            height: 30.0, // Adjust the height of the switch
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: switchValue ? AppColors.switchBack : AppColors.greyBackButton,
            ),
            child: Row(
              mainAxisAlignment: switchValue
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Container(
                  width: 25.0, // Adjust the width of the thumb
                  height: 25.0, // Adjust the height of the thumb
                  decoration: BoxDecoration(
                    gradient: switchValue&&widget.enabled?const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]):null,
                    shape: BoxShape.circle,
                    color: switchValue&&widget.enabled ? null : AppColors.darkGrey,
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