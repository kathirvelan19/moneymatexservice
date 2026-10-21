import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedView = 0; // 0: Pie Chart, 1: Bar Chart, 2: Monthly Trend

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    // Group expenses by category
    final Map<Category, double> categoryTotals = {};
    for (var exp in provider.expenses) {
      categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0.0) + exp.amount;
    }

    // Monthly aggregation
    final Map<String, double> monthlyTotals = {};
    final monthFormat = DateFormat('MMM yyyy');
    for (var exp in provider.expenses) {
      final key = monthFormat.format(exp.date);
      monthlyTotals[key] = (monthlyTotals[key] ?? 0.0) + exp.amount;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        title: const Text('Spending Analytics', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1D192B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D192B)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Visual Spending Intelligence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D192B))),
                        SizedBox(height: 2),
                        Text('Comprehensive breakdown of categories, monthly trends, and expense distribution.', style: TextStyle(fontSize: 12, color: Color(0xFF79747E))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Segmented View Filter
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _viewTabButton('Distribution', 0, Icons.pie_chart),
                        ),
                        Expanded(
                          child: _viewTabButton('Bar View', 1, Icons.bar_chart),
                        ),
                        Expanded(
                          child: _viewTabButton('Trends', 2, Icons.show_chart),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (provider.expenses.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEBF6)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.query_stats, size: 52, color: Color(0xFF5E43A5)),
                          SizedBox(height: 12),
                          Text('No analytics data available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D192B))),
                          SizedBox(height: 4),
                          Text('Record expenses or scan receipts to unlock charts and reports.', style: TextStyle(color: Color(0xFF79747E), fontSize: 12)),
                        ],
                      ),
                    )
                  else ...[
                    // Active Chart View
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedView == 0
                                ? 'Category Share (%)'
                                : _selectedView == 1
                                    ? 'Category Spending Breakdown (₹)'
                                    : 'Monthly Spending Trend (₹)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D192B)),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 240,
                            child: _selectedView == 0
                                ? _buildPieChart(categoryTotals, provider.totalSpending)
                                : _selectedView == 1
                                    ? _buildBarChart(categoryTotals)
                                    : _buildLineChart(monthlyTotals),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category Details List
                    const Text('Category Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D192B))),
                    const SizedBox(height: 10),

                    ...categoryTotals.entries.map((entry) {
                      final color = _getCategoryColor(entry.key);
                      final pct = provider.totalSpending > 0 ? (entry.value / provider.totalSpending * 100) : 0.0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEFEBF6)),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                              ),
                            ),
                          ),
                          title: Text(entry.key.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('${pct.toStringAsFixed(1)}% of total expenses', style: const TextStyle(fontSize: 11, color: Color(0xFF79747E))),
                          trailing: Text(
                            '₹${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1D192B)),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _viewTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedView == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isSelected ? const Color(0xFF5E43A5) : const Color(0xFF79747E)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFF5E43A5) : const Color(0xFF79747E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<Category, double> totals, double totalSpending) {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 46,
        sections: totals.entries.map((entry) {
          final color = _getCategoryColor(entry.key);
          final pct = totalSpending > 0 ? (entry.value / totalSpending * 100) : 0.0;
          return PieChartSectionData(
            color: color,
            value: entry.value,
            title: '${pct.toStringAsFixed(0)}%',
            radius: 54,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(Map<Category, double> totals) {
    final entries = totals.entries.toList();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: entries.fold(0.0, (max, e) => e.value > max ? e.value : max) * 1.2,
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) return const SizedBox.shrink();
                final name = entries[index].key.name;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    name.length > 5 ? name.substring(0, 4) : name,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF79747E), fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) {
                return Text(
                  value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF79747E)),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          final color = _getCategoryColor(entry.key);
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: color,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(Map<String, double> monthlyTotals) {
    if (monthlyTotals.isEmpty) {
      return const Center(child: Text('No historical monthly records.'));
    }
    final entries = monthlyTotals.entries.toList();
    final spots = entries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
    final maxY = entries.fold(0.0, (max, e) => e.value > max ? e.value : max) * 1.2;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    entries[idx].key.split(' ')[0],
                    style: const TextStyle(fontSize: 10, color: Color(0xFF79747E), fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (val, meta) => Text(
                val >= 1000 ? '${(val / 1000).toStringAsFixed(0)}k' : val.toStringAsFixed(0),
                style: const TextStyle(fontSize: 10, color: Color(0xFF79747E)),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxY > 0 ? maxY : 1000,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF5E43A5),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF5E43A5).withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(Category cat) {
    switch (cat) {
      case Category.Food: return const Color(0xFFEF4444);
      case Category.Travel: return const Color(0xFF3B82F6);
      case Category.Shopping: return const Color(0xFFEC4899);
      case Category.Bills: return const Color(0xFFF59E0B);
      case Category.Recharge: return const Color(0xFF00BA88);
      case Category.Entertainment: return const Color(0xFF8B5CF6);
      case Category.Healthcare: return const Color(0xFF06B6D4);
      default: return const Color(0xFF79747E);
    }
  }
}
