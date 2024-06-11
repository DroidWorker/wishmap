import 'dart:async';
import 'package:flutter/material.dart';
import 'package:next_audio_recorder/next_audio_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class AnimatedRoundIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTouchDown;
  final Function(String audioLink) onTouchUp;


  AnimatedRoundIconButton({required this.icon, required this.onTouchDown, required this.onTouchUp});

  @override
  _RoundIconButtonState createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<AnimatedRoundIconButton> {
  double _elevation = 0.0;
  double _color = 0;
  //Recording? recording;
  //late FlutterVoiceRecorder recorder;
  late NextAudioRecorder _nextAudioRecorder;
  late String path;
  var tapState = false;

  /*Future _init() async {
    path = "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";
    recorder = FlutterVoiceRecorder(path); // .wav .aac .m4a
    await recorder.initialized;
  }*/

  @override
  void initState() {
    super.initState();
    _nextAudioRecorder = NextAudioRecorder();
    //_init();
  }
  Future _onTapDown(TapDownDetails details) async {
    final permission = await Permission.microphone.status;
    if(permission!=PermissionStatus.granted){
      final reqResult = await Permission.microphone.request();
    }else{
      tapState=true;
      await _nextAudioRecorder.startRecorder('output.mp4');
      await _nextAudioRecorder.setSubscriptionDuration(100);
      _nextAudioRecorder.startRecorderSubscriptions((e) async {
        setState(() {
          print("updaaaaaaate - ${e.decibels}");
          if(e.decibels!=null&&tapState){
            _color = (255-e.decibels!)%255;
            _elevation = 70-((e.decibels!/3)%50.abs());
          }
        });
      });
    }
  }

  Future<void> _onTapUp(TapUpDetails details) async {
    tapState=false;
    _nextAudioRecorder.cancelRecorderSubscriptions();
    String? outputFilePath = await _nextAudioRecorder.stopRecorder();
    if(outputFilePath!=null)widget.onTouchUp(outputFilePath);
    setState(() {
      _elevation = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("color $_color");
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(100, _color.toInt(), 25, 25),
              spreadRadius: _elevation,
              blurRadius: _elevation,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: widget.icon,
        ),
      ),
    );
  }
}
