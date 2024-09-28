import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/interface_widgets/outlined_button.dart';
import 'package:wishmap/res/colors.dart';

class ActualizeMoonDialog extends StatefulWidget{
  Function() onActualizeClick;
  Function() onCreateNew;
  Function() onCloseDialogClick;

  ActualizeMoonDialog(
      {required this.onActualizeClick,
        required this.onCloseDialogClick,
        required this.onCreateNew});

  @override
  ActualizeMoonDialogState createState() => ActualizeMoonDialogState();
}

class ActualizeMoonDialogState extends State<ActualizeMoonDialog> {
  bool inLoading = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Карты желаний",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          const SizedBox(height: 8),
          const Text(
            "Актуализировать последнюю карту желаний иди создать новую чистую карту без желаний и целей? ",
            style: TextStyle(color: AppColors.greytextColor),
          ),
          const SizedBox(height: 24),
          !inLoading?Row(
            children: [
              Expanded(
                  child: OutlinedGradientButton("Актуализировать", () {
                    setState(() {
                      inLoading = true;
                    });
                widget.onActualizeClick();
              })),
              const SizedBox(width: 8),
              Expanded(
                  child: ColorRoundedButton("Создать новую", () {
                    setState(() {
                      inLoading = true;
                    });
                    widget.onCreateNew();
              })),
            ],
          ):const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
