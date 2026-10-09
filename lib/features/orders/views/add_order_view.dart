import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../../products/controllers/product_controller.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/order_model.dart';
import '../../onboarding/controllers/business_controller.dart';

class AddOrderView extends StatefulWidget {
  final OrderModel? order;
  const AddOrderView({super.key, this.order});

  @override
  State<AddOrderView> createState() => _AddOrderViewState();
}

class _AddOrderViewState extends State<AddOrderView> {
  final OrderController _orderController = Get.find<OrderController>();
  final ProductController _productController = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();

  ProductModel? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _courierName = 'Steadfast';
  final List<String> _couriers = ['Steadfast', 'Pathao', 'RedX', 'eCourier', 'Paperfly', 'Sundarban', 'SA Paribahan', 'Other'];
  final _courierCostController = TextEditingController(text: '60');
  final _discountController = TextEditingController(text: '0');

  String _status = 'Pending';
  final List<String> _statuses = ['Pending', 'Confirmed', 'Shipped', 'Delivered', 'Returned', 'Cancelled', 'RTO'];
  bool _isPaymentReceived = false;

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _customerNameController.text = widget.order!.customerName ?? '';
      _phoneController.text = widget.order!.phone ?? '';
      _courierName = widget.order!.courier ?? 'Steadfast';
      _courierCostController.text = widget.order!.courierCost.toString();
      _discountController.text = widget.order!.discount.toString();
      _status = widget.order!.status;
      _isPaymentReceived = widget.order!.isPaymentReceived;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _courierCostController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && (_selectedProduct != null || widget.order != null)) {
      FocusScope.of(context).unfocus();
      
      bool success;
      if (widget.order == null) {
        success = await _orderController.addOrder(
          product: _selectedProduct!,
          quantity: int.tryParse(_quantityController.text) ?? 1,
          customerName: _customerNameController.text.trim(),
          phone: _phoneController.text.trim(),
          courier: _courierName,
          status: _status,
          discount: double.tryParse(_discountController.text) ?? 0,
          courierCost: double.tryParse(_courierCostController.text) ?? 70,
          isPaymentReceived: _isPaymentReceived,
        );
      } else {
        success = await _orderController.editOrder(
          orderId: widget.order!.id,
          customerName: _customerNameController.text.trim(),
          phone: _phoneController.text.trim(),
          courier: _courierName,
          status: _status,
          discount: double.tryParse(_discountController.text) ?? 0,
          courierCost: double.tryParse(_courierCostController.text) ?? 0,
          // isPaymentReceived: _isPaymentReceived, // Causes DB error if column missing
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
        title: Text(widget.order == null ? 'Add Order' : 'Edit Order'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Customer Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(labelText: 'Customer Name *', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number *', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                ),
                
                const SizedBox(height: 32),
                const Text('Product & Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                
                if (widget.order == null) ...[
                  DropdownButtonFormField<ProductModel>(
                    decoration: const InputDecoration(labelText: 'Product *', prefixIcon: Icon(Icons.inventory_2_outlined)),
                    initialValue: _selectedProduct,
                    items: _productController.products.map((product) {
                      return DropdownMenuItem(value: product, child: Text(product.name));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProduct = value;
                        if (value != null) {
                          _discountController.text = value.defaultDiscount.toStringAsFixed(0);
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Please select a product' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedProduct != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Stock', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text(
                                '${_selectedProduct!.stockQuantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedProduct!.stockQuantity < 10 ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Cost', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text('${Get.find<BusinessController>().currencySymbol}${_selectedProduct!.productCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Price', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text('${Get.find<BusinessController>().currencySymbol}${_selectedProduct!.sellingPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                
                Row(
                  children: [
                    if (widget.order == null) ...[
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Quantity'),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Status'),
                        initialValue: _status,
                        items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (value) => setState(() => _status = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Courier Name', prefixIcon: Icon(Icons.local_shipping_outlined)),
                        initialValue: _courierName,
                        items: _couriers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (value) => setState(() => _courierName = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Delivery Area'),
                        initialValue: 'Inside City',
                        items: const [
                          DropdownMenuItem(value: 'Inside City', child: Text('Inside City')),
                          DropdownMenuItem(value: 'Outside City', child: Text('Outside City')),
                          DropdownMenuItem(value: 'Sub-city', child: Text('Sub-city')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == 'Inside City') {
                              _courierCostController.text = '60';
                            } else if (value == 'Outside City') {
                              _courierCostController.text = '120';
                            } else if (value == 'Sub-city') {
                              _courierCostController.text = '100';
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _courierCostController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: 'Courier Cost', prefixText: '${Get.find<BusinessController>().currencySymbol} '),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _discountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: 'Discount Given', prefixText: '${Get.find<BusinessController>().currencySymbol} '),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: _isPaymentReceived ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPaymentReceived ? Colors.green.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: SwitchListTile(
                    title: const Text('Payment Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      _isPaymentReceived ? 'Payment Received / Advance Paid' : 'Payment Pending',
                      style: TextStyle(
                        color: _isPaymentReceived ? Colors.green[700] : Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: _isPaymentReceived,
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      setState(() {
                        _isPaymentReceived = value;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                Obx(() => ElevatedButton(
                  onPressed: _orderController.isLoading.value ? null : _submit,
                  child: _orderController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(widget.order == null ? 'Save Order' : 'Update Order'),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
