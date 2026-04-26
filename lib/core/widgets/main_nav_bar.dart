import 'package:flutter/material.dart';
import '../constants.dart';

class MainNavBar extends StatelessWidget {
  const MainNavBar({
    super.key,
    required this.currentIndex,
    this.showLabels = true,
  });

  final int currentIndex;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1D2E),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            height: 76,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            selectedIndex: currentIndex,
            labelBehavior: showLabels
                ? NavigationDestinationLabelBehavior.alwaysShow
                : NavigationDestinationLabelBehavior.onlyShowSelected,
            onDestinationSelected: (index) => _onTap(context, index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 28),
                selectedIcon: Icon(Icons.home_rounded, size: 30),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined, size: 28),
                selectedIcon: Icon(Icons.shopping_bag_rounded, size: 30),
                label: 'Cart',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined, size: 28),
                selectedIcon: Icon(Icons.receipt_long_rounded, size: 30),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, size: 28),
                selectedIcon: Icon(Icons.person_rounded, size: 30),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    final route = switch (index) {
      0 => AppRoutes.home,
      1 => AppRoutes.cart,
      2 => AppRoutes.orders,
      _ => AppRoutes.profile,
    };

    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }
}
