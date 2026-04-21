import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../models/order_model.dart';
import '../../../cart/provider/cart_provider.dart';
import '../../../orders/provider/orders_provider.dart';
import '../../../auth/provider/auth_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isLoading = false;

  String _generateOrderId() {
    final shortId = DateTime.now().millisecondsSinceEpoch
        .remainder(1000000)
        .toString()
        .padLeft(6, '0');
    return '#$shortId';
  }

  @override
  void initState() {
    super.initState();
    // Auto-fill user data if logged in
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      _nameCtrl.text = authProvider.userName ?? '';
      _phoneCtrl.text = authProvider.userPhone ?? '';
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();
    final authProvider = context.read<AuthProvider>();
    final now = DateTime.now();
    final generatedOrderId = _generateOrderId();

    try {
      final order = Order(
        id: generatedOrderId,
        customerName: _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        customerAddress: _addressCtrl.text.trim(),
        items: cart.items.values
            .map(
              (ci) => OrderItem(
                productId: ci.product.id,
                name: ci.product.name,
                quantity: ci.quantity,
                price: ci.product.price,
              ),
            )
            .toList(),
        total: cart.totalAmount,
        status: 'placed',
        createdAt: now,
        userEmail: authProvider.userEmail,
      );

      await orders.addOrder(order);
      cart.clearCart();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.orderSuccess,
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        labelText: 'Full Name',
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined),
                        labelText: 'Phone Number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on_outlined),
                        labelText: 'Delivery Address',
                      ),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _submitOrder,
                      child: const Text('Place Order'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
