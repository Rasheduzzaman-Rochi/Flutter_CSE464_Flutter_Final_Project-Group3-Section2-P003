import 'package:flutter/material.dart';

class CategoryFilter extends StatefulWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  @override
  Widget build(BuildContext context) {
    return _buildCategoryFilter(widget.categories);
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: 54,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, index) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) => ChoiceChip(
            label: Text(categories[i]),
            selected: widget.selectedCategory == categories[i],
            onSelected: (_) => widget.onCategorySelected(categories[i]),
          ),
        ),
      ),
    );
  }
}
