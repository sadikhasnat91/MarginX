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
        
        return ListView(
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
                      Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                      Get.snackbar('Theme Changed', 'Applied ${Get.isDarkMode ? "Light" : "Dark"} Mode.', snackPosition: SnackPosition.BOTTOM);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security_outlined),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      if (user?.email != null) {
                        try {
                          await Supabase.instance.client.auth.resetPasswordForEmail(user!.email!);
                          Get.snackbar('Success', 'Password reset email sent!', backgroundColor: Colors.green, colorText: Colors.white);
                        } catch (e) {
                          Get.snackbar('Error', 'Could not send reset email.');
                        }
                      }
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
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                foregroundColor: Colors.red,
                elevation: 0,
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ],
        );
      }),
    );
  }

  void _showEditProfileDialog(BuildContext context, BusinessController controller) {
    final business = controller.currentBusiness.value;
    if (business == null) return;

    final nameController = TextEditingController(text: business.name);
    final categoryController = TextEditingController(text: business.category ?? '');
    final logoController = TextEditingController(text: business.logoUrl ?? '');

    Get.defaultDialog(
      title: 'Edit Business Profile',
      content: Column(
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
        ],
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await controller.updateBusiness(
          name: nameController.text.trim(),
          category: categoryController.text.trim(),
          logoUrl: logoController.text.trim(),
        );
      },
    );
  }
}
