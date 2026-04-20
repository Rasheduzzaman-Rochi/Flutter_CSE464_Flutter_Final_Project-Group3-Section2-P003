import 'package:flutter/material.dart';
import '../../../../models/order_model.dart';

class OrdersProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void removeOrderById(String orderId) {
    _orders.removeWhere((order) => order.id == orderId);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
