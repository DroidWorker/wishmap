import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../ViewModel.dart';
import '../navigation/navigation_block.dart';

class QRCheckScreen extends StatelessWidget{
bool isFound = false;
  @override
  Widget build(BuildContext context) {
    final appViewModel = context.read<AppViewModel>();
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          iconSize: 30,
          onPressed: (){
            BlocProvider.of<NavigationBloc>(context).handleBackPress();
          },
        ),
      ),
      body: Align(alignment: Alignment.center,
      child: SizedBox(
        width: 300,
        height: 300,
        child: MobileScanner(
          // fit: BoxFit.contain,
          controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.noDuplicates,
          ),
          onDetect: (capture) async {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              debugPrint('Barcode found! ${barcode.rawValue}');
            }
            if(barcodes.last.rawValue.toString()=="promocode"&&!isFound){
              await appViewModel.duplicateLastMoon();
              final moonId = appViewModel.moonItems.last;
              appViewModel.startMainScreen(moonId);
              BlocProvider.of<NavigationBloc>(context)
                  .add(NavigateToMainScreenEvent());
              isFound=true;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(barcodes.first.rawValue.toString()),
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      )
      ),
    );
  }
}