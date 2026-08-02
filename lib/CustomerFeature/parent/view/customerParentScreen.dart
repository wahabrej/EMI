import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constant/App_Colors.dart';
import '../../home/view/homeScreen.dart';
import '../../payment/view/customerPaymentScreen.dart';
import '../../profile/view/customerProfileScreen.dart';
import '../../Support/view/customerSupportScreen.dart';
import '../viewModel/customerParentViewModel.dart';

class CustomerParentScreen extends StatelessWidget {
  const CustomerParentScreen({super.key});

  static const List<Widget> _screens = [
    CustomerHomeScreen(),
    CustomerPaymentScreen(),
    CustomerSupportScreen(),
    CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerParentViewModel>(
      builder: (context, provider, child) {
        return Scaffold(
          body: IndexedStack(
            index: provider.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: provider.currentIndex,
              onTap: (index) {
                provider.setIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.white,
              selectedItemColor: AppColors.primaryBlue,
              unselectedItemColor: AppColors.lightGreyText,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              showUnselectedLabels: true,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Payments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.headset_mic_outlined),
                  activeIcon: Icon(Icons.headset_mic),
                  label: 'Support',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}