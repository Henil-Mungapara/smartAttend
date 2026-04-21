

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCxxEqpnqGWyPObVr4JCYCXeHXW1VK2SA8',
    appId: '1:259927600486:web:945c5e3f5eac9dd2406ca7',
    messagingSenderId: '259927600486',
    projectId: 'smartattend-f9f81',
    authDomain: 'smartattend-f9f81.firebaseapp.com',
    storageBucket: 'smartattend-f9f81.firebasestorage.app',
    measurementId: 'G-DP5RS02S5E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjjhu0FlNei0-W2ttNVT0WgdXTGgtAMJY',
    appId: '1:259927600486:android:9248fe0443b9e335406ca7',
    messagingSenderId: '259927600486',
    projectId: 'smartattend-f9f81',
    storageBucket: 'smartattend-f9f81.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABSE85P_Al2lRifxIR9nMZPqhXjJsVkSQ',
    appId: '1:259927600486:ios:013d080fa483658d406ca7',
    messagingSenderId: '259927600486',
    projectId: 'smartattend-f9f81',
    storageBucket: 'smartattend-f9f81.firebasestorage.app',
    iosBundleId: 'com.example.smartattend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyABSE85P_Al2lRifxIR9nMZPqhXjJsVkSQ',
    appId: '1:259927600486:ios:013d080fa483658d406ca7',
    messagingSenderId: '259927600486',
    projectId: 'smartattend-f9f81',
    storageBucket: 'smartattend-f9f81.firebasestorage.app',
    iosBundleId: 'com.example.smartattend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCxxEqpnqGWyPObVr4JCYCXeHXW1VK2SA8',
    appId: '1:259927600486:web:7da983ba0b094415406ca7',
    messagingSenderId: '259927600486',
    projectId: 'smartattend-f9f81',
    authDomain: 'smartattend-f9f81.firebaseapp.com',
    storageBucket: 'smartattend-f9f81.firebasestorage.app',
    measurementId: 'G-F47VTSZSH0',
  );
}
