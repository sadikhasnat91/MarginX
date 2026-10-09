import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../../data/models/business_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/views/dashboard_view.dart';

class BusinessController extends GetxController {
  static BusinessController get instance => Get.find();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  final Rx<BusinessModel?> currentBusiness = Rx<BusinessModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isCheckingBusiness = true.obs;

  @override
  void onInit() {
    super.onInit();
    
    final authController = Get.find<AuthController>();
    
    // Listen for auth changes
    ever(authController.currentUser, (User? user) {
      if (user != null) {
        checkAndLoadBusiness(user.id);
      } else {
        currentBusiness.value = null;
        isCheckingBusiness.value = false;
      }
    });
    
    // Check initially since ever only triggers on change
    if (authController.currentUser.value != null) {
      checkAndLoadBusiness(authController.currentUser.value!.id);
    } else {
      isCheckingBusiness.value = false;
    }
  }

  Future<void> checkAndLoadBusiness(String userId) async {
    try {
      // Only show full-screen loading if we don't have a business loaded yet
      if (currentBusiness.value == null) {
        isCheckingBusiness.value = true;
      }
      final response = await _supabase
          .from('businesses')
          .select()
          .eq('owner_id', userId)
          .maybeSingle();

      if (response != null) {
        currentBusiness.value = BusinessModel.fromJson(response);
      } else {
        currentBusiness.value = null;
      }
    } catch (e) {
      debugPrint('Error loading business: $e');
      currentBusiness.value = null;
    } finally {
      isCheckingBusiness.value = false;
    }
  }

  String get currencySymbol {
    final currency = currentBusiness.value?.currency ?? 'BDT';
    switch (currency) {
      case 'USD': return '\$';
      case 'INR': return '₹';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'PKR': return 'Rs';
      case 'BDT':
      default: return '৳';
    }
  }

  Future<void> createBusiness({
    required String name,
    String? category,
    String? monthlyOrderVolume,
    String? sellingChannel,
    String currency = 'BDT',
  }) async {
    final user = Get.find<AuthController>().currentUser.value;
    if (user == null) return;

    try {
      isLoading.value = true;
      
      final businessData = {
        'owner_id': user.id,
        'name': name,
        'category': category,
        'monthly_order_volume': monthlyOrderVolume,
        'selling_channel': sellingChannel,
        'currency': currency,
      };

      final response = await _supabase
          .from('businesses')
          .insert(businessData)
          .select()
          .single();

      currentBusiness.value = BusinessModel.fromJson(response);
      
      Get.offAll(() => const DashboardView());
    } catch (e) {
      Get.snackbar('Error', 'Could not create business profile: $e', 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateBusiness({
    required String name,
    String? category,
    String? logoUrl,
    String? currency,
  }) async {
    final business = currentBusiness.value;
    if (business == null) return false;

    try {
      isLoading.value = true;
      
      final businessData = {
        'name': name,
        'category': category,
        'logo_url': logoUrl,
      };
      
      if (currency != null) {
        businessData['currency'] = currency;
      }

      final response = await _supabase
          .from('businesses')
          .update(businessData)
          .eq('id', business.id)
          .select()
          .single();

      currentBusiness.value = BusinessModel.fromJson(response);
      
      Get.snackbar('Success', 'Profile updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Could not update profile: $e', 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
