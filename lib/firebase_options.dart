// lib/firebase_options.dart
// Arquivo de configuração do Firebase gerado via CLI (`flutterfire configure`).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configurações padrão do Firebase para a aplicação.
/// Subscriba ou substitua executando `flutterfire configure` no terminal do projeto.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não suporta esta plataforma. Execute `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdjIoG7YXH9TVuK3LMWJl7g29MQ8dcq6M',
    appId: '1:824672159806:android:b570abdd099d73c9a8296f',
    messagingSenderId: '824672159806',
    projectId: 'estante-leitura',
    storageBucket: 'estante-leitura.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'estante-leitura',
    storageBucket: 'estante-leitura.appspot.com',
    iosBundleId: 'com.example.estanteLeitura',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAcmaVZaoF73FQE3NprU68jE8qDkiXx3Fg',
    appId: '1:824672159806:web:99f09902a9a1be13a8296f',
    messagingSenderId: '824672159806',
    projectId: 'estante-leitura',
    authDomain: 'estante-leitura.firebaseapp.com',
    storageBucket: 'estante-leitura.firebasestorage.app',
    measurementId: 'G-82Q3NQQ4CT',
  );
}
