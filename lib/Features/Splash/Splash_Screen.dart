import 'package:flutter/material.dart';
import 'package:smart_pay_app/core/routes/Routes_name.dart';
import '../../core/constant/Token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // 🚀 Redirection Logic
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // লোগো দেখার জন্য ২ সেকেন্ড ওয়েট করুন
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final storage = AppStorage();

    // 🔥 Token এবং Role উভয়ই রিড করুন
    final String? token = await storage.getToken();
    final String? role = await storage.getUserRole();

    debugPrint('🔍 [Splash] Token: ${token != null ? "Present" : "NULL"}');
    debugPrint('🔍 [Splash] Role: $role');

    if (!mounted) return;

    // ✅ নিরাপদ চেক: টোকেন এবং রোল—উভয়ই থাকলে পোর্টালে যাবে
    if (token != null && token.isNotEmpty && role != null && role.isNotEmpty) {
      debugPrint("✅ Authenticated session found.");

      if (role == 'CUSTOMER') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteName.customerParentScreen,
              (route) => false,
        );
      } else {
        // Staff/Admin Roles (MANAGER, AGENT, SHOP, etc.)
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteName.parentScreen,
              (route) => false,
        );
      }
    } else {
      // ❌ টোকেন বা রোল কোনো একটি মিসিং থাকলে সরাসরি লগইন স্ক্রিন
      debugPrint("🚪 Session missing or incomplete. Redirecting to Login.");

      // ডেটা অসম্পূর্ণ থাকলে ক্লিনআপ করে নেওয়া নিরাপদ
      if (token != null || role != null) {
        await storage.clearAll();
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteName.loginScreen,
            (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const SizedBox.shrink(),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/logo.png", height: 120),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
