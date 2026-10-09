import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/business_controller.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final BusinessController _businessController = Get.find<BusinessController>();
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedOrderVolume;
  String? _selectedChannel;
  String _selectedCurrency = 'BDT';

  final List<String> _categories = [
    'Fashion & Apparel',
    'Cosmetics & Beauty',
    'Electronics',
    'Home & Lifestyle',
    'Shoes & Accessories',
    'Food & Groceries',
    'Other'
  ];

  final List<String> _orderVolumes = [
    '0 - 50',
    '51 - 200',
    '201 - 500',
    '501 - 2000',
    '2000+'
  ];

  final List<String> _channels = [
    'Facebook',
    'Instagram',
    'Website / E-commerce',
    'WhatsApp',
    'Physical Store',
    'Other'
  ];

  final List<String> _currencies = [
    'BDT',
    'USD',
    'INR',
    'EUR',
    'GBP',
    'PKR'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _businessController.createBusiness(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        monthlyOrderVolume: _selectedOrderVolume,
        sellingChannel: _selectedChannel,
        currency: _selectedCurrency,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to MarginX',
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s set up your business profile to start tracking your real profit.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Business Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Business Name *',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter business name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    initialValue: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                  ),
                  const SizedBox(height: 16),
                  
                  // Order Volume Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Monthly Orders',
                      prefixIcon: Icon(Icons.local_shipping_outlined),
                    ),
                    initialValue: _selectedOrderVolume,
                    items: _orderVolumes.map((volume) {
                      return DropdownMenuItem(value: volume, child: Text(volume));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedOrderVolume = value),
                  ),
                  const SizedBox(height: 16),
                  
                  // Selling Channel Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Primary Selling Channel',
                      prefixIcon: Icon(Icons.public),
                    ),
                    initialValue: _selectedChannel,
                    items: _channels.map((channel) {
                      return DropdownMenuItem(value: channel, child: Text(channel));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedChannel = value),
                  ),
                  const SizedBox(height: 16),
                  
                  // Currency Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Primary Currency',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    value: _selectedCurrency,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(value: currency, child: Text(currency));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCurrency = value ?? 'BDT'),
                  ),
                  
                  const SizedBox(height: 32),
                  Obx(() => ElevatedButton(
                    onPressed: _businessController.isLoading.value ? null : _submit,
                    child: _businessController.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Continue'),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
