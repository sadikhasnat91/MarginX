import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import 'package:intl/intl.dart';

import '../../../data/models/expense_model.dart';

class AddExpenseView extends StatefulWidget {
  final ExpenseModel? expense;
  const AddExpenseView({super.key, this.expense});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _category = 'Advertising';
  final List<String> _categories = [
    'Advertising',
    'Courier',
    'Packaging',
    'Salary',
    'Rent',
    'Software',
    'Payment Fee',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description ?? '';
      _selectedDate = widget.expense!.date;
      _category = widget.expense!.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      bool success;
      if (widget.expense == null) {
        success = await _expenseController.addExpense(
          amount: double.tryParse(_amountController.text) ?? 0,
          category: _category,
          date: _selectedDate,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        );
      } else {
        success = await _expenseController.editExpense(
          expenseId: widget.expense!.id,
          amount: double.tryParse(_amountController.text) ?? 0,
          category: _category,
          date: _selectedDate,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        );
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category *', prefixIcon: Icon(Icons.category_outlined)),
                  initialValue: _category,
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount *', prefixText: '৳ '),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description (Optional)', alignLabelWithHint: true),
                ),
                
                const SizedBox(height: 48),
                Obx(() => ElevatedButton(
                  onPressed: _expenseController.isLoading.value ? null : _submit,
                  child: _expenseController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(widget.expense == null ? 'Save Expense' : 'Update Expense'),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
