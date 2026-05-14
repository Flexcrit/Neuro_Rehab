// File generated manually for project: vr-based-neuro-rehab
// FlutterFire CLI equivalent configuration.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // Values from your Firebase project: vr-based-neuro-rehab
  // IMPORTANT: Replace the apiKey and appId with your actual Android app values
  // from the Firebase Console > Project Settings > Your Apps > Android app.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRa-T1F5EmS7lUdKhGdvFBol_HmT8hZ-c',
    appId: '1:689222497876:android:f3088861d9a3b10e8b5fc1',
    messagingSenderId: '689222497876',
    projectId: 'vr-based-neuro-rehab',
    storageBucket: 'vr-based-neuro-rehab.firebasestorage.app',
  );
}
