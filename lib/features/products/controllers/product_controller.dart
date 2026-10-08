import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';
import '../../onboarding/controllers/business_controller.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load products when the business is available
    ever(Get.find<BusinessController>().currentBusiness, (business) {
      if (business != null) {
        fetchProducts();
      } else {
        products.clear();
      }
    });
    
    // Initial fetch if business is already loaded
    if (Get.find<BusinessController>().currentBusiness.value != null) {
      fetchProducts();
    }
  }

  Future<void> fetchProducts() async {
    final business = Get.find<BusinessController>().currentBusiness.value;
    if (business == null) return;

    try {
      isLoading.value = true;
      final response = await _supabase
          .from('products')
          .select()
          .eq('business_id', business.id)
          .order('created_at', ascending: false);

      products.value = (response as List).map((data) => ProductModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      Get.snackbar('Error', 'Failed to load products.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addProduct({
    required String name,
    String? sku,
    String? category,
    required double sellingPrice,
    required double productCost,
    required double packagingCost,
    required double defaultDiscount,
    required int stockQuantity,
  }) async {
    debugPrint('addProduct called');
    final business = Get.find<BusinessController>().currentBusiness.value;
    if (business == null) {
      debugPrint('business is null');
      return false;
    }

    try {
      isLoading.value = true;
      debugPrint('isLoading set to true');
      
      final productData = {
        'business_id': business.id,
        'name': name,
        'sku': sku,
        'category': category,
        'selling_price': sellingPrice,
        'product_cost': productCost,
        'packaging_cost': packagingCost,
        'default_discount': defaultDiscount,
        'stock_quantity': stockQuantity,
        'is_active': true,
      };

      debugPrint('Inserting data into Supabase: $productData');

      final response = await _supabase
          .from('products')
          .insert(productData)
          .select()
          .single();

      debugPrint('Insert successful: $response');

      final newProduct = ProductModel.fromJson(response);
      products.insert(0, newProduct);
      
      Get.snackbar('Success', 'Product added successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      debugPrint('addProduct completed successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error adding product: $e\n$stackTrace');
      Get.snackbar('Error', 'Could not add product: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
      debugPrint('isLoading set to false');
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      
      await _supabase
          .from('products')
          .delete()
          .eq('id', productId);

      products.removeWhere((p) => p.id == productId);
      
      Get.snackbar('Success', 'Product deleted successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      if (e.toString().contains('foreign key constraint')) {
        Get.snackbar('Cannot Delete', 'This product is linked to existing orders. You cannot delete it.', backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Could not delete product.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> editProduct({
    required String productId,
    required String name,
    String? sku,
    String? category,
    required double sellingPrice,
    required double productCost,
    required double packagingCost,
    required double defaultDiscount,
    required int stockQuantity,
  }) async {
    try {
      isLoading.value = true;
      
      final productData = {
        'name': name,
        'sku': sku,
        'category': category,
        'selling_price': sellingPrice,
        'product_cost': productCost,
        'packaging_cost': packagingCost,
        'default_discount': defaultDiscount,
        'stock_quantity': stockQuantity,
      };

      final response = await _supabase
          .from('products')
          .update(productData)
          .eq('id', productId)
          .select()
          .single();

      final updatedProduct = ProductModel.fromJson(response);
      
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        products[index] = updatedProduct;
      }
      
      Get.snackbar('Success', 'Product updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      Get.snackbar('Error', 'Could not update product.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
