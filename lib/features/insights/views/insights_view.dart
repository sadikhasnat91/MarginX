import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/services/profit_calculation_service.dart';
import '../../onboarding/controllers/business_controller.dart';
import '../../../core/widgets/animated_ui_elements.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfitCalculationService profitService = Get.find<ProfitCalculationService>();
    final BusinessController businessController = Get.find<BusinessController>();
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Insights & Profit Analytics',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
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
        final totalOrders = profitService.totalOrdersCount.value;
        final deliveredOrders = profitService.deliveredOrdersCount.value;
        final returnedOrders = profitService.returnedOrdersCount.value;

        if (revenue == 0 && totalCosts == 0) {
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
                  child: Icon(Icons.insights_rounded, size: 64, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 20),
                Text('No Data Available', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Add orders and expenses to see real-time profit analytics.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).scale(),
          );
        }

        final deliveryRate = totalOrders > 0 ? (deliveredOrders / totalOrders) * 100 : 0.0;
        final roi = totalCosts > 0 ? (profit / totalCosts) * 100 : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top 3 Stat Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildKPIPillCard(
                      context: context,
                      title: 'Net Margin',
                      value: margin,
                      suffix: '%',
                      isPositive: margin >= 0,
                      accentColor: margin >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      icon: margin >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      delayMs: 100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKPIPillCard(
                      context: context,
                      title: 'Return on Cost (ROI)',
                      value: roi,
                      suffix: '%',
                      isPositive: roi >= 0,
                      accentColor: const Color(0xFF2563EB),
                      icon: Icons.auto_graph_rounded,
                      delayMs: 150,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKPIPillCard(
                      context: context,
                      title: 'Delivery Rate',
                      value: deliveryRate,
                      suffix: '%',
                      isPositive: deliveryRate >= 80,
                      accentColor: deliveryRate >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706),
                      icon: Icons.local_shipping_outlined,
                      delayMs: 200,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Main Cards Grid (Desktop: Side-by-Side, Mobile: Stacked)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 850;

                  final costBreakdownCard = HoverableCard(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cost & Profit Breakdown',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isLight ? const Color(0xFFF1F5F9) : Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Gross: ${businessController.currencySymbol}${revenue.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Pie Chart
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 45,
                              sections: [
                                if (productCost > 0)
                                  PieChartSectionData(
                                    color: const Color(0xFF2563EB),
                                    value: productCost,
                                    title: '${((productCost / (revenue > 0 ? revenue : totalCosts)) * 100).toStringAsFixed(0)}%',
                                    radius: 46,
                                    titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                if (courierCost > 0)
                                  PieChartSectionData(
                                    color: const Color(0xFFD97706),
                                    value: courierCost,
                                    title: '${((courierCost / (revenue > 0 ? revenue : totalCosts)) * 100).toStringAsFixed(0)}%',
                                    radius: 46,
                                    titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                if (returnLoss > 0)
                                  PieChartSectionData(
                                    color: const Color(0xFFDC2626),
                                    value: returnLoss,
                                    title: '${((returnLoss / (revenue > 0 ? revenue : totalCosts)) * 100).toStringAsFixed(0)}%',
                                    radius: 54,
                                    titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                if (expenses > 0)
                                  PieChartSectionData(
                                    color: const Color(0xFF7C3AED),
                                    value: expenses,
                                    title: '${((expenses / (revenue > 0 ? revenue : totalCosts)) * 100).toStringAsFixed(0)}%',
                                    radius: 46,
                                    titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                if (profit > 0)
                                  PieChartSectionData(
                                    color: const Color(0xFF059669),
                                    value: profit,
                                    title: '${((profit / (revenue > 0 ? revenue : totalCosts)) * 100).toStringAsFixed(0)}%',
                                    radius: 52,
                                    titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Detailed Linear Proportion Bars
                        _buildDetailedCostRow(
                          label: 'Product Sourcing',
                          amount: productCost,
                          total: revenue > 0 ? revenue : totalCosts,
                          color: const Color(0xFF2563EB),
                          currency: businessController.currencySymbol,
                          isLight: isLight,
                        ),
                        _buildDetailedCostRow(
                          label: 'Courier Delivery Fees',
                          amount: courierCost,
                          total: revenue > 0 ? revenue : totalCosts,
                          color: const Color(0xFFD97706),
                          currency: businessController.currencySymbol,
                          isLight: isLight,
                        ),
                        _buildDetailedCostRow(
                          label: 'Return / RTO Losses',
                          amount: returnLoss,
                          total: revenue > 0 ? revenue : totalCosts,
                          color: const Color(0xFFDC2626),
                          currency: businessController.currencySymbol,
                          isLight: isLight,
                        ),
                        _buildDetailedCostRow(
                          label: 'Ads & Operations',
                          amount: expenses,
                          total: revenue > 0 ? revenue : totalCosts,
                          color: const Color(0xFF7C3AED),
                          currency: businessController.currencySymbol,
                          isLight: isLight,
                        ),
                        const Divider(height: 24),
                        _buildDetailedCostRow(
                          label: 'Real Net Profit',
                          amount: profit > 0 ? profit : 0,
                          total: revenue > 0 ? revenue : totalCosts,
                          color: const Color(0xFF059669),
                          currency: businessController.currencySymbol,
                          isLight: isLight,
                          isBold: true,
                        ),
                      ],
                    ),
                  );

                  final orderPerformanceCard = HoverableCard(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fulfillment & Delivery Health',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Large Circular Success Meter
                        Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  (deliveryRate >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706))
                                      .withValues(alpha: 0.1),
                                  Colors.transparent,
                                ],
                              ),
                              border: Border.all(
                                color: (deliveryRate >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706))
                                    .withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedCounter(
                                    value: deliveryRate,
                                    suffix: '%',
                                    fractionDigits: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 26,
                                      letterSpacing: -1,
                                      color: deliveryRate >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706),
                                    ),
                                  ),
                                  Text(
                                    'Delivery Rate',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isLight ? const Color(0xFF64748B) : Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 3 Stat Badges
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricPill(
                                label: 'Total Orders',
                                count: totalOrders,
                                color: isLight ? const Color(0xFF0F172A) : Colors.white,
                                bgColor: isLight ? const Color(0xFFF1F5F9) : Colors.white10,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricPill(
                                label: 'Delivered',
                                count: deliveredOrders,
                                color: const Color(0xFF059669),
                                bgColor: const Color(0xFF059669).withValues(alpha: 0.12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricPill(
                                label: 'Returned',
                                count: returnedOrders,
                                color: const Color(0xFFDC2626),
                                bgColor: const Color(0xFFDC2626).withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Progress line
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: totalOrders > 0 ? (deliveredOrders / totalOrders).clamp(0.0, 1.0) : 0.0,
                            backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          deliveryRate >= 80
                              ? 'Your delivery success rate is healthy! Keep following up on dispatched parcels.'
                              : 'High returns detected. Consider phone confirmation before shipping orders.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLight ? const Color(0xFF64748B) : Colors.white60,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: costBreakdownCard.animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0)),
                        const SizedBox(width: 16),
                        Expanded(child: orderPerformanceCard.animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.06, end: 0)),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      costBreakdownCard.animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
                      const SizedBox(height: 16),
                      orderPerformanceCard.animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.06, end: 0),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildKPIPillCard({
    required BuildContext context,
    required String title,
    required double value,
    String suffix = '',
    required bool isPositive,
    required Color accentColor,
    required IconData icon,
    required int delayMs,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return HoverableCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isLight ? const Color(0xFF64748B) : Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedCounter(
            value: value,
            suffix: suffix,
            fractionDigits: 1,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
              color: accentColor,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delayMs.ms, duration: 350.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildDetailedCostRow({
    required String label,
    required double amount,
    required double total,
    required Color color,
    required String currency,
    required bool isLight,
    bool isBold = false,
  }) {
    final pct = total > 0 ? (amount / total) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                      color: isLight ? (isBold ? Colors.black87 : const Color(0xFF475569)) : Colors.white70,
                    ),
                  ),
                ],
              ),
              Text(
                '$currency${amount.toStringAsFixed(0)} (${pct.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isBold ? color : (isLight ? const Color(0xFF1E293B) : Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: isLight ? const Color(0xFFF1F5F9) : Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
