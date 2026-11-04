import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../domain/statistics_calculator.dart';

double _niceMax(num value) {
  if (value <= 0) return 1000;
  final exp = math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
  final m = value / exp;
  final nice = m <= 1 ? 1 : m <= 2 ? 2 : m <= 5 ? 5 : 10;
  return nice * exp;
}

Widget _axisLabel(String text, TitleMeta meta, BuildContext context) => SideTitleWidget(
      meta: meta,
      space: 6,
      child: Text(
        text,
        style: TextStyle(fontSize: 10.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );

FlGridData _grid(BuildContext context, double interval) => FlGridData(
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (_) => FlLine(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
        strokeWidth: 1,
        dashArray: [4, 4],
      ),
    );

/// Grouped bars: income (green) vs expense (red) per month.
class IncomeExpenseBarChart extends StatelessWidget {
  const IncomeExpenseBarChart({super.key, required this.months, required this.format, this.height = 200});
  final List<MonthTotal> months;
  final String Function(int) format;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxY = _niceMax(months.fold<int>(0, (m, e) => math.max(m, math.max(e.income, e.expense))));
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: _grid(context, maxY / 4),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 4,
                getTitlesWidget: (v, meta) => _axisLabel(compactNumber(v), meta, context),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= months.length) return const SizedBox.shrink();
                  return _axisLabel(DateFormats.shortMonth.format(months[i].month), meta, context);
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItem: (group, _, rod, rodIndex) => BarTooltipItem(
                '${rodIndex == 0 ? 'Masuk' : 'Keluar'}\n${format(rod.toY.round())}',
                TextStyle(color: scheme.onInverseSurface, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          barGroups: [
            for (final (i, m) in months.indexed)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(
                    toY: m.income.toDouble(),
                    color: AppColors.income,
                    width: 9,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: m.expense.toDouble(),
                    color: AppColors.expense,
                    width: 9,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }
}

/// Single-series line chart for spending trends.
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.values,
    required this.labelFor,
    required this.format,
    this.color = AppColors.expense,
    this.height = 200,
    this.labelEvery = 1,
  });

  final List<int> values;

  /// Bottom axis label for index i.
  final String Function(int i) labelFor;
  final String Function(int) format;
  final Color color;
  final double height;
  final int labelEvery;

  @override
  Widget build(BuildContext context) {
    final maxY = _niceMax(values.fold<int>(0, math.max));
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          minX: 0,
          maxX: math.max(0, values.length - 1).toDouble(),
          gridData: _grid(context, maxY / 4),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 4,
                getTitlesWidget: (v, meta) => _axisLabel(compactNumber(v), meta, context),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (v != i || i < 0 || i >= values.length) return const SizedBox.shrink();
                  if (i % labelEvery != 0 && i != values.length - 1) return const SizedBox.shrink();
                  return _axisLabel(labelFor(i), meta, context);
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${labelFor(s.x.toInt())}\n${format(s.y.round())}',
                    TextStyle(color: scheme.onInverseSurface, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (final (i, v) in values.indexed) FlSpot(i.toDouble(), v.toDouble())],
              isCurved: true,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(show: values.length <= 12),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }
}

/// Donut chart of expense by category with a legend.
class CategoryDonutChart extends StatefulWidget {
  const CategoryDonutChart({super.key, required this.totals, required this.format});
  final List<CategoryTotal> totals;
  final String Function(int) format;

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totals = widget.totals;
    final sum = totals.fold<int>(0, (s, t) => s + t.amount);
    final focused = _touched != null && _touched! < totals.length ? totals[_touched!] : null;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 62,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions) return;
                      setState(() => _touched = response?.touchedSection?.touchedSectionIndex);
                    },
                  ),
                  sections: [
                    for (final (i, t) in totals.indexed)
                      PieChartSectionData(
                        value: t.amount.toDouble(),
                        color: t.category.color,
                        radius: i == _touched ? 30 : 24,
                        showTitle: false,
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 200),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    focused?.category.name ?? 'Total',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    compactNumber(focused?.amount ?? sum),
                    style: theme.textTheme.titleLarge,
                  ),
                  if (focused != null)
                    Text('${(focused.share * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final (i, t) in totals.indexed)
          InkWell(
            onTap: () => setState(() => _touched = _touched == i ? null : i),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: t.category.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.category.name,
                      style: TextStyle(fontWeight: i == _touched ? FontWeight.w700 : FontWeight.w500),
                    ),
                  ),
                  Text('${(t.share * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 12),
                  Text(widget.format(t.amount), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.items});
  final List<(String, Color)> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: [
        for (final (label, color) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}
