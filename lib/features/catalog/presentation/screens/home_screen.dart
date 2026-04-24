import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../core/widgets/main_nav_bar.dart';
import '../../../../models/product_model.dart';
import '../../../cart/provider/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/search_Bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  final _productsStream = FirebaseFirestore.instance
      .collection('products')
      .snapshots();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 74,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B1F33), Color(0xFF163C5A), Color(0xFF1F6F8B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SnapBuy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    height: 1,
                  ),
                ),
                Text(
                  'Premium shopping',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${cart.itemCount} items',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          buildSearchBar(
            searchController: searchController,
            searchQuery: searchQuery,
            onChanged: (value) => setState(() => searchQuery = value),
            onClear: () {
              searchController.clear();
              setState(() => searchQuery = '');
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Failed to load products: ${snapshot.error}'),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allProducts = snapshot.data!.docs
                    .map((doc) => Product.fromFirestore(doc.data(), doc.id))
                    .toList();

                final categories = <String>[
                  'All',
                  ...{
                    for (final product in allProducts)
                      if (product.category.trim().isNotEmpty) product.category,
                  },
                ];

                final visibleProducts = allProducts
                    .where(
                      (product) =>
                          _selectedCategory == 'All' ||
                          product.category == _selectedCategory,
                    )
                    .where(
                      (product) =>
                          searchQuery.isEmpty ||
                          product.name.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

                if (allProducts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No products found in Firestore.'),
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildCategoryFilter(categories),
                    Expanded(child: _buildProductGrid(visibleProducts)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 0),
    );
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
            selected: _selectedCategory == categories[i],
            onSelected: (_) =>
                setState(() => _selectedCategory = categories[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No matching products found',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different product name or category.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ProductCard(
        imageUrl: products[i].imageUrl,
        name: products[i].name,
        price: products[i].price,
        onTap: () => Navigator.pushNamed(
          ctx,
          AppRoutes.productDetail,
          arguments: products[i],
        ),
      ),
    );
  }
}
