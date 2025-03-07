import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

import 'custom_slider_color_picker.dart' as slPicker;

/// Color palette and color slider.
class PaletteHuePicker extends StatefulWidget {
  const PaletteHuePicker({
    required this.color,
    required this.onChanged,
    this.paletteHeight = 280,
    this.palettePadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 20,
    ),
    this.hueBorder,
    this.hueBorderRadius,
    this.hueHeight = 40,
    this.paletteBorder,
    this.paletteBorderRadius,
    Key? key,
  }) : super(key: key);

  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;
  final double paletteHeight;
  final EdgeInsets palettePadding;
  final Border? hueBorder;
  final double hueHeight;
  final BorderRadius? hueBorderRadius;
  final Border? paletteBorder;
  final BorderRadius? paletteBorderRadius;

  @override
  State<PaletteHuePicker> createState() => _PaletteHuePickerState();
}

class _PaletteHuePickerState extends State<PaletteHuePicker> {
  HSVColor get color => widget.color;

  // Hue
  void hueOnChange(double value) => widget.onChanged(
    color.withHue(value).withSaturation(1),
  );
  List<Color> get hueColors => <Color>[
    color.withHue(0.0).withSaturation(1).withValue(1).toColor(),
    color.withHue(60.0).withSaturation(1).withValue(1).toColor(),
    color.withHue(120.0).withSaturation(1).withValue(1).toColor(),
    color.withHue(180.0).withSaturation(1).withValue(1).toColor(),
    color.withHue(240.0).withSaturation(1).withValue(1).toColor(),
    color.withHue(300.0).withSaturation(1).withValue(1).toColor(),
    color.withHue(0.0).withSaturation(1).withValue(1).toColor()
  ];

  // Saturation Value
  void saturationValueOnChange(Offset value) => widget.onChanged(
    HSVColor.fromAHSV(color.alpha, color.hue, value.dx, value.dy),
  );
  // Saturation
  List<Color> get saturationColors => <Color>[
    Colors.white,
    HSVColor.fromAHSV(1.0, color.hue, 1.0, 1.0).toColor(),
  ];
  // Value
  final List<Color> valueColors = <Color>[
    Colors.transparent,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Palette
        SizedBox(
          height: widget.paletteHeight,
          child: Padding(
            padding: widget.palettePadding,
            child: PalettePicker(
              border: widget.paletteBorder,
              borderRadius: widget.paletteBorderRadius,
              position: Offset(color.saturation, color.value),
              onChanged: saturationValueOnChange,
              leftRightColors: saturationColors,
              topPosition: 1.0,
              bottomPosition: 0.0,
              topBottomColors: valueColors,
            ),
          ),
        ),

        // Slider
        slPicker.SliderPicker(
          max: 360.0,
          border: widget.hueBorder,
          borderRadius: widget.hueBorderRadius,
          height: widget.hueHeight,
          value: color.hue,
          onChanged: hueOnChange,
          colors: hueColors,
        )
      ],
    );
  }
}
