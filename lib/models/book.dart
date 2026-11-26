// lib/models/book.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Status possíveis para um livro na estante
enum BookStatus {
  wantToRead,
  reading,
  read;

  /// Rótulo para exibição na interface do usuário
  String get label {
    switch (this) {
      case BookStatus.wantToRead:
        return 'Quero ler';
      case BookStatus.reading:
        return 'Lendo';
      case BookStatus.read:
        return 'Lido';
    }
  }

  /// Converte o enum para String salva no Firestore
  String toStorageString() => name;

  /// Converte uma String do Firestore para o enum BookStatus
  static BookStatus fromStorageString(String? value) {
    switch (value) {
      case 'reading':
        return BookStatus.reading;
      case 'read':
        return BookStatus.read;
      case 'wantToRead':
      default:
        return BookStatus.wantToRead;
    }
  }
}

/// Gêneros literários disponíveis para seleção no formulário
const List<String> bookGenres = [
  'Ficção científica',
  'Fantasia',
  'Romance',
  'Terror',
  'Suspense',
  'Não ficção',
  'Outro',
];

/// Modelo representando um livro da estante pessoal
class Book {
  final String? id;
  final String title;
  final String author;
  final BookStatus status;
  final int totalPages;
  final int currentPage;
  final int? rating;
  final DateTime? finishedAt;
  final DateTime createdAt;
  final String genre;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.status,
    required this.totalPages,
    required this.currentPage,
    required this.genre,
    this.rating,
    this.finishedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Retorna o progresso de leitura em formato decimal de 0.0 a 1.0
  double get progress {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  /// Converte um documento do Firestore para uma instância de [Book]
  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final status = BookStatus.fromStorageString(data['status'] as String?);
    final createdAtRaw = data['createdAt'];
    final finishedAtRaw = data['finishedAt'];

    return Book(
      id: doc.id,
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      status: status,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (data['currentPage'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toInt(),
      genre: data['genre'] as String? ?? '',
      finishedAt: finishedAtRaw is Timestamp ? finishedAtRaw.toDate() : null,
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now(),
    );
  }

  /// Converte a instância de [Book] para um Map consistente a ser salvo no Firestore
  Map<String, dynamic> toMap() {
    int finalCurrentPage = currentPage;
    int? finalRating = rating;
    DateTime? finalFinishedAt = finishedAt;

    // Regras de consistência
    if (status == BookStatus.read) {
      finalCurrentPage = totalPages;
      finalFinishedAt ??= DateTime.now();
    } else if (status == BookStatus.wantToRead) {
      finalCurrentPage = 0;
      finalRating = null;
      finalFinishedAt = null;
    } else {
      // status == BookStatus.reading
      finalRating = null;
      finalFinishedAt = null;
    }

    return {
      'title': title,
      'author': author,
      'genre': genre,
      'status': status.toStorageString(),
      'totalPages': totalPages,
      'currentPage': finalCurrentPage,
      'rating': finalRating,
      'finishedAt': finalFinishedAt != null ? Timestamp.fromDate(finalFinishedAt) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Cria uma cópia deste livro alterando apenas os campos passados por parâmetro
  Book copyWith({
    String? id,
    String? title,
    String? author,
    BookStatus? status,
    String? genre,
    int? totalPages,
    int? currentPage,
    int? rating,
    DateTime? finishedAt,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      status: status ?? this.status,
      genre: genre ?? this.genre,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      rating: rating ?? this.rating,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
