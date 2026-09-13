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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBQCJkLl0mojM9F8VPehutLMxDQ0TAFzEY',
    authDomain: 'student-result-analyzer-48a6b.firebaseapp.com',
    projectId: 'student-result-analyzer-48a6b',
    storageBucket: 'student-result-analyzer-48a6b.firebasestorage.app',
    messagingSenderId: '525353162988',
    appId: '1:525353162988:web:f9d7a31702381a65e6edc9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC98dyxrEA56h23rRrbG8xVFbN_pDtnH4k',
    appId: '1:525353162988:android:81abc7ffac62b402e6edc9',
    messagingSenderId: '525353162988',
    projectId: 'student-result-analyzer-48a6b',
    storageBucket: 'student-result-analyzer-48a6b.appspot.com',
  );
}
