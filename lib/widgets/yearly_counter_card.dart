// lib/widgets/yearly_counter_card.dart
import 'package:flutter/material.dart';

/// Card de destaque exibindo a contagem de livros lidos no ano atual
class YearlyCounterCard extends StatelessWidget {
  final int count;
  final int? year;

  const YearlyCounterCard({
    super.key,
    required this.count,
    this.year,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = year ?? DateTime.now().year;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leituras do Ano ($currentYear)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Você leu $count ${count == 1 ? 'livro' : 'livros'} em $currentYear',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
