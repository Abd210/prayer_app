import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/azkar_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Timeframe { daily, weekly, monthly }

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with TickerProviderStateMixin {
  late Future<Map<String, Map<String, bool>>> _future;
  late TabController _tabCtrl;

  /* cached */
  late Map<DateTime, Map<String, bool>> _dailyRaw;
  late Map<DateTime, double> _dailyRatio;
  
  // Heat map data
  Map<DateTime, int> _heatMapData = {};
  
  /* selection */
  DateTime? _selectedDay; // for daily detail

  /* KPI */
  int _totalDays = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _completedAzkar = 0;
  double _avgCompletionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _future = AzkarStorage.loadStats();
    _tabCtrl = TabController(length: 3, vsync: this);
    _generateHeatMapData();
  }
  
  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }
  
  void _generateHeatMapData() {
    // This will be populated with actual data after loading azkar stats
  }

  void _computeKpis() {
    /* KPI calculation logic */
    final now = DateTime.now();
    
    // Total days with data
    _totalDays = _dailyRaw.length;
    
    // Calculate total completed azkar
    _completedAzkar = 0;
    for (final dayData in _dailyRaw.values) {
      _completedAzkar += dayData.values.where((v) => v).length;
    }
    
    // Calculate average completion rate
    if (_totalDays > 0) {
      double totalRatio = 0;
      for (final ratio in _dailyRatio.values) {
        totalRatio += ratio;
      }
      _avgCompletionRate = totalRatio / _totalDays;
    }
    
    // Current streak
    var streak = 0;
    var date = now;
    while (_dailyRaw.containsKey(DateTime(date.year, date.month, date.day))) {
      final dayData = _dailyRaw[DateTime(date.year, date.month, date.day)]!;
      final completed = dayData.values.where((v) => v).length / dayData.length >= 0.5;
      if (!completed) break;
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    _currentStreak = streak;
    
    // Best streak
    int bestStreak = 0;
    int currentBest = 0;
    final sortedDates = _dailyRaw.keys.toList()..sort();
    for (int i = 0; i < sortedDates.length; i++) {
      if (i > 0) {
        final prevDate = sortedDates[i - 1];
        final currentDate = sortedDates[i];
        final dayData = _dailyRaw[currentDate]!;
        final completed = dayData.values.where((v) => v).length / dayData.length >= 0.5;
        
        if (completed && currentDate.difference(prevDate).inDays == 1) {
          currentBest++;
        } else {
          currentBest = completed ? 1 : 0;
        }
        
        bestStreak = max(bestStreak, currentBest);
      } else {
        final dayData = _dailyRaw[sortedDates[i]]!;
        final completed = dayData.values.where((v) => v).length / dayData.length >= 0.5;
        currentBest = completed ? 1 : 0;
        bestStreak = max(bestStreak, currentBest);
      }
    }
    _bestStreak = bestStreak;
    
    // Populate heat map data from actual azkar completion
    _heatMapData.clear();
    for (final entry in _dailyRaw.entries) {
      final date = entry.key;
      final dayData = entry.value;
      final completionRate = dayData.values.where((v) => v).length / dayData.length;
      
      // Map completion rate to 1-5 scale
      int heatValue = 1;
      if (completionRate >= 0.95) heatValue = 5;
      else if (completionRate >= 0.75) heatValue = 4;
      else if (completionRate >= 0.5) heatValue = 3;
      else if (completionRate >= 0.25) heatValue = 2;
      
      _heatMapData[date] = heatValue;
    }
  }

  /* ───────────────────────── BUILD ───────────────────────── */

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, Map<String, bool>>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(loc.statsTitle)),
            body: Center(
              child: Text(
                loc.statsNoData,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        /* 1) Pre‑compute once */
        _dailyRaw = snap.data!.map(
          (k, v) => MapEntry(DateTime.parse(k), Map<String, bool>.from(v)),
        );
        _dailyRatio = _dailyRaw.map(
          (d, v) => MapEntry(d, v.values.where((e) => e).length / v.length),
        );

        _computeKpis();
        _selectedDay ??=
            _dailyRaw.keys.reduce((a, b) => a.isAfter(b) ? a : b);

        /* 2) UI */
        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            title: Text('Azkar Statistics', 
                style: TextStyle(fontWeight: FontWeight.w600)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          body: Column(
            children: [
              _buildStatsSummary(context, loc),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: loc.tabDaily.toUpperCase()),
                    Tab(text: loc.tabWeekly.toUpperCase()),
                    Tab(text: loc.tabMonthly.toUpperCase()),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _dailyView(context, loc),
                    _periodView(context, loc, Timeframe.weekly),
                    _periodView(context, loc, Timeframe.monthly),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ───────────────────── KPI Cards ───────────────────── */

  Widget _buildStatsSummary(BuildContext ctx, AppLocalizations loc) {
    final theme = Theme.of(ctx);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Your Azkar Journey',
              style: TextStyle(
                color: theme.colorScheme.onPrimary.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statCard(
                        context: ctx,
                        icon: Icons.calendar_today_rounded,
                        value: '$_totalDays',
                        label: loc.kpiDays,
                        iconColor: theme.colorScheme.primary,
                      ),
                      _verticalDivider(theme),
                      _statCard(
                        context: ctx,
                        icon: Icons.local_fire_department_rounded,
                        value: '$_currentStreak',
                        label: loc.kpiStreak,
                        iconColor: Colors.orange,
                      ),
                      _verticalDivider(theme),
                      _statCard(
                        context: ctx,
                        icon: Icons.emoji_events_rounded,
                        value: '$_bestStreak',
                        label: loc.kpiBest,
                        iconColor: Colors.amber,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCard(
                        context: ctx,
                        icon: Icons.check_circle_outline_rounded,
                        value: '$_completedAzkar',
                        label: 'Completed',
                        iconColor: Colors.green,
                      ),
                      _verticalDivider(theme),
                      _statCard(
                        context: ctx,
                        icon: Icons.percent_rounded,
                        value: '${(_avgCompletionRate * 100).toStringAsFixed(0)}%',
                        label: 'Success Rate',
                        iconColor: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _verticalDivider(ThemeData theme) {
    return Container(
      height: 50,
      width: 1,
      color: theme.dividerColor.withOpacity(0.2),
    );
  }
  
  Widget _statCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /* ───────────────────── DAILY VIEW ───────────────────── */

  Widget _dailyView(BuildContext ctx, AppLocalizations loc) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: [
        _chartCard(ctx, loc, Timeframe.daily, _dailyRatio, onTap: (d) {
          setState(() => _selectedDay = d);
        }),
        const SizedBox(height: 16),
        _dailyDetailCard(ctx, loc),
        const SizedBox(height: 16),
        _buildHeatMap(ctx),
      ],
    );
  }

  Widget _dailyDetailCard(BuildContext ctx, AppLocalizations loc) {
    final t = Theme.of(ctx);
    final entries = _dailyRaw[_selectedDay]!;
    
    // Calculate completion percentage for the selected day
    final completed = entries.values.where((v) => v).length;
    final total = entries.length;
    final completionPercentage = total > 0 ? (completed / total * 100) : 0;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: t.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: t.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat.yMMMMEEEEd().format(_selectedDay!),
                          style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCompletionColor(completionPercentage.toDouble(), t).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${completionPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _getCompletionColor(completionPercentage.toDouble(), t),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Azkar for this day',
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: t.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries.entries.map((e) {
                final done = e.value;
                return Chip(
                  avatar: Icon(
                    done ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: done ? Colors.green : t.colorScheme.error,
                  ),
                  label: Text(
                    e.key,
                    style: TextStyle(
                      fontSize: 13,
                      color: t.colorScheme.onSurface,
                    ),
                  ),
                  backgroundColor: done
                      ? Colors.green.withOpacity(.12)
                      : t.colorScheme.error.withOpacity(.08),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCompletionColor(double percentage, ThemeData theme) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return theme.colorScheme.primary;
    if (percentage >= 40) return theme.colorScheme.secondary;
    if (percentage >= 20) return Colors.orange;
    return theme.colorScheme.error;
  }
  
  // Heat map calendar
  Widget _buildHeatMap(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.auto_graph_rounded,
                    color: theme.colorScheme.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Consistency Calendar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            HeatMapCalendar(
              datasets: _heatMapData,
              colorMode: ColorMode.color,
              colorsets: {
                1: theme.colorScheme.error.withOpacity(0.3),
                2: theme.colorScheme.error.withOpacity(0.7),
                3: theme.colorScheme.secondary,
                4: theme.colorScheme.primary,
                5: Colors.green,
              },
              textColor: theme.textTheme.bodyMedium?.color,
              showColorTip: false,
              defaultColor: theme.colorScheme.surface,
              monthFontSize: 14,
              weekFontSize: 12,
              borderRadius: 4,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _colorLegendItem(theme.colorScheme.error.withOpacity(0.3), 'Poor'),
                  const SizedBox(width: 12),
                  _colorLegendItem(theme.colorScheme.error.withOpacity(0.7), 'Fair'),
                  const SizedBox(width: 12),
                  _colorLegendItem(theme.colorScheme.secondary, 'Good'),
                  const SizedBox(width: 12),
                  _colorLegendItem(theme.colorScheme.primary, 'Great'),
                  const SizedBox(width: 12),
                  _colorLegendItem(Colors.green, 'Excellent'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _colorLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  /* ───────────────────── WEEKLY / MONTHLY ───────────────────── */

  Widget _periodView(BuildContext ctx, AppLocalizations loc, Timeframe tf) {
    final ratios = switch (tf) {
      Timeframe.weekly => _aggregate(_dailyRatio, _weekKey),
      Timeframe.monthly => _aggregate(_dailyRatio, _monthKey),
      _ => _dailyRatio,
    };

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: [
        _chartCard(ctx, loc, tf, ratios),
        const SizedBox(height: 16),
        if (tf == Timeframe.weekly) _buildWeeklyInsights(ctx),
        if (tf == Timeframe.monthly) _buildMonthlyInsights(ctx),
      ],
    );
  }
  
  Widget _buildWeeklyInsights(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Weekly Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInsightItem(
              theme, 
              'Best Day', 
              'Friday', 
              Icons.star_rounded, 
              theme.colorScheme.primary
            ),
            _buildInsightItem(
              theme, 
              'Needs Improvement', 
              'Monday', 
              Icons.trending_down_rounded, 
              theme.colorScheme.error
            ),
            _buildInsightItem(
              theme, 
              'Most Completed', 
              'Morning Azkar', 
              Icons.check_circle_rounded, 
              Colors.green
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMonthlyInsights(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: theme.colorScheme.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Monthly Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildMonthlyProgressChart(theme),
            const SizedBox(height: 16),
            _buildInsightItem(
              theme, 
              'Perfect Days', 
              '12 days with 100% completion', 
              Icons.workspace_premium_rounded, 
              theme.colorScheme.primary
            ),
            _buildInsightItem(
              theme, 
              'Most Consistent', 
              'Evening Azkar', 
              Icons.nights_stay_rounded, 
              theme.colorScheme.secondary
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMonthlyProgressChart(ThemeData theme) {
    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final weekNumber = value.toInt() + 1;
                  return Text(
                    'W$weekNumber',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 0.6),
                const FlSpot(1, 0.7),
                const FlSpot(2, 0.65),
                const FlSpot(3, 0.8),
              ],
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.primary,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.15),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ],
          minY: 0,
          maxY: 1,
        ),
      ),
    );
  }
  
  Widget _buildInsightItem(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /* ───────────────────── CHART ───────────────────── */

  Widget _chartCard(BuildContext ctx, AppLocalizations loc, Timeframe tf,
      Map<DateTime, double> data,
      {Function(DateTime)? onTap}) {
    if (data.length < 2) {
      final msg = loc.needMoreData(_periodName(tf, loc));
      return _placeholderCard(msg, ctx);
    }

    final entries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final first = entries.first.key;
    final spots = [
      for (final e in entries)
        FlSpot(e.key.difference(first).inDays.toDouble(), e.value * 100)
    ];

    final t = Theme.of(ctx);
    final isPrimary = tf == Timeframe.daily;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isPrimary ? t.colorScheme.primary : t.colorScheme.secondary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.show_chart_rounded,
                    color: isPrimary ? t.colorScheme.primary : t.colorScheme.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Azkar Completion ${_getTimeframeTitle(tf)}',
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  lineTouchData: LineTouchData(
                    touchCallback: (evt, res) {
                      if (evt is FlTapUpEvent &&
                          res != null &&
                          res.lineBarSpots != null &&
                          tf == Timeframe.daily &&
                          onTap != null) {
                        final x = res.lineBarSpots!.first.x;
                        final d = first.add(Duration(days: x.toInt()));
                        onTap(d);
                      }
                    },
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: t.colorScheme.surface,
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.all(10),
                      tooltipBorder: BorderSide(
                        color: t.colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                      getTooltipItems: (touched) => touched.map((pt) {
                        final pct = pt.y.toStringAsFixed(1);
                        final date =
                            first.add(Duration(days: pt.x.toInt()));
                        final label = switch (tf) {
                          Timeframe.daily   => DateFormat('d MMM').format(date),
                          Timeframe.weekly  => '${loc.weekShort}${DateFormat('w').format(date)}',
                          Timeframe.monthly => DateFormat('MMM yy').format(date),
                        };
                        return LineTooltipItem(
                          '$label\n$pct %',
                          TextStyle(
                            color: t.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: _bottomTitles(t, first, tf),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        interval: 20,
                        getTitlesWidget: (v, _) =>
                            Text(
                              '${v.toInt()} %',
                              style: TextStyle(
                                fontSize: 11,
                                color: t.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 20,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: t.dividerColor.withOpacity(0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percentage, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: isPrimary ? t.colorScheme.primary : t.colorScheme.secondary,
                            strokeWidth: 2,
                            strokeColor: t.colorScheme.surface,
                          );
                        },
                      ),
                      color: isPrimary ? t.colorScheme.primary : t.colorScheme.secondary,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (isPrimary ? t.colorScheme.primary : t.colorScheme.secondary)
                                .withOpacity(0.3),
                            (isPrimary ? t.colorScheme.primary : t.colorScheme.secondary)
                                .withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTimeframeTitle(Timeframe tf) {
    switch (tf) {
      case Timeframe.daily:
        return 'Daily';
      case Timeframe.weekly:
        return 'Weekly';
      case Timeframe.monthly:
        return 'Monthly';
    }
  }

  Widget _placeholderCard(String msg, BuildContext ctx) {
    final theme = Theme.of(ctx);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black26,
      child: SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timeline_outlined,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                msg,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ───────────────────── Helpers ───────────────────── */

  SideTitles _bottomTitles(ThemeData t, DateTime first, Timeframe tf) {
    return SideTitles(
      showTitles: true,
      interval: switch (tf) {
        Timeframe.daily   => 3,
        Timeframe.weekly  => 2,
        Timeframe.monthly => 1,
      },
      getTitlesWidget: (v, _) {
        final date = first.add(Duration(days: v.toInt()));
        final lbl = switch (tf) {
          Timeframe.daily   => DateFormat('d\nMMM').format(date),
          Timeframe.weekly  =>
              'W${DateFormat('w').format(date)}\n${DateFormat('yy').format(date)}',
          Timeframe.monthly => DateFormat('MMM\nyy').format(date),
        };
        return Text(lbl,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11));
      },
    );
  }

  Map<DateTime, double> _aggregate(
    Map<DateTime, double> base,
    DateTime Function(DateTime) keyFn,
  ) {
    final grouped = <DateTime, List<double>>{};
    for (final e in base.entries) {
      grouped.putIfAbsent(keyFn(e.key), () => []).add(e.value);
    }
    return grouped.map(
        (k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length));
  }

  DateTime _weekKey(DateTime d) =>
      d.subtract(Duration(days: d.weekday - DateTime.monday));
  DateTime _monthKey(DateTime d) => DateTime.utc(d.year, d.month, 1);

  /* period‑name helper for localisation */
  String _periodName(Timeframe tf, AppLocalizations loc) => switch (tf) {
        Timeframe.daily   => loc.periodDaily,
        Timeframe.weekly  => loc.periodWeekly,
        Timeframe.monthly => loc.periodMonthly,
      };
}
