// lib/screens/book_form_screen.dart
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/validators.dart';
import '../widgets/rating_stars.dart';

/// Tela para inclusão e edição de livros na estante
class BookFormScreen extends StatefulWidget {
  final Book? book;

  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _totalPagesController;
  late TextEditingController _currentPageController;

  late BookStatus _status;
  String? _genre;
  int? _rating;
  bool _isLoading = false;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;

    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _totalPagesController =
        TextEditingController(text: b != null ? b.totalPages.toString() : '');
    _currentPageController =
        TextEditingController(text: b != null ? b.currentPage.toString() : '0');

    _status = b?.status ?? BookStatus.wantToRead;
    _rating = b?.rating;

    // Gêneros antigos/desconhecidos (ou vazios) ficam sem seleção no dropdown
    final savedGenre = b?.genre ?? '';
    _genre = savedGenre.isNotEmpty ? savedGenre : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    if (_status == BookStatus.read && (_rating == null || _rating! < 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione uma avaliação de 1 a 5 estrelas.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    final totalPages = int.parse(_totalPagesController.text.trim());
    int currentPage = 0;
    if (_status == BookStatus.reading) {
      currentPage = int.tryParse(_currentPageController.text.trim()) ?? 0;
    } else if (_status == BookStatus.read) {
      currentPage = totalPages;
    }

    final bookData = Book(
      id: widget.book?.id,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      genre: _genre ?? '',
      status: _status,
      totalPages: totalPages,
      currentPage: currentPage,
      rating: _status == BookStatus.read ? _rating : null,
      finishedAt: _status == BookStatus.read
          ? (widget.book?.finishedAt ?? DateTime.now())
          : null,
      createdAt: widget.book?.createdAt ?? DateTime.now(),
    );

    try {
      final dbService = DatabaseService(uid: user.uid);
      if (_isEditing) {
        await dbService.updateBook(bookData);
      } else {
        await dbService.addBook(bookData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro salvo.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteBook() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir livro?'),
        content: Text('Deseja remover "${widget.book!.title}" da estante?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final user = _authService.currentUser;
    if (user == null || widget.book?.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dbService = DatabaseService(uid: user.uid);
      await dbService.deleteBook(widget.book!.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro excluído.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar livro' : 'Novo livro'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Excluir',
              onPressed: _isLoading ? null : _deleteBook,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Título do livro',
                  prefixIcon: Icon(Icons.book_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    Validators.minLength(val, 2, 'Informe o título do livro.'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    Validators.minLength(val, 2, 'Informe o autor do livro.'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _genre,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  // Mantém um gênero salvo que não esteja na lista atual
                  if (_genre != null && !bookGenres.contains(_genre))
                    DropdownMenuItem<String>(
                      value: _genre,
                      child: Text(_genre!),
                    ),
                  ...bookGenres.map((genre) {
                    return DropdownMenuItem<String>(
                      value: genre,
                      child: Text(genre),
                    );
                  }),
                ],
                onChanged: (newGenre) {
                  setState(() {
                    _genre = newGenre;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BookStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status de leitura',
                  prefixIcon: Icon(Icons.bookmark_outline),
                  border: OutlineInputBorder(),
                ),
                items: BookStatus.values.map((status) {
                  return DropdownMenuItem<BookStatus>(
                    value: status,
                    child: Text(status.label),
                  );
                }).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    setState(() {
                      _status = newStatus;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalPagesController,
                keyboardType: TextInputType.number,
                textInputAction: _status == BookStatus.reading
                    ? TextInputAction.next
                    : TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Total de páginas',
                  prefixIcon: Icon(Icons.numbers_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.positiveInt,
              ),

              // Campo de Página Atual (visível apenas quando o status é "Lendo")
              if (_status == BookStatus.reading) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentPageController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Página atual',
                    prefixIcon: Icon(Icons.auto_stories_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    final total =
                        int.tryParse(_totalPagesController.text.trim()) ?? 0;
                    return Validators.currentPage(val, total);
                  },
                ),
              ],

              // Componente de Nota (visível apenas quando o status é "Lido")
              if (_status == BookStatus.read) ...[
                const SizedBox(height: 24),
                Text(
                  'Sua avaliação',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: RatingStars(
                    rating: _rating ?? 0,
                    size: 36,
                    onChanged: (newRating) {
                      setState(() {
                        _rating = newRating;
                      });
                    },
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBook,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Salvar Alterações' : 'Salvar Livro',
                          style: const TextStyle(fontSize: 16),
                        ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
