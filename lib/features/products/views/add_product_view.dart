import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

import '../../../data/models/product_model.dart';

class AddProductView extends StatefulWidget {
  final ProductModel? product;
  const AddProductView({super.key, this.product});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final ProductController _productController = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _productCostController = TextEditingController();
  final _packagingCostController = TextEditingController();
  final _defaultDiscountController = TextEditingController();
  final _stockController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _skuController.text = widget.product!.sku ?? '';
      _categoryController.text = widget.product!.category ?? '';
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _productCostController.text = widget.product!.productCost.toString();
      _packagingCostController.text = widget.product!.packagingCost.toString();
      _defaultDiscountController.text = widget.product!.defaultDiscount.toString();
      _stockController.text = widget.product!.stockQuantity.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _sellingPriceController.dispose();
    _productCostController.dispose();
    _packagingCostController.dispose();
    _defaultDiscountController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      bool success;
      if (widget.product == null) {
        success = await _productController.addProduct(
          name: _nameController.text.trim(),
          sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
          category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
          sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
          productCost: double.tryParse(_productCostController.text) ?? 0,
          packagingCost: double.tryParse(_packagingCostController.text) ?? 0,
          defaultDiscount: double.tryParse(_defaultDiscountController.text) ?? 0,
          stockQuantity: int.tryParse(_stockController.text) ?? 0,
        );
      } else {
        success = await _productController.editProduct(
          productId: widget.product!.id,
          name: _nameController.text.trim(),
          sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
          category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
          sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
          productCost: double.tryParse(_productCostController.text) ?? 0,
          packagingCost: double.tryParse(_packagingCostController.text) ?? 0,
          defaultDiscount: double.tryParse(_defaultDiscountController.text) ?? 0,
          stockQuantity: int.tryParse(_stockController.text) ?? 0,
        );
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Basic Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name *'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _skuController,
                        decoration: const InputDecoration(labelText: 'SKU (Optional)'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Category (Optional)'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text('Pricing & Costs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _sellingPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Selling Price *',
                    prefixText: '৳ ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _productCostController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Product Cost *',
                    prefixText: '৳ ',
                    helperText: 'How much it costs you to buy/make',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _packagingCostController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Packaging Cost',
                          prefixText: '৳ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _defaultDiscountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Default Discount',
                          prefixText: '৳ ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Initial Stock Quantity',
                    prefixIcon: Icon(Icons.inventory),
                  ),
                ),
                
                const SizedBox(height: 48),
                Obx(() => ElevatedButton(
                  onPressed: _productController.isLoading.value ? null : _submit,
                  child: _productController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(widget.product == null ? 'Save Product' : 'Update Product'),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
