import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../../../models/order_model.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider({firestore.FirebaseFirestore? firestoreInstance})
    : _firestore = firestoreInstance ?? firestore.FirebaseFirestore.instance;

  final firestore.FirebaseFirestore _firestore;
  final List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  Future<void> loadOrders({String? userEmail}) async {
    _setLoading(true);

    try {
      firestore.Query<Map<String, dynamic>> query = _firestore.collection(
        'orders',
      );

      if (userEmail != null && userEmail.trim().isNotEmpty) {
        query = query.where(
          'userEmail',
          isEqualTo: userEmail.trim().toLowerCase(),
        );
      }

      final snapshot = await query.get();
      final loadedOrders =
          snapshot.docs
              .map((doc) => Order.fromFirestore(doc.data(), doc.id))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _orders
        ..clear()
        ..addAll(loadedOrders);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addOrder(Order order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toMap());
    _orders.insert(0, order);
    notifyListeners();
  }

  Future<void> removeOrderById(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
    _orders.removeWhere((order) => order.id == orderId);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
