import 'package:flutter/material.dart';

class IngredientInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const IngredientInput({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Ajouter un ingrédient',
              prefixIcon: const Icon(Icons.restaurant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 246, 131, 97),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
