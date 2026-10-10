import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../onboarding/controllers/business_controller.dart';
import '../../../data/models/business_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final BusinessController businessController = Get.find<BusinessController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(() {
        final BusinessModel? business = businessController.currentBusiness.value;
        final user = authController.currentUser.value;
        
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
          children: [
            // User Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: business?.logoUrl != null && business!.logoUrl!.isNotEmpty 
                          ? (business.logoUrl!.startsWith('data:image') 
                              ? MemoryImage(base64Decode(business.logoUrl!.split(',').last)) as ImageProvider
                              : NetworkImage(business.logoUrl!))
                          : null,
                      child: business?.logoUrl == null || business!.logoUrl!.isEmpty 
                          ? Icon(Icons.person, size: 32, color: theme.colorScheme.primary) 
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.email ?? 'Unknown User',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Business Owner',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Business Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {
                    _showEditProfileDialog(context, businessController);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.storefront),
                    title: const Text('Business Name'),
                    subtitle: Text(business?.name ?? 'Not Set'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Category'),
                    subtitle: Text(business?.category ?? 'Not Set'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: const Text('Monthly Order Volume'),
                    subtitle: Text(business?.monthlyOrderVolume ?? 'Not Set'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.public),
                    title: const Text('Selling Channel'),
                    subtitle: Text(business?.sellingChannel ?? 'Not Set'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text('App Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.color_lens_outlined),
                    title: const Text('Theme'),
                    subtitle: Text(Get.isDarkMode ? 'Dark Mode' : 'Light Mode'),
                    trailing: const Icon(Icons.sync),
                    onTap: () {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
                      Get.changeThemeMode(newMode);
                      Get.snackbar(
                        'Theme Changed', 
                        'Switched to ${newMode == ThemeMode.light ? "Light" : "Dark"} Mode.', 
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF1E293B),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security_outlined),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  authController.logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
            ],
            ),
          ),
        );
      }),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFF1F5F9) : Colors.white10,
                    foregroundColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFF475569) : Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: Theme.of(context).brightness == Brightness.light ? const BorderSide(color: Color(0xFFE2E8F0)) : BorderSide.none,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (passwordController.text.length < 6) {
                      Get.snackbar('Error', 'Password must be at least 6 characters.');
                      return;
                    }
                    setState(() => isLoading = true);
                    try {
                      await Supabase.instance.client.auth.updateUser(
                        UserAttributes(password: passwordController.text),
                      );
                      Navigator.pop(context);
                      Get.snackbar('Success', 'Password updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
                    } catch (e) {
                      Get.snackbar('Error', 'Failed to update password.');
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                  child: isLoading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, BusinessController controller) {
    final business = controller.currentBusiness.value;
    if (business == null) return;

    final nameController = TextEditingController(text: business.name);
    final categoryController = TextEditingController(text: business.category ?? '');
    final logoController = TextEditingController(text: business.logoUrl ?? '');
    String selectedCurrency = business.currency;

    final List<String> currencies = ['BDT', 'USD', 'INR', 'EUR', 'GBP', 'PKR'];

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Business Profile'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Business Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: logoController,
                        decoration: const InputDecoration(labelText: 'Profile Image URL (Or Upload)'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      color: Theme.of(context).colorScheme.primary,
                      tooltip: 'Pick from Gallery',
                      onPressed: () async {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 512,
                          maxHeight: 512,
                          imageQuality: 50,
                        );
                        if (image != null) {
                          final bytes = await image.readAsBytes();
                          final base64Image = base64Encode(bytes);
                          final mimeType = image.mimeType ?? 'image/jpeg';
                          logoController.text = 'data:$mimeType;base64,$base64Image';
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Currency'),
                  value: selectedCurrency,
                  items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) selectedCurrency = val;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFF1F5F9) : Colors.white10,
              foregroundColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFF475569) : Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: Theme.of(context).brightness == Brightness.light ? const BorderSide(color: Color(0xFFE2E8F0)) : BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.updateBusiness(
                name: nameController.text.trim(),
                category: categoryController.text.trim(),
                logoUrl: logoController.text.trim(),
                currency: selectedCurrency,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
