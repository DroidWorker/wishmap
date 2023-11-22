import 'package:flutter/material.dart';
import "package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart";

typedef ValueCallback<T> = void Function(T value);
class ColorPickerWidget extends StatefulWidget {
  final ValueCallback<Color> onColorSelected;
  final Color? initColor;
  const ColorPickerWidget({super.key, required this.onColorSelected, required this.initColor});

  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  Color selectedColor = Colors.blue;

  Color currentColor = Colors.red;
  HSVColor hsvCurrent = HSVColor.fromColor(Colors.red);

  @override
  void initState() {
    if(widget.initColor!=null) {
      currentColor = widget.initColor!;
      hsvCurrent = HSVColor.fromColor(widget.initColor!);
    }
    super.initState();
  }

  void onChanged(HSVColor color) {
    currentColor = color.toColor();
    hsvCurrent = color;
    widget.onColorSelected(currentColor);
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.redAccent,
      Colors.grey,
      Colors.brown,
      Colors.yellowAccent,
      Colors.pink,
      Colors.orangeAccent,
      Colors.deepPurple,
      Colors.deepOrange,
      Colors.cyanAccent,
      Colors.blueGrey,
      Colors.purple,
      Colors.amber,
    ];

    return AlertDialog(
          content: IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: currentColor,
                    ),
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, // Количество столбцов
                        ),
                        itemCount: colors.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Обработка нажатия на квадратик
                              final selectedColor = colors[index];
                              setState(() {
                                onChanged(HSVColor.fromColor(colors[index]));
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              width: 9.0,
                              height: 9.0,
                              color: colors[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: 120,
                  child: PaletteHuePicker(
                    palettePadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    paletteHeight: 140,
                    hueBorderRadius: const BorderRadius.all(Radius.circular(6)),
                    hueHeight: 20,
                    color: hsvCurrent,
                    onChanged: (value) => super.setState(() => onChanged(value)),
                  ),
                ),
              ],
            ),
          )
    );
  }
}