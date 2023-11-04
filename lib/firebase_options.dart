// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDKGgexDrfEkGwrRRJifj2poP4A1crV_38',
    appId: '1:390038865604:web:9b60e2ef4e231495322b91',
    messagingSenderId: '390038865604',
    projectId: 'wishmap-c3e06',
    authDomain: 'wishmap-c3e06.firebaseapp.com',
    databaseURL: 'https://wishmap-c3e06-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'wishmap-c3e06.appspot.com',
    measurementId: 'G-D9CRBD8J37',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjJ4xG1qLDbjJoIrZLpGRXYwuJIdt9TDc',
    appId: '1:390038865604:android:6a168f43397f5c9d322b91',
    messagingSenderId: '390038865604',
    projectId: 'wishmap-c3e06',
    databaseURL: 'https://wishmap-c3e06-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'wishmap-c3e06.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPNydN0lZdZnBburzvFN41UZ1_8ctlHOY',
    appId: '1:390038865604:ios:5af297097fb2c5ff322b91',
    messagingSenderId: '390038865604',
    projectId: 'wishmap-c3e06',
    databaseURL: 'https://wishmap-c3e06-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'wishmap-c3e06.appspot.com',
    iosBundleId: 'com.kwork.wish.map.wishmap',
  );
}