// lib/widgets/rating_stars.dart
import 'package:flutter/material.dart';

/// Componente de avaliação com 5 estrelas (modo interativo ou somente leitura)
class RatingStars extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;
  final Color? color;

  const RatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Colors.amber;
    final inactiveColor = Theme.of(context).disabledColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isSelected = starValue <= rating;

        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          iconSize: size,
          icon: Icon(
            isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isSelected ? activeColor : inactiveColor,
          ),
          onPressed: onChanged == null ? null : () => onChanged!(starValue),
        );
      }),
    );
  }
}
