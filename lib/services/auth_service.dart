// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

/// Exceção personalizada para erros de autenticação com mensagens amigáveis em português
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Serviço responsável por todas as operações de autenticação com o Firebase Auth
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Stream com as alterações no estado de autenticação do usuário
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Retorna o usuário atualmente logado no Firebase
  User? get currentUser => _auth.currentUser;

  /// Autentica o usuário utilizando e-mail e senha
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro inesperado. Tente novamente.');
    }
  }

  /// Cadastra um novo usuário com nome, e-mail e senha, atualizando o displayName
  Future<void> register(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name.trim());
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro inesperado. Tente novamente.');
    }
  }

  /// Desconecta o usuário atual
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthError(e.code));
    } catch (e) {
      throw AuthException('Erro inesperado ao sair.');
    }
  }

  /// Mapeia códigos de erro do FirebaseAuth para mensagens claras em português
  String _handleAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'Senha fraca. Use pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}
