class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description,
  });

  factory Product.fromFirestore(Map<String, dynamic> doc, String id) {
    return Product(
      id: id,
      name: doc['name'] ?? '',
      price: (doc['price'] ?? 0).toDouble(),
      category: doc['category'] ?? '',
      imageUrl: doc['imageUrl'] ?? '',
      description: doc['description'] ?? '',
    );
  }
}