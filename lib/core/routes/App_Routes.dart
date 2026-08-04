import 'package:flutter/material.dart';
import '../../CustomerFeature/home/model/customer_dashboard_model.dart';
import '../../CustomerFeature/home/view/homeScreen.dart';
import '../../CustomerFeature/payment/view/ProceedToPayScreen.dart';
import '../../Features/Auth/Screen/Login_Screen.dart';
import '../../Features/Auth/Screen/Sign_Up_Screen.dart';
import '../../Features/EMI/Screen/EmiRepaymentScheduleScreen.dart';
import '../../Features/Home/Screen/brand_selection_screen.dart';
import '../../Features/Parent/Screen/Parent_screen.dart';
import '../../Features/Splash/Splash_Screen.dart';
import '../../Features/multy_form/multyform_screen.dart';
import '../../CustomerFeature/parent/view/customerParentScreen.dart';
import '../../CustomerFeature/home/view/loanDetailsScreen.dart';
import '../../CustomerFeature/home/view/customerDocumentsScreen.dart';
import '../../CustomerFeature/home/view/notificationScreen.dart';
import '../../CustomerFeature/home/view/loanApplicationListScreen.dart';
import '../../CustomerFeature/home/view/loanApplicationDetailsScreen.dart';
import '../../CustomerFeature/home/model/customer_loan_application_model.dart';
import 'Routes_name.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),

    RouteName.parentScreen: (context) => const ParentScreen(),
    RouteName.loginScreen: (context) => const LoginScreen(),
    RouteName.signUpScreen: (context) => const SignUpScreen(),
    RouteName.checkoutParentScreen: (context) => const MultyFormScreen(),
    RouteName.brandSelectionScreen: (context) => const BrandSelectionScreen(),
    RouteName.emiRepaymentScheduleScreen: (context) =>
        const EmiRepaymentScheduleScreen(),

    // ── Customer Feature Routes ──────────────────────────
    RouteName.customerParentScreen: (context) => const CustomerParentScreen(),
    RouteName.customerHomeScreen: (context) => const CustomerHomeScreen(),
    RouteName.customerDocumentsScreen: (context) =>
        const CustomerDocumentsScreen(),
    RouteName.customerNotificationScreen: (context) =>
        const CustomerNotificationScreen(),
    RouteName.customerLoanApplicationListScreen: (context) =>
        const CustomerLoanApplicationListScreen(),
    RouteName.proceedToPayScreen: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      return ProceedToPayScreen(
        selectedItems: args['selectedItems'] as List<Installments>,
        loanAccount: args['loanAccount'] as String? ?? 'N/A',
        customerName: args['customerName'] as String? ?? 'Customer',
      );
    },
    RouteName.customerLoanDetailsScreen: (context) {
      final loanId = ModalRoute.of(context)!.settings.arguments as String?;
      return CustomerLoanDetailsScreen(loanId: loanId);
    },

    RouteName.customerLoanApplicationDetailsScreen: (context) {
      final application =
          ModalRoute.of(context)!.settings.arguments
              as CustomerLoanApplicationModel;
      return CustomerLoanApplicationDetailsScreen(application: application);
    },
  };
}
