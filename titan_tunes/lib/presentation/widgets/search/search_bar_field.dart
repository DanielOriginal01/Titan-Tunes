import 'package:flutter/material.dart';

/// Barre de recherche stylisée avec icône, champ texte et bouton clear.
class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final Color primary;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.primary,
    required this.isDark,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(18),
          ),
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Chanson, artiste, genre, label…',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          if (query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_rounded, color: primary, size: 20),
              onPressed: onClear,
            )
          else
            const SizedBox(width: 14),
        ]),
      ),
    );
  }
}