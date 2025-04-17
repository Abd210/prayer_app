import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/azkar_storage.dart';

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

  /* selection */
  DateTime? _selectedDay; // for daily detail

  /* KPI */
  int _totalDays = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;

  @override
  void initState() {
    super.initState();
    _future = AzkarStorage.loadStats();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  /* ───────────────────────── BUILD ───────────────────────── */

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, Map<String, bool>>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Azkar Statistics')),
            body: const Center(
              child: Text(
                'No statistics yet.\nFinish any Azkar list and come back!',
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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Azkar Statistics'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Stack(
            children: [
              _headerGradient(context),
              SafeArea(
                child: Column(
                  children: [
                    _kpiRow(context),
                    const SizedBox(height: 4),
                    TabBar(
                      controller: _tabCtrl,
                      tabs: const [
                        Tab(text: 'DAILY'),
                        Tab(text: 'WEEKLY'),
                        Tab(text: 'MONTHLY'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _dailyView(context),
                          _periodView(context, Timeframe.weekly),
                          _periodView(context, Timeframe.monthly),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ───────────────────── Header & KPI ───────────────────── */

  Widget _headerGradient(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(.9),
            scheme.secondary.withOpacity(.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _kpiRow(BuildContext ctx) {
    final big = Theme.of(ctx)
        .textTheme
        .labelLarge
        ?.copyWith(fontWeight: FontWeight.bold);
    final small = Theme.of(ctx).textTheme.bodySmall;

    Widget tile(String label, String value) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              children: [Text(value, style: big), const SizedBox(height: 4), Text(label, style: small)],
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 80, 14, 14),
      child: Row(
        children: [
          tile('Days', '$_totalDays'),
          tile('Streak', '$_currentStreak'),
          tile('Best', '$_bestStreak'),
        ],
      ),
    );
  }

  /* ───────────────────── DAILY VIEW ───────────────────── */

  Widget _dailyView(BuildContext ctx) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _chartCard(ctx, Timeframe.daily, _dailyRatio, onTap: (d) {
          setState(() => _selectedDay = d);
        }),
        const SizedBox(height: 18),
        _dailyDetailCard(ctx),
      ],
    );
  }

  Widget _dailyDetailCard(BuildContext ctx) {
    final t = Theme.of(ctx);
    final entries = _dailyRaw[_selectedDay]!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat.yMMMMEEEEd().format(_selectedDay!),
                style: t.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: entries.entries.map((e) {
                final done = e.value;
                return Chip(
                  avatar: Icon(
                    done ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: done ? Colors.green : t.colorScheme.error,
                  ),
                  label: Text(e.key),
                  backgroundColor: done
                      ? Colors.green.withOpacity(.15)
                      : t.colorScheme.error.withOpacity(.12),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /* ───────────────────── WEEKLY / MONTHLY ───────────────────── */

  Widget _periodView(BuildContext ctx, Timeframe tf) {
    final ratios = switch (tf) {
      Timeframe.weekly  => _aggregate(_dailyRatio, _weekKey),
      Timeframe.monthly => _aggregate(_dailyRatio, _monthKey),
      _                 => _dailyRatio,
    };
    final sorted = ratios.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _chartCard(ctx, tf, ratios),
        const SizedBox(height: 18),
        ...sorted.map((e) => _periodCard(ctx, tf, e.key, e.value)),
      ],
    );
  }

  Widget _periodCard(
      BuildContext ctx, Timeframe tf, DateTime key, double ratio) {
    final t = Theme.of(ctx);
    final title = switch (tf) {
      Timeframe.weekly =>
        'Week ${DateFormat('w').format(key)} · ${DateFormat('yyyy').format(key)}',
      Timeframe.monthly =>
        DateFormat.yMMMM().format(key),
      _ => '',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: t.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: t.colorScheme.primary,
              backgroundColor: t.colorScheme.primary.withOpacity(.2),
            ),
            const SizedBox(height: 8),
            Text('${(ratio * 100).toStringAsFixed(1)} % completed',
                style: t.textTheme.bodySmall
                    ?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  /* ───────────────────── CHART CARD ───────────────────── */

  Widget _chartCard(BuildContext ctx, Timeframe tf, Map<DateTime, double> map,
      {void Function(DateTime)? onTap}) {
    if (map.length < 2) {
      return _placeholderCard(
          'Need more data to draw a ${tf.name.toLowerCase()} trend', ctx);
    }

    final entries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final first = entries.first.key;
    final spots = [
      for (final e in entries)
        FlSpot(e.key.difference(first).inDays.toDouble(), e.value * 100)
    ];

    final t = Theme.of(ctx);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 24, 24),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
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
                        Text('${v.toInt()} %',
                            style: const TextStyle(fontSize: 11)),
                  ),
                ),
              ),
              gridData: FlGridData(
                horizontalInterval: 20,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: t.dividerColor, strokeWidth: .4),
              ),
              borderData: FlBorderData(show: false),
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
                  tooltipBgColor: t.colorScheme.surface.withOpacity(.9),
                  getTooltipItems: (touched) => touched.map((pt) {
                    final pct = pt.y.toStringAsFixed(1);
                    final date =
                        first.add(Duration(days: pt.x.toInt()));
                    final label = switch (tf) {
                      Timeframe.daily   => DateFormat('d MMM').format(date),
                      Timeframe.weekly  => 'W${DateFormat('w').format(date)}',
                      Timeframe.monthly => DateFormat('MMM yy').format(date),
                    };
                    return LineTooltipItem('$label\n$pct %',
                        t.textTheme.bodyMedium!);
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  gradient: LinearGradient(
                    colors: [
                      t.colorScheme.primary,
                      t.colorScheme.secondary,
                    ],
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: t.colorScheme.primary.withOpacity(.18),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  Widget _placeholderCard(String msg, BuildContext ctx) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: 160,
          child: Center(
              child: Text(msg, style: Theme.of(ctx).textTheme.bodyMedium)),
        ),
      );

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

  void _computeKpis() {
    _totalDays = _dailyRaw.length;

    final sorted = _dailyRaw.keys.toList()..sort();
    int streak = 0, best = 0;
    DateTime? prev;

    for (final d in sorted) {
      final doneAll = _dailyRatio[d] == 1.0;
      if (doneAll && (prev == null || d.difference(prev).inDays == 1)) {
        streak++;
      } else if (doneAll) {
        streak = 1;
      } else {
        streak = 0;
      }
      best = max(best, streak);
      prev = d;
    }
    _currentStreak = streak;
    _bestStreak = best;
  }
}
