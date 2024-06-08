// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCKsPgOPz5ux_BTfzvSCcQQS2SneWHIw90',
    appId: '1:957436300982:web:eada2f766826b0d3352017',
    messagingSenderId: '957436300982',
    projectId: 'pillpal-e782d',
    authDomain: 'pillpal-e782d.firebaseapp.com',
    storageBucket: 'pillpal-e782d.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCuUx2bRKV8U0Vjtpl4iaYDln9zkwwatKc',
    appId: '1:957436300982:android:1efbfbf85746da70352017',
    messagingSenderId: '957436300982',
    projectId: 'pillpal-e782d',
    storageBucket: 'pillpal-e782d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsU2udA1NViDwiCA75ojiQPFLbpGgYClQ',
    appId: '1:957436300982:ios:7967e3b328b2e251352017',
    messagingSenderId: '957436300982',
    projectId: 'pillpal-e782d',
    storageBucket: 'pillpal-e782d.appspot.com',
    iosBundleId: 'com.example.pillpal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDsU2udA1NViDwiCA75ojiQPFLbpGgYClQ',
    appId: '1:957436300982:ios:7967e3b328b2e251352017',
    messagingSenderId: '957436300982',
    projectId: 'pillpal-e782d',
    storageBucket: 'pillpal-e782d.appspot.com',
    iosBundleId: 'com.example.pillpal',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCKsPgOPz5ux_BTfzvSCcQQS2SneWHIw90',
    appId: '1:957436300982:web:aa151c77aa5f5287352017',
    messagingSenderId: '957436300982',
    projectId: 'pillpal-e782d',
    authDomain: 'pillpal-e782d.firebaseapp.com',
    storageBucket: 'pillpal-e782d.appspot.com',
  );

}