import 'package:flutter/material.dart';

Widget buildSearchBar({
  required TextEditingController searchController,
  required String searchQuery,
  required ValueChanged<String> onChanged,
  required VoidCallback onClear,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) => onChanged(value.trim()),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search products by name',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    ),
  );
}