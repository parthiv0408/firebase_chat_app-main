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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxFZMCFnoqz_PcJtcB_wH02pqws3io8aI',
    appId: '1:139136429186:android:229cc2286ff7e2a3ee989b',
    messagingSenderId: '139136429186',
    projectId: 'fir-chat-app-39c82',
    storageBucket: 'fir-chat-app-39c82.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBiAVolBgm9iCiaL9TFAHsu4u5P37i9mjU',
    appId: '1:139136429186:ios:de9ea69c5281c85cee989b',
    messagingSenderId: '139136429186',
    projectId: 'fir-chat-app-39c82',
    storageBucket: 'fir-chat-app-39c82.appspot.com',
    iosClientId:
        '139136429186-7si67v1mfd9tqint6idc9a9n18klbcc3.apps.googleusercontent.com',
    iosBundleId: 'com.app.firebaseChatApp',
  );
}
