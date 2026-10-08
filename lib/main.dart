import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/views/login_view.dart';
import 'features/dashboard/views/dashboard_view.dart';
import 'features/onboarding/controllers/business_controller.dart';
import 'features/onboarding/views/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  bool isSupabaseInitialized = false;

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty && supabaseUrl != 'your_supabase_url_here') {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
      isSupabaseInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
    }
  }

  if (isSupabaseInitialized) {
    // Initialize global controllers
    Get.put(AuthController());
    runApp(const MarginXApp());
  } else {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Supabase is not configured.\n\nPlease open the .env file and add your SUPABASE_URL and SUPABASE_ANON_KEY, then restart the app.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ),
      ),
    ));
  }
}

class MarginXApp extends StatelessWidget {
  const MarginXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MarginX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const RootView(),
    );
  }
}

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final businessController = Get.put(BusinessController());

    return Obx(() {
      if (authController.isAuthenticated) {
        if (businessController.isCheckingBusiness.value) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (businessController.currentBusiness.value == null) {
          return const OnboardingView();
        }
        
        return const DashboardView();
      } else {
        return const LoginView();
      }
    });
  }
}
