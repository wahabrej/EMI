import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/Parent/ViewModel/Parent_screen_provider.dart';

import '../../EMI/Screen/EmiRepaymentScheduleScreen.dart';
import '../../EMI/Screen/Emi_Screen.dart';
import '../../Home/Screen/Home_Screen.dart';
import '../../Home/Screen/brand_selection_screen.dart';
import '../../Order/Screen/Order_Screen.dart';
import '../../Payment/Screen/Payment_Screen.dart';
import '../../Profile/Screen/ProfileScreen.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    BrandSelectionScreen(),
    OrderScreen(),
    PaymentScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentScreenProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: IndexedStack(
            index: provider.currentIndex,
            children: _screens,
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: provider.currentIndex,
            onTap: (index) {
              provider.setIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF3B82F6), // Active Color
            unselectedItemColor: Colors.grey,           // Inactive Color
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate_outlined),
                activeIcon: Icon(Icons.calculate),
                label: 'EMI',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Order',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payment_outlined),
                activeIcon: Icon(Icons.payment),
                label: 'Payment',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}