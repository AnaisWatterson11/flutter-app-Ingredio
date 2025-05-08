import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final void Function(int)? onRatingChanged; // nullable

  const StarRating({
    super.key,
    required this.rating,
    this.onRatingChanged, // rend facultatif
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final icon = Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );

        if (onRatingChanged != null) {
          return IconButton(
            icon: icon,
            onPressed: () => onRatingChanged!(index + 1),
            splashRadius: 20,
          );
        } else {
          return icon; // juste afficher l'icône
        }
      }),
    );
  }
}
