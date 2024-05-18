import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import '../import_extension/custom_pallete_hue_picker.dart';

class ColorPickerBS extends StatefulWidget {
  ColorPickerBS(this.currentColor, this.onClose, {super.key});

  Color currentColor;
  Function(Color c) onClose;

  @override
  ColorPickerBSState createState() => ColorPickerBSState();
}

class ColorPickerBSState extends State<ColorPickerBS>{
  late HSVColor hsvCurrent;
  late Color currentColor;

  @override
  void initState() {
    currentColor = widget.currentColor;
    super.initState();
  }

  void onChanged(HSVColor color) {
    currentColor = color.toColor();
    hsvCurrent = color;

  }

  @override
  Widget build(BuildContext context) {
    hsvCurrent = HSVColor.fromColor(currentColor);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          height: 640,
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 36),
                const Text('Выберите цвет', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                const SizedBox(height: 24),
                SizedBox(
                  width: constraints.maxWidth-32,
                  child: PaletteHuePicker(
                    palettePadding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    paletteHeight: 300,
                    paletteBorderRadius: const BorderRadius.all(Radius.circular(12)),
                    hueBorderRadius: const BorderRadius.all(Radius.circular(20)),
                    hueHeight: 40,
                    color: hsvCurrent,
                    onChanged: (value) => super.setState(() => onChanged(value)),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(22)),
                      color: currentColor
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ColorRoundedButton("Выбрать", () => widget.onClose(currentColor)),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}