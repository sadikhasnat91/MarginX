import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../../data/models/expense_model.dart';
import '../../onboarding/controllers/business_controller.dart';

class ExpenseController extends GetxController {
  static ExpenseController get instance => Get.find();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<BusinessController>().currentBusiness, (business) {
      if (business != null) {
        fetchExpenses();
      } else {
        expenses.clear();
      }
    });
    
    if (Get.find<BusinessController>().currentBusiness.value != null) {
      fetchExpenses();
    }
  }

  Future<void> fetchExpenses() async {
    final business = Get.find<BusinessController>().currentBusiness.value;
    if (business == null) return;

    try {
      isLoading.value = true;
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('business_id', business.id)
          .order('date', ascending: false);

      expenses.value = (response as List).map((data) => ExpenseModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      Get.snackbar('Error', 'Failed to load expenses.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addExpense({
    required double amount,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    final business = Get.find<BusinessController>().currentBusiness.value;
    if (business == null) return false;

    try {
      isLoading.value = true;
      
      final expenseData = {
        'business_id': business.id,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String().split('T')[0],
        'description': description,
      };

      final response = await _supabase
          .from('expenses')
          .insert(expenseData)
          .select()
          .single();

      final newExpense = ExpenseModel.fromJson(response);
      
      expenses.insert(0, newExpense);
      
      Get.snackbar('Success', 'Expense added successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      Get.snackbar('Error', 'Could not add expense.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      isLoading.value = true;
      
      await _supabase
          .from('expenses')
          .delete()
          .eq('id', expenseId);

      expenses.removeWhere((e) => e.id == expenseId);
      
      Get.snackbar('Success', 'Expense deleted successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      Get.snackbar('Error', 'Could not delete expense.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> editExpense({
    required String expenseId,
    required double amount,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      
      final expenseData = {
        'amount': amount,
        'category': category,
        'date': date.toIso8601String().split('T')[0],
        'description': description,
      };

      final response = await _supabase
          .from('expenses')
          .update(expenseData)
          .eq('id', expenseId)
          .select()
          .single();

      final updatedExpense = ExpenseModel.fromJson(response);
      
      final index = expenses.indexWhere((e) => e.id == expenseId);
      if (index != -1) {
        expenses[index] = updatedExpense;
      }
      
      Get.snackbar('Success', 'Expense updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      Get.snackbar('Error', 'Could not update expense.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
