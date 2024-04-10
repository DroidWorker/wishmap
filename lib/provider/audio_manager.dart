import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();

  AudioPlayerManager._internal();

  factory AudioPlayerManager(){
    return _instance;
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  Connectivity connectivity = Connectivity();

  Future<bool> streamAudio(String url) async {
    if ((await connectivity.checkConnectivity()) == ConnectivityResult.none) {
      return false;
    }
    _audioPlayer.play(UrlSource(url));
    return true;
  }

    void playLocal(String localFileName) async {
      final directory = await getTemporaryDirectory();
      _audioPlayer.play(DeviceFileSource("${directory.path}/$localFileName"));
    }

    void pause(){
      _audioPlayer.pause();
    }
  void stop(){
    _audioPlayer.stop();
  }
}