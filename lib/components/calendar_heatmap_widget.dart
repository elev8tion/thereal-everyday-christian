import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

/// Calendar heatmap widget showing reading activity over time
/// Similar to GitHub's contribution graph
class CalendarHeatmapWidget extends StatelessWidget {
  final Map<DateTime, int> activityData;
  final int columns;
  final double cellSize;
  final Color Function(int count) colorForCount;

  const CalendarHeatmapWidget({
    super.key,
    required this.activityData,
    this.columns = 12,
    this.cellSize = 12.0,
    Color Function(int count)? colorForCount,
  }) : colorForCount = colorForCount ?? _defaultColorForCount;

  static Color _defaultColorForCount(int count) {
    if (count == 0) return Colors.white.withValues(alpha: 0.1);
    if (count == 1) return AppTheme.primaryColor.withValues(alpha: 0.3);
    if (count == 2) return AppTheme.primaryColor.withValues(alpha: 0.6);
    return AppTheme.primaryColor.withValues(alpha: 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = columns * 7; // Show 7 rows (days of week) * columns
    final startDate = now.subtract(Duration(days: days - 1));

    // Group dates by week
    final List<List<DateTime>> weeks = [];
    DateTime currentDate = startDate;

    for (int i = 0; i < columns; i++) {
      final week = <DateTime>[];
      for (int j = 0; j < 7; j++) {
        week.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
        if (currentDate.isAfter(now)) break;
      }
      weeks.add(week);
      if (currentDate.isAfter(now)) break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels (M, W, F)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDayLabel('M', 0, context),
                  _buildDayLabel('', 1, context),
                  _buildDayLabel('W', 2, context),
                  _buildDayLabel('', 3, context),
                  _buildDayLabel('F', 4, context),
                  _buildDayLabel('', 5, context),
                  _buildDayLabel('', 6, context),
                ],
              ),
            ),
            // Heatmap grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weeks.map((week) => _buildWeekColumn(week, context)).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildDayLabel(String label, int index, BuildContext context) {
    return SizedBox(
      height: cellSize + 4,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 10, minSize: 8, maxSize: 12),
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekColumn(List<DateTime> week, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Column(
        children: week.map((date) => _buildDayCell(date, context)).toList(),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, BuildContext context) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final count = activityData[normalizedDate] ?? 0;
    final color = colorForCount(count);
    final now = DateTime.now();
    final isToday = normalizedDate.year == now.year &&
        normalizedDate.month == now.month &&
        normalizedDate.day == now.day;

    return Tooltip(
      message: '${_formatDate(date)}: ${count > 0 ? '$count reading${count > 1 ? 's' : ''}' : 'No activity'}',
      child: Container(
        width: cellSize,
        height: cellSize,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.xs / 4),
          border: isToday
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 10, minSize: 8, maxSize: 12),
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        _buildLegendCell(0, context),
        _buildLegendCell(1, context),
        _buildLegendCell(2, context),
        _buildLegendCell(3, context),
        const SizedBox(width: 8),
        Text(
          'More',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 10, minSize: 8, maxSize: 12),
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendCell(int count, BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: colorForCount(count),
        borderRadius: BorderRadius.circular(AppRadius.xs / 4),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
