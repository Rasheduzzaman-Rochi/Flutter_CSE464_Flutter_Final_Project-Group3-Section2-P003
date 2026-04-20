import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../core/widgets/main_nav_bar.dart';
import '../../../../models/product_model.dart';
import '../../../cart/provider/cart_provider.dart';
import '../widgets/product_card.dart';

const List<Product> _sampleProducts = [
  Product(
    id: 'p1',
    name: 'Wireless Headphones',
    price: 79.99,
    category: 'Electronics',
    imageUrl: 'https://picsum.photos/seed/headphones/800/800',
    description:
        'Comfortable wireless headphones with clear sound and long battery life.',
  ),
  Product(
    id: 'p2',
    name: 'Everyday T-Shirt',
    price: 24.50,
    category: 'Clothing',
    imageUrl: 'https://picsum.photos/seed/tshirt/800/800',
    description: 'Soft cotton tee designed for daily wear with a relaxed fit.',
  ),
  Product(
    id: 'p3',
    name: 'Desk Lamp',
    price: 39.00,
    category: 'Home',
    imageUrl: 'https://picsum.photos/seed/lamps/800/800',
    description: 'Minimal desk lamp with warm lighting for work or study.',
  ),
  Product(
    id: 'p4',
    name: 'Smart Watch',
    price: 149.99,
    category: 'Electronics',
    imageUrl: 'https://picsum.photos/seed/watch/800/800',
    description:
        'Track your workouts, notifications, and sleep from your wrist.',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Electronics', 'Clothing', 'Home'];

  @override
  void dispose() {
    _searchController.dispose();
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
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 0),
    );
  }

  Widget _buildSearchBar() {
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
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value.trim()),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search products by name',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
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

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: 54,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          separatorBuilder: (_, index) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) => ChoiceChip(
            label: Text(_categories[i]),
            selected: _selectedCategory == _categories[i],
            onSelected: (_) =>
                setState(() => _selectedCategory = _categories[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = _sampleProducts
        .where(
          (product) =>
              _selectedCategory == 'All' ||
              product.category == _selectedCategory,
        )
        .where(
          (product) =>
              _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

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
