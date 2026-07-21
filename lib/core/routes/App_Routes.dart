import 'package:flutter/cupertino.dart';

import '../../Features/Parent/Screen/Parent_screen.dart';
import '../../Features/Splash/Splash_Screen.dart';
import 'Routes_name.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    //'/': (context) => InterestingScreen(),
    '/': (context) => SplashScreen(),

    RouteName.parentScreen: (context) => const ParentScreen(),

  };
}