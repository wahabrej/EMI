import 'package:flutter/cupertino.dart';

import '../../Features/Auth/Screen/Login_Screen.dart';
import '../../Features/Auth/Screen/Sign_Up_Screen.dart';
import '../../Features/EMI/Screen/EmiRepaymentScheduleScreen.dart';
import '../../Features/Home/Screen/brand_selection_screen.dart';
import '../../Features/Parent/Screen/Parent_screen.dart';
import '../../Features/Splash/Splash_Screen.dart';
import '../../Features/multy_form/multyform_screen.dart';
import 'Routes_name.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    //'/': (context) => InterestingScreen(),
    '/': (context) => SplashScreen(),

    RouteName.parentScreen: (context) => const ParentScreen(),
    RouteName.loginScreen: (context) => const LoginScreen(),
    RouteName.signUpScreen: (context) => const SignUpScreen(),
    RouteName.checkoutParentScreen: (context) => const CheckoutScreen(),
    RouteName.brandSelectionScreen: (context) => const BrandSelectionScreen(),
    RouteName.emiRepaymentScheduleScreen: (context) => const EmiRepaymentScheduleScreen(),

  };
}