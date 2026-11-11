// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

/// Exceção personalizada para erros de manipulação do banco de dados Cloud Firestore
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => message;
}

/// Serviço responsável pelas operações de CRUD de livros no Cloud Firestore
class DatabaseService {
  final String uid;
  final FirebaseFirestore _firestore;

  DatabaseService({
    required this.uid,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Referência da coleção de livros associada ao UID do usuário logado
  CollectionReference<Map<String, dynamic>> get _userBooksRef {
    if (uid.isEmpty) {
      throw DatabaseException('Usuário não autenticado.');
    }
    return _firestore.collection('users').doc(uid).collection('books');
  }

  /// Retorna uma Stream contendo a lista de livros do usuário ordenada por createdAt (descendente).
  /// O filtro por status é realizado na aplicação para evitar a necessidade de índices compostos no Firestore.
  Stream<List<Book>> watchBooks() {
    try {
      return _userBooksRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(_handleDatabaseError(e));
    } catch (e) {
      throw DatabaseException('Erro ao carregar a lista de livros.');
    }
  }

  /// Adiciona um novo livro ao Firestore
  Future<void> addBook(Book book) async {
    try {
      await _userBooksRef.add(book.toMap());
    } on FirebaseException catch (e) {
      throw DatabaseException(_handleDatabaseError(e));
    } catch (e) {
      throw DatabaseException('Erro ao salvar o novo livro.');
    }
  }

  /// Atualiza os dados de um livro existente
  Future<void> updateBook(Book book) async {
    if (book.id == null || book.id!.isEmpty) {
      throw DatabaseException('ID do livro não informado para atualização.');
    }
    try {
      await _userBooksRef.doc(book.id).update(book.toMap());
    } on FirebaseException catch (e) {
      throw DatabaseException(_handleDatabaseError(e));
    } catch (e) {
      throw DatabaseException('Erro ao atualizar o livro.');
    }
  }

  /// Exclui um livro pelo seu ID no Firestore
  Future<void> deleteBook(String id) async {
    if (id.isEmpty) {
      throw DatabaseException('ID do livro não informado para exclusão.');
    }
    try {
      await _userBooksRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw DatabaseException(_handleDatabaseError(e));
    } catch (e) {
      throw DatabaseException('Erro ao excluir o livro.');
    }
  }

  /// Mapeia códigos de erro do Cloud Firestore para mensagens claras em português
  String _handleDatabaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Acesso negado. Você não tem permissão para realizar esta operação.';
      case 'unavailable':
        return 'Serviço indisponível no momento. Verifique sua conexão com a internet.';
      case 'not-found':
        return 'O livro solicitado não foi encontrado.';
      default:
        return 'Erro no banco de dados. Tente novamente.';
    }
  }
}
