import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
    });
  }

  bool get isAuthenticated => currentUser.value != null;

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      Get.snackbar('Error', e.message, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      await _supabase.auth.signUp(email: email, password: password);
      Get.snackbar('Success', 'Account created! Please check your email to verify.', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } on AuthException catch (e) {
      Get.snackbar('Error', e.message, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _supabase.auth.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Failed to log out.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _supabase.auth.resetPasswordForEmail(email);
      Get.snackbar('Success', 'Password reset email sent.', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } on AuthException catch (e) {
      Get.snackbar('Error', e.message, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
