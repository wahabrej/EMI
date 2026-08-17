import 'package:flutter/material.dart';
import 'package:smart_pay_app/Features/Profile/Screen/ProfileScreen.dart';
import '../../CustomerFeature/home/model/customer_dashboard_model.dart';
import '../../CustomerFeature/home/view/homeScreen.dart';
import '../../CustomerFeature/payment/view/ProceedToPayScreen.dart';
import '../../Features/Auth/Screen/Login_Screen.dart';
import '../../Features/Auth/Screen/Sign_Up_Screen.dart';
import '../../Features/EMI/Screen/EmiRepaymentScheduleScreen.dart';
import '../../Features/Home/Screen/ActiveLoanScreen.dart';
import '../../Features/Home/Screen/CollectPaymentScreen.dart';
import '../../Features/Home/Screen/Edit_customer.dart';
import '../../Features/Home/Screen/OverdueLoanScreen.dart';
import '../../Features/Home/Screen/PendingApprovalScreen.dart';
import '../../Features/Home/Screen/TotalCustomerScreen.dart';
import '../../Features/Home/Screen/brand_selectforManager.dart';
import '../../Features/Home/Screen/brand_selection_screen.dart';
import '../../Features/Home/Screen/LoanApplicationDetailsScreen.dart';
import '../../Features/Home/Screen/CustomerDetailsScreen.dart'; // Added this
import '../../Features/Home/Screen/singleLoanDetailScreen.dart';
import '../../Features/Notification/view/seller_notification_screen.dart';
import '../../Features/Parent/Screen/Parent_screen.dart';
import '../../Features/Payment/Screen/Payment_Screen.dart';
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

    RouteName.collectPaymentScreen: (context) =>
        const CollectPaymentScreen(),
    RouteName.brandSelectForManager: (context) =>
        const BrandSelectForManager(),
    RouteName.editCustomerScreen: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      if (args == null || args.isEmpty) {
        // Fallback বা Error Handle
        return const Scaffold(
          body: Center(child: Text('Customer ID not found')),
        );
      }
      return EditCustomerScreen(customerId: args);
    },
    RouteName.singleLoanDetailScreen: (context) {
      // arguments থেকে loanId নিন
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is String) {
        return SingleLoanDetailScreen(loanId: arguments);
      }
      // Fallback - যদি arguments না আসে
      return const Scaffold(
        body: Center(
          child: Text('No Loan ID provided'),
        ),
      );
    },

    RouteName.totalCustomerScreen: (context) =>
        const TotalCustomerScreen(),
    RouteName.paymentScreen: (context) =>
        const PaymentScreen(),
    RouteName.pendingApprovalScreen: (context) =>
        const PendingApprovalScreen(),
    RouteName.activeLoanScreen: (context) =>
        const ActiveLoanScreen(),
    RouteName.overdueLoanScreen: (context) =>
        const OverdueLoanScreen(),
    RouteName.sellerNotificationScreen: (context) =>
        const SellerNotificationScreen(),
    RouteName.loanApplicationDetailsScreen: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      return LoanApplicationDetailsScreen(applicationId: id);
    },
    RouteName.customerDetailsScreen: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      return CustomerDetailsScreen(customerId: id);
    },


    // ── Customer Feature Routes ──────────────────────────
    RouteName.customerParentScreen: (context) => const CustomerParentScreen(),
    RouteName.customerHomeScreen: (context) => const CustomerHomeScreen(),
    RouteName.customerDocumentsScreen: (context) =>
        const CustomerDocumentsScreen(),
    RouteName.customerNotificationScreen: (context) =>
        const CustomerNotificationScreen(),
    RouteName.customerLoanApplicationListScreen: (context) =>
        const CustomerLoanApplicationListScreen(),
    RouteName.profileScreen: (context) =>
        const ProfileScreen(),
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
