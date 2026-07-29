import 'package:provider/provider.dart';

import '../../Features/Auth/ModelView/Auth_Screen_Provider.dart';
import '../../Features/Home/ViewModel/Brand_Selection_Model.dart';
import '../../Features/Home/ViewModel/SalesDashboardViewModel.dart';
import '../../Features/Parent/ViewModel/Parent_screen_provider.dart';
import '../../Features/multy_form/viewModel/multyform_provider.dart';

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
      // 🟢 ২. এখানে BrandSelectionViewModel যোগ করে দিন
      ChangeNotifierProvider<BrandSelectionViewModel>(
        create: (context) => BrandSelectionViewModel(),
      ),
      ChangeNotifierProvider<SalesDashboardViewModel>(
        create: (context) => SalesDashboardViewModel(),
      ),
    ];
  }
}