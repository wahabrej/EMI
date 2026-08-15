import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/Parent/ViewModel/Parent_screen_provider.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/constant/Token_storage.dart';
import '../../Home/Screen/Home_Screen.dart';
import '../../Home/Screen/brand_selectforManager.dart';
import '../../Home/Screen/brand_selection_screen.dart';
import '../../Order/Screen/Order_Screen.dart';
import '../../Payment/Screen/Payment_Screen.dart';
import '../../Profile/Screen/ProfileScreen.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final AppStorage _appStorage = AppStorage();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _appStorage.getUserRole();
    setState(() {
      _userRole = role;
    });
    debugPrint("👤 [ParentScreen] User Role: $_userRole");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentScreenProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: IndexedStack(
            index: provider.currentIndex,
            children: _getScreens(), // ✅ Dynamic screens
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
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              showUnselectedLabels: true,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calculate_outlined),
                  activeIcon: Icon(Icons.calculate),
                  label: 'EMI Calculator',
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
          ),
        );
      },
    );
  }

  //  Dynamic Screens based on Role
  List<Widget> _getScreens() {
    // Check if user is Manager
    final bool isManager = _userRole?.toUpperCase() == 'MANAGER' || _userRole?.toUpperCase() == 'SHOP';

    return [
      const HomeScreen(),

      //  Brand Selection based on Role
      isManager
          ? const BrandSelectForManager()
          : const BrandSelectionScreen(),

      const OrderScreen(),
      const PaymentScreen(),
      const ProfileScreen(),
    ];
  }
}
