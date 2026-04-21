import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'quantity': quantity,
    'price': price,
  };
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
  final String? userEmail;

  const Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.userEmail,
  });

  factory Order.fromFirestore(Map<String, dynamic> doc, String id) {
    final List<dynamic> rawItems = (doc['items'] as List<dynamic>? ?? const []);
    final List<OrderItem> itemsList = rawItems
        .map(
          (e) => OrderItem(
            productId: e['productId'] ?? '',
            name: e['name'] ?? '',
            quantity: (e['quantity'] as num?)?.toInt() ?? 0,
            price: (e['price'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();

    final createdAtValue = doc['createdAt'];
    final createdAt = createdAtValue is Timestamp
        ? createdAtValue.toDate()
        : DateTime.now();

    return Order(
      id: id,
      customerName: doc['customerName'] ?? '',
      customerPhone: doc['customerPhone'] ?? '',
      customerAddress: doc['customerAddress'] ?? '',
      items: itemsList,
      total: (doc['total'] as num).toDouble(),
      status: doc['status'] ?? 'placed',
      createdAt: createdAt,
      userEmail: doc['userEmail'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'userEmail': userEmail,
    };
  }
}
