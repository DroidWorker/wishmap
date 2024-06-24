import 'dart:async';
import 'package:flutter/material.dart';
import 'package:next_audio_recorder/next_audio_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wishmap/res/colors.dart';

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
  int duration = -1;
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

      await _nextAudioRecorder.startRecorder('${DateTime.now().millisecondsSinceEpoch}.mp4');
      await _nextAudioRecorder.setSubscriptionDuration(100);
      _nextAudioRecorder.startRecorderSubscriptions((e) async {
        setState(() {
          print("updaaaaaaate - ${e.decibels}");
          if(e.decibels!=null&&tapState){
            _color = (255-e.decibels!)%255;
            _elevation = 10+((e.decibels)!.abs());
            duration = e.duration.inSeconds;
          }
        });
      });
    }
  }

  Future<void> _onTapUp(TapUpDetails details) async {
    if(!tapState)return;
    tapState=false;
    _nextAudioRecorder.cancelRecorderSubscriptions();
    String? outputFilePath = await _nextAudioRecorder.stopRecorder();
    if(outputFilePath!=null)widget.onTouchUp(outputFilePath);
    setState(() {
      duration = -1;
      _elevation = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("color $_color");
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(100, _color.toInt(), 50, 50),
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
      ),
        if(duration>0)Positioned(
          left: 10,
          top: -30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4)
            ),
            child: Text("${(duration/60).round()}:${duration%60}"),
          ),
        )
      ]
    );
  }
}
