// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/yearly_counter_card.dart';

/// Tela principal com a estante de livros dividida por abas e contador de leitura anual
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  Future<void> _confirmSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
    }
  }

  Future<bool> _confirmDelete(BuildContext context, Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir livro?'),
        content: Text('Deseja remover "${book.title}" da sua estante?'),
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

    return confirm ?? false;
  }

  Future<void> _deleteBook(DatabaseService dbService, Book book) async {
    if (book.id == null) return;
    try {
      await dbService.deleteBook(book.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro excluído.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  int _calculateYearlyReadCount(List<Book> books) {
    final currentYear = DateTime.now().year;
    return books.where((b) {
      if (b.status != BookStatus.read || b.finishedAt == null) return false;
      return b.finishedAt!.year == currentYear;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado.')),
      );
    }

    final dbService = DatabaseService(uid: user.uid);
    final userName = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : (user.email ?? 'Leitor');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Olá, $userName'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => _confirmSignOut(),
            ),
          ],
        ),
        body: StreamBuilder<List<Book>>(
          stream: dbService.watchBooks(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyState(
                message: 'Erro ao carregar a estante:\n${snapshot.error}',
                icon: Icons.error_outline,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allBooks = snapshot.data ?? [];
            final wantToReadBooks =
                allBooks.where((b) => b.status == BookStatus.wantToRead).toList();
            final readingBooks =
                allBooks.where((b) => b.status == BookStatus.reading).toList();
            final readBooks =
                allBooks.where((b) => b.status == BookStatus.read).toList();

            final yearlyCount = _calculateYearlyReadCount(allBooks);

            return Column(
              children: [
                YearlyCounterCard(count: yearlyCount),
                TabBar(
                  tabs: [
                    Tab(text: 'Quero ler (${wantToReadBooks.length})'),
                    Tab(text: 'Lendo (${readingBooks.length})'),
                    Tab(text: 'Lidos (${readBooks.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBookList(
                        context,
                        dbService,
                        wantToReadBooks,
                        'Nenhum livro na lista "Quero ler".',
                        Icons.bookmark_border_rounded,
                      ),
                      _buildBookList(
                        context,
                        dbService,
                        readingBooks,
                        'Nenhum livro sendo lido atualmente.',
                        Icons.menu_book_rounded,
                      ),
                      _buildBookList(
                        context,
                        dbService,
                        readBooks,
                        'Nenhum livro concluído ainda.',
                        Icons.check_circle_outline_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.bookForm);
          },
          tooltip: 'Adicionar Livro',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBookList(
    BuildContext context,
    DatabaseService dbService,
    List<Book> books,
    String emptyMessage,
    IconData emptyIcon,
  ) {
    if (books.isEmpty) {
      return EmptyState(
        message: emptyMessage,
        icon: emptyIcon,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Dismissible(
          key: Key(book.id ?? index.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context, book),
          onDismissed: (_) => _deleteBook(dbService, book),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          child: BookCard(
            book: book,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.bookForm,
                arguments: book,
              );
            },
          ),
        );
      },
    );
  }
}
