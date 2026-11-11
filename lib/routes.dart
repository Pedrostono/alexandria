// lib/routes.dart
import 'package:flutter/material.dart';
import 'models/book.dart';
import 'screens/auth_gate.dart';
import 'screens/book_form_screen.dart';
import 'screens/register_screen.dart';

/// Definição centralizada dos nomes das rotas e gerador de rotas do aplicativo
class AppRoutes {
  static const String authGate = '/';
  static const String register = '/register';
  static const String bookForm = '/book-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case bookForm:
        final book = settings.arguments as Book?;
        return MaterialPageRoute(
          builder: (_) => BookFormScreen(book: book),
        );
      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
