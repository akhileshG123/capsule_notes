import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // We only provide Android for now based on user requirements.
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvVXwI-7Cp4K4v6vyWwZyBsq4WEPkrQpo',
    appId: '1:1068256137189:android:ea31cec8bd3e6a440c690c',
    messagingSenderId: '1068256137189',
    projectId: 'capsule-notes-19a78',
    storageBucket: 'capsule-notes-19a78.firebasestorage.app',
  );
}
