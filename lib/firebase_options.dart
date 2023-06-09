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
        return macos;
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
    apiKey: 'AIzaSyCHY9o8tJyXwlRwRWciDTDuP0vMktvsD1M',
    appId: '1:566371582218:web:d583fb46a9874aeb967af3',
    messagingSenderId: '566371582218',
    projectId: 'secondserving-ef1f1',
    authDomain: 'secondserving-ef1f1.firebaseapp.com',
    databaseURL: 'https://secondserving-ef1f1-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'secondserving-ef1f1.appspot.com',
    measurementId: 'G-SCP8GWL34D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSE-UAl4xNmb6Fk7y4ey2h6ayyeHQu2kw',
    appId: '1:566371582218:android:979bc5d1d44a5e4c967af3',
    messagingSenderId: '566371582218',
    projectId: 'secondserving-ef1f1',
    databaseURL: 'https://secondserving-ef1f1-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'secondserving-ef1f1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJXLb6SJPsQG59rnRzzdJTa93KQox0gKM',
    appId: '1:566371582218:ios:a6017e20f2d4638e967af3',
    messagingSenderId: '566371582218',
    projectId: 'secondserving-ef1f1',
    databaseURL: 'https://secondserving-ef1f1-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'secondserving-ef1f1.appspot.com',
    iosClientId: '566371582218-b2gqrmsr77sg55t16gkn22eq10knmkej.apps.googleusercontent.com',
    iosBundleId: 'com.example.secondserving',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAJXLb6SJPsQG59rnRzzdJTa93KQox0gKM',
    appId: '1:566371582218:ios:a6017e20f2d4638e967af3',
    messagingSenderId: '566371582218',
    projectId: 'secondserving-ef1f1',
    databaseURL: 'https://secondserving-ef1f1-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'secondserving-ef1f1.appspot.com',
    iosClientId: '566371582218-b2gqrmsr77sg55t16gkn22eq10knmkej.apps.googleusercontent.com',
    iosBundleId: 'com.example.secondserving',
  );
}
