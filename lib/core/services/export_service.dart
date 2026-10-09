import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../../data/models/order_model.dart';
import '../../features/onboarding/controllers/business_controller.dart';

class ExportService {
  static Future<void> generateInvoicePdf(OrderModel order) async {
    final business = Get.find<BusinessController>().currentBusiness.value;
    final currencySymbol = Get.find<BusinessController>().currencySymbol;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    business?.name ?? 'MarginX Business',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, color: PdfColors.grey)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(order.customerName ?? 'Customer'),
                      if (order.phone != null) pw.Text(order.phone!),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice Date: ${DateFormat('MMM dd, yyyy').format(order.orderDate ?? DateTime.now())}'),
                      pw.Text('Status: ${order.status}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Description', 'Amount'],
                  <String>['Order ID: ${order.id.substring(0, 8)}', '$currencySymbol${order.sellingPrice.toStringAsFixed(2)}'],
                  <String>['Discount', '-$currencySymbol${order.discount.toStringAsFixed(2)}'],
                  <String>['Courier / Shipping', '$currencySymbol${order.courierCost.toStringAsFixed(2)}'],
                  <String>['Total (Net Revenue)', '$currencySymbol${(order.sellingPrice - order.discount).toStringAsFixed(2)}'],
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text('Thank you for your business!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${order.customerName ?? "order"}.pdf',
    );
  }

  static Future<void> exportOrdersToExcel(List<OrderModel> orders) async {
    try {
      final currencySymbol = Get.find<BusinessController>().currencySymbol;
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Orders'];
      excel.setDefaultSheet('Orders');

      // Add Headers
      sheetObject.appendRow([
        TextCellValue('Date'),
        TextCellValue('Customer Name'),
        TextCellValue('Phone'),
        TextCellValue('Status'),
        TextCellValue('Revenue ($currencySymbol)'),
        TextCellValue('Product Cost ($currencySymbol)'),
        TextCellValue('Courier Cost ($currencySymbol)'),
        TextCellValue('Net Profit ($currencySymbol)'),
      ]);

      // Add Data
      for (var order in orders) {
        final netProfit = order.sellingPrice - order.discount - order.productCost - order.courierCost - order.packagingCost - order.adAllocation - order.paymentFee - order.returnCost - order.otherCost;
        final revenue = order.sellingPrice - order.discount;

        sheetObject.appendRow([
          TextCellValue(order.orderDate != null ? DateFormat('yyyy-MM-dd').format(order.orderDate!) : ''),
          TextCellValue(order.customerName ?? ''),
          TextCellValue(order.phone ?? ''),
          TextCellValue(order.status),
          TextCellValue(revenue.toStringAsFixed(2)),
          TextCellValue(order.productCost.toStringAsFixed(2)),
          TextCellValue(order.courierCost.toStringAsFixed(2)),
          TextCellValue(netProfit.toStringAsFixed(2)),
        ]);
      }

      var fileBytes = excel.save();
      if (fileBytes != null) {
        if (GetPlatform.isWeb) {
          // Web download requires different approach if needed, but for now we'll just try to save locally if not web,
          // Actually, saving on mobile requires path_provider
          Get.snackbar('Notice', 'Excel export is supported on Desktop/Mobile natively. Web requires html download.');
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final path = '${directory.path}/Orders_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);
          Get.snackbar('Success', 'Excel saved at: $path', duration: const Duration(seconds: 5));
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to export to Excel: $e');
    }
  }
}
