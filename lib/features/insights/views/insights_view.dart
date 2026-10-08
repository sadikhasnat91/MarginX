import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/profit_calculation_service.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfitCalculationService profitService = Get.find<ProfitCalculationService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights & Analytics'),
      ),
      body: Obx(() {
        final revenue = profitService.totalRevenue.value;
        final profit = profitService.totalRealProfit.value;
        final margin = profitService.profitMargin.value;
        
        final productCost = profitService.totalProductCost.value;
        final courierCost = profitService.totalCourierCost.value;
        final returnLoss = profitService.totalReturnLoss.value;
        final expenses = profitService.totalExpenses.value;
        
        final totalCosts = productCost + courierCost + returnLoss + expenses;
        
        if (revenue == 0 && totalCosts == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_chart_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No Data Available', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Add some orders and expenses to see your insights.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Financial Overview',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Key Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(context, 'Margin', '${margin.toStringAsFixed(1)}%', margin >= 0 ? Colors.green : Colors.red),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStatCard(context, 'Total ROI', revenue > 0 ? '${((profit / totalCosts) * 100).toStringAsFixed(1)}%' : '0%', Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Cost Breakdown Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Where is your money going?', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              if (productCost > 0)
                                PieChartSectionData(color: Colors.blue, value: productCost, title: 'Product', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              if (courierCost > 0)
                                PieChartSectionData(color: Colors.orange, value: courierCost, title: 'Courier', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              if (returnLoss > 0)
                                PieChartSectionData(color: Colors.red, value: returnLoss, title: 'Returns', radius: 60, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              if (expenses > 0)
                                PieChartSectionData(color: Colors.purple, value: expenses, title: 'Ads/Other', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              if (profit > 0)
                                PieChartSectionData(color: Colors.green, value: profit, title: 'Profit', radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Legend
                      _buildLegend(context, 'Product Cost', Colors.blue, productCost),
                      _buildLegend(context, 'Courier Cost', Colors.orange, courierCost),
                      _buildLegend(context, 'Return Losses', Colors.red, returnLoss),
                      _buildLegend(context, 'Expenses (Ads, etc.)', Colors.purple, expenses),
                      const Divider(),
                      _buildLegend(context, 'Real Profit', Colors.green, profit),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Order Performance
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Performance', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOrderStat('Total', profitService.totalOrdersCount.value, Colors.grey),
                          _buildOrderStat('Delivered', profitService.deliveredOrdersCount.value, Colors.green),
                          _buildOrderStat('Returned', profitService.returnedOrdersCount.value, Colors.red),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (profitService.totalOrdersCount.value > 0)
                        LinearProgressIndicator(
                          value: profitService.deliveredOrdersCount.value / profitService.totalOrdersCount.value,
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          color: Colors.green,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      const SizedBox(height: 8),
                      if (profitService.totalOrdersCount.value > 0)
                        Center(
                          child: Text(
                            'Delivery Success Rate: ${((profitService.deliveredOrdersCount.value / profitService.totalOrdersCount.value) * 100).toStringAsFixed(1)}%',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMiniStatCard(BuildContext context, String title, String value, Color color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String label, Color color, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Text('৳${amount.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrderStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
