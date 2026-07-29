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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // 🚀 Check Authentication Token and Navigate
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    // এনিমেশন দেখার জন্য ন্যূনতম ২-৩ সেকেন্ড বিলম্ব রাখা ভালো
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final tokenStorage = AppStorage();
    final token = await tokenStorage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // 🟢 Token আছে -> ParentScreen (Home)-এ নিয়ে যাও এবং ব্যাক স্ট্যাক ক্লিয়ার করো
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteName.parentScreen,
            (route) => false,
      );
    } else {
      // 🔴 Token নাই -> LoginScreen-এ নিয়ে যাও
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
                    Image.asset("assets/icons/logo.png"),
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