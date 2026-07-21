
import 'package:provider/provider.dart';

import '../../Features/Auth/ModelView/Auth_Screen_Provider.dart';
import '../../Features/Parent/ViewModel/Parent_screen_provider.dart';


class AppProviders {
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<ParentScreenProvider>(
        create: (context) => ParentScreenProvider(),
      ),
      ChangeNotifierProvider<AuthScreenProvider>(
        create: (context) => AuthScreenProvider(),
      ),

    ];
  }
}