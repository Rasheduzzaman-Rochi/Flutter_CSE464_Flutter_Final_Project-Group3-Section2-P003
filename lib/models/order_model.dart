class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  const OrderItem({required this.productId, required this.name, required this.quantity, required this.price});

  Map<String, dynamic> toMap() => {'productId': productId, 'name': name, 'quantity': quantity, 'price': price};
}

class Order {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<OrderItem> items;
  final double total;
  final String status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromFirestore(Map<String, dynamic> doc, String id) {
    final List<OrderItem> itemsList = (doc['items'] as List)
        .map((e) => OrderItem(
              productId: e['productId'],
              name: e['name'],
              quantity: e['quantity'],
              price: (e['price'] as num).toDouble(),
            ))
        .toList();

    return Order(
      id: id,
      customerName: doc['customerName'] ?? '',
      customerPhone: doc['customerPhone'] ?? '',
      customerAddress: doc['customerAddress'] ?? '',
      items: itemsList,
      total: (doc['total'] as num).toDouble(),
      status: doc['status'] ?? 'placed',
      createdAt: (doc['createdAt'] as dynamic).toDate(),
    );
  }
}