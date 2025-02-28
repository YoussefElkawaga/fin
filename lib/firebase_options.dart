import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace these values with your Firebase project configuration
    return const FirebaseOptions(
      apiKey: "AIzaSyAhsexZyrrtj6p0sGUd9vKU9sHKVb1r_oc",
      // You'll need these other values from your Firebase Console
      appId: "1:989433114042:android:7aa9dbf29c0626eca98183",
      messagingSenderId: "989433114042",
      projectId: "fin-market-risk-predictor",
      authDomain: "fin-market-risk-predictor.firebaseapp.com",
      storageBucket: "fin-market-risk-predictor.appspot.com",
    );
  }
} 