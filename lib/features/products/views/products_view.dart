import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import 'add_product_view.dart';
import '../../onboarding/controllers/business_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_ui_elements.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final ProductController _productController = Get.put(ProductController());
  final BusinessController _businessController = Get.find<BusinessController>();
  final TextEditingController _searchController = TextEditingController();

  String _stockFilter = 'All'; // All, Low Stock, In Stock
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Products & Inventory',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
      ),
      body: Obx(() {
        if (_productController.isLoading.value && _productController.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_productController.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF1F5F9) : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 20),
                Text('No products yet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Add products to calculate margins and track stock levels.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddProductView()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Product'),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).scale(),
          );
        }

        final allProducts = _productController.products;
        final filteredProducts = allProducts.where((p) {
          final matchesFilter = _stockFilter == 'All' ||
              (_stockFilter == 'Low Stock' && p.stockQuantity <= 10) ||
              (_stockFilter == 'In Stock' && p.stockQuantity > 10);

          final q = _searchQuery.toLowerCase();
          final matchesSearch = q.isEmpty || p.name.toLowerCase().contains(q);

          return matchesFilter && matchesSearch;
        }).toList();

        final lowStockCount = allProducts.where((p) => p.stockQuantity <= 10).length;

        return RefreshIndicator(
          onRefresh: _productController.fetchProducts,
          child: Column(
            children: [
              // Search & Filter header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isLight ? const Color(0xFFD8DEE6) : Colors.white12,
                          width: 1.2,
                        ),
                        boxShadow: isLight
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search product name...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isLight ? const Color(0xFF94A3B8) : Colors.white54,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter tabs
                    Row(
                      children: [
                        _buildFilterPill('All', allProducts.length),
                        const SizedBox(width: 8),
                        _buildFilterPill('In Stock', allProducts.length - lowStockCount),
                        const SizedBox(width: 8),
                        _buildFilterPill('Low Stock', lowStockCount, isAlert: lowStockCount > 0),
                      ],
                    ),
                  ],
                ),
              ),

              // Product Cards
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 800;

                          if (isDesktop) {
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth >= 1200 ? 3 : 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 220,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(
                                  context: context,
                                  product: filteredProducts[index],
                                  productController: _productController,
                                  businessController: _businessController,
                                  theme: theme,
                                  index: index,
                                );
                              },
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: filteredProducts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              return _buildProductCard(
                                context: context,
                                product: filteredProducts[index],
                                productController: _productController,
                                businessController: _businessController,
                                theme: theme,
                                index: index,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddProductView()),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildFilterPill(String label, int count, {bool isAlert = false}) {
    final isSelected = _stockFilter.toLowerCase() == label.toLowerCase();
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return InkWell(
      onTap: () => setState(() => _stockFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isAlert ? const Color(0xFFDC2626) : theme.colorScheme.primary)
              : (isLight ? Colors.white : theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isAlert ? const Color(0xFFDC2626) : theme.colorScheme.primary)
                : (isLight ? const Color(0xFFD8DEE6) : Colors.white12),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAlert && count > 0) ...[
              const PulsingStatusDot(color: Color(0xFFDC2626), size: 7),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white24 : (isLight ? const Color(0xFFF1F5F9) : Colors.white12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : (isLight ? const Color(0xFF64748B) : Colors.white70),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required dynamic product,
    required ProductController productController,
    required BusinessController businessController,
    required ThemeData theme,
    required int index,
  }) {
    final isLight = theme.brightness == Brightness.light;
    final margin = product.sellingPrice > 0
        ? ((product.sellingPrice - product.productCost - product.packagingCost) / product.sellingPrice) * 100
        : 0.0;
    final isLowStock = product.stockQuantity <= 10;

    Color marginColor = const Color(0xFF059669);
    if (margin < 15) {
      marginColor = const Color(0xFFDC2626);
    } else if (margin < 30) {
      marginColor = const Color(0xFFD97706);
    }

    return HoverableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Icon with Gradient
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                      AppTheme.primaryLight.withValues(alpha: 0.22),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.inventory_2_rounded, color: theme.colorScheme.primary, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Cost: ${businessController.currencySymbol}${product.productCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLight ? const Color(0xFF64748B) : Colors.white60,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const PulsingStatusDot(color: Color(0xFFDC2626), size: 6),
                                const SizedBox(width: 4),
                                Text(
                                  'Low Stock: ${product.stockQuantity}',
                                  style: const TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            'Stock: ${product.stockQuantity}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isLight ? const Color(0xFF475569) : Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit Product',
                    style: IconButton.styleFrom(
                      backgroundColor: isLight ? const Color(0xFFF1F5F9) : Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 17, color: Colors.blue),
                    onPressed: () => Get.to(() => AddProductView(product: product)),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Delete Product',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 17, color: Color(0xFFDC2626)),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Text('Delete Product'),
                            ],
                          ),
                          content: Text(
                            'Are you sure you want to delete "${product.name}"?\nThis cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: isLight ? const Color(0xFFF1F5F9) : Colors.white10,
                                foregroundColor: isLight ? const Color(0xFF475569) : Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: isLight ? const BorderSide(color: Color(0xFFE2E8F0)) : BorderSide.none,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Get.back();
                                productController.deleteProduct(product.id);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price & Margin Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Selling Price: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLight ? const Color(0xFF64748B) : Colors.white60,
                          ),
                        ),
                        Text(
                          '${businessController.currencySymbol}${product.sellingPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: marginColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${margin.toStringAsFixed(1)}% margin',
                        style: TextStyle(
                          color: marginColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (margin / 100).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: isLight ? const Color(0xFFE2E8F0) : Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(marginColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
