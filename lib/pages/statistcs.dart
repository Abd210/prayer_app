import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/azkar_storage.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Azkar Statistics')),
      body: FutureBuilder<Map<String, Map<String, bool>>>(
        future: AzkarStorage.loadStats(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          if (data.isEmpty) {
            return const Center(
              child: Text('No statistics yet.\nFinish any Azkar list and come back!',
                  textAlign: TextAlign.center),
            );
          }

          // Sort newest on top
          final dates = data.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, idx) {
              final day = dates[idx];
              final done = data[day]!;
              final completedCount = done.values.where((e) => e).length;
              final progress = completedCount / done.length;

              final niceDate =
                  DateFormat.yMMMMEEEEd().format(DateTime.parse(day));

              return Card(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(niceDate,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        color: theme.colorScheme.primary,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.2),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: done.entries.map((e) {
                          return Chip(
                            avatar: Icon(
                              e.value ? Icons.check_circle : Icons.cancel,
                              size: 18,
                              color: e.value
                                  ? Colors.green
                                  : theme.colorScheme.error,
                            ),
                            label: Text(e.key),
                            backgroundColor: e.value
                                ? Colors.green.withOpacity(.15)
                                : theme.colorScheme.error.withOpacity(.12),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
