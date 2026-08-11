import 'package:provider/provider.dart';

import '../../Features/Auth/ModelView/Auth_Screen_Provider.dart';
import '../../Features/Home/ViewModel/Brand_Selection_Model.dart';
import '../../Features/Home/ViewModel/SalesDashboardViewModel.dart';
import '../../Features/Home/ViewModel/LoanApplicationViewModel.dart';
import '../../Features/Home/ViewModel/CustomerDetailViewModel.dart'; // Added this
import '../../Features/Notification/viewModel/sellerNotificationProvider.dart';
import '../../Features/Order/viewModel/OrderSummaryViewModel.dart';
import '../../Features/Parent/ViewModel/Parent_screen_provider.dart';
import '../../Features/Payment/viewmodel/PaymentHistoryViewModel.dart';
import '../../Features/Profile/viewmodel/profileScreenProvider.dart';
import '../../Features/multy_form/viewModel/multyform_provider.dart';
import '../../CustomerFeature/parent/viewModel/customerParentViewModel.dart';
import '../../CustomerFeature/home/viewModel/home_view_model.dart';
import '../../CustomerFeature/payment/viewModel/customer_payment_history_view_model.dart';
import '../../CustomerFeature/home/viewModel/loan_view_model.dart';
import '../../CustomerFeature/home/viewModel/loan_application_view_model.dart';
import '../../CustomerFeature/home/viewModel/notification_view_model.dart';
import '../../CustomerFeature/profile/viewModel/customer_profile_view_model.dart';

class AppProviders {
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<ParentScreenProvider>(
        create: (context) => ParentScreenProvider(),
      ),
      ChangeNotifierProvider<AuthScreenProvider>(
        create: (context) => AuthScreenProvider(),
      ),
      ChangeNotifierProvider<CheckoutViewModel>(
        create: (context) => CheckoutViewModel(),
      ),
      ChangeNotifierProvider<BrandSelectionViewModel>(
        create: (context) => BrandSelectionViewModel(),
      ),
      ChangeNotifierProvider<SalesDashboardViewModel>(
        create: (context) => SalesDashboardViewModel(),
      ),
      ChangeNotifierProvider<LoanApplicationViewModel>(
        create: (context) => LoanApplicationViewModel(),
      ),
      ChangeNotifierProvider<CustomerDetailViewModel>( // Added this
        create: (context) => CustomerDetailViewModel(),
      ),
      
      // ── Customer Feature Providers ────────────────────────
      ChangeNotifierProvider<CustomerParentViewModel>(
        create: (context) => CustomerParentViewModel(),
      ),
      ChangeNotifierProvider<CustomerHomeViewModel>(
        create: (context) => CustomerHomeViewModel(),
      ),
      ChangeNotifierProvider<CustomerPaymentHistoryViewModel>(
        create: (context) => CustomerPaymentHistoryViewModel(),
      ),
      ChangeNotifierProvider<CustomerLoanViewModel>(
        create: (context) => CustomerLoanViewModel(),
      ),
      ChangeNotifierProvider<CustomerLoanApplicationViewModel>(
        create: (context) => CustomerLoanApplicationViewModel(),
      ),
      ChangeNotifierProvider<CustomerNotificationViewModel>(
        create: (context) => CustomerNotificationViewModel(),
      ),
      ChangeNotifierProvider<CustomerProfileViewModel>(
        create: (context) => CustomerProfileViewModel(),
      ),

      ChangeNotifierProvider<OrderSummaryViewModel>(
        create: (context) => OrderSummaryViewModel(),
      ),

      ChangeNotifierProvider<PaymentHistoryViewModel>(
        create: (context) => PaymentHistoryViewModel(),
      ),

      ChangeNotifierProvider<ProfileProvider>(
        create: (context) => ProfileProvider(),
      ),

      ChangeNotifierProvider<SellerNotificationProvider>(
        create: (context) => SellerNotificationProvider(),
      ),
    ];
  }
}