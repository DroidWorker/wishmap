import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/res/colors.dart';

class ActualizeMoonDialog extends StatelessWidget{
  Function() onActualizeClick;
  Function() onCreateNew;
  Function() onCloseDialogClick;

  ActualizeMoonDialog({required this.onActualizeClick, required this.onCloseDialogClick, required this.onCreateNew});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content:IntrinsicHeight(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(alignment: Alignment.topRight,
                child: IconButton(onPressed: (){onCloseDialogClick();}, icon: const Icon(Icons.close), padding: EdgeInsets.zero,),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15), child: Text("Актуализировать последнюю карту желаний или создать новую чистую карту без желаний и целей", textAlign: TextAlign.center,),),
              const Divider(height: 3,color: AppColors.dividerGreyColor,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child:Padding(padding: const EdgeInsets.all(15),child: TextButton(onPressed: (){onActualizeClick();},
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: const Text("Актуализировать последнюю", textAlign: TextAlign.center, style: TextStyle(fontSize:10, color: Colors.black))),)),
                  Expanded(child:Padding(padding: const EdgeInsets.all(15),child: TextButton(onPressed: (){onCreateNew();},
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.greyBackButton,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: const Text("Создать чистую карту", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black),))))
                ],)
            ],
          ),
        ),
      ),
    );
  }

}