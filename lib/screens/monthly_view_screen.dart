import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';

class MonthlyViewScreen extends StatefulWidget {
  const MonthlyViewScreen({super.key});

  @override
  State<MonthlyViewScreen> createState() => _MonthlyViewScreenState();
}

class _MonthlyViewScreenState extends State<MonthlyViewScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.monthlyView),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final records = appState.getRecordsForMonth(
            _selectedMonth.year,
            _selectedMonth.month,
          );

          final daysInMonth = DateUtils.getDaysInMonth(
            _selectedMonth.year,
            _selectedMonth.month,
          );

          final onTimeCount = records.where((r) => r.wasOnTime).length;
          final lateCount = records.where((r) => !r.wasOnTime).length;

          return Column(
            children: [
              // Month selector
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(_selectedMonth),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
              
              // Summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SummaryItem(
                      icon: Icons.check_circle,
                      count: onTimeCount,
                      label: AppLocalizations.of(context)!.onTimeArrival,
                      color: Colors.green,
                    ),
                    _SummaryItem(
                      icon: Icons.cancel,
                      count: lateCount,
                      label: AppLocalizations.of(context)!.lateArrival,
                      color: Colors.red,
                    ),
                    _SummaryItem(
                      icon: Icons.calendar_today,
                      count: daysInMonth,
                      label: AppLocalizations.of(context)!.totalDays,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Calendar grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
                    
                    final dayRecord = records.where((r) {
                      return r.date.day == day;
                    }).firstOrNull;

                    final hasRewardAchievement = appState.hasRewardAchievementOnDate(date);

                    return _DayCell(
                      day: day,
                      isOnTime: dayRecord?.wasOnTime,
                      isToday: _isToday(date),
                      hasRewardAchievement: hasRewardAchievement,
                    );
                  },
                ),
              ),

              // Legend
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _LegendItem(color: Colors.green.shade100, label: AppLocalizations.of(context)!.onTimeArrival),
                    _LegendItem(color: Colors.red.shade100, label: AppLocalizations.of(context)!.lateArrival),
                    _LegendItem(color: Colors.amber.shade100, label: 'Reward won'),
                    _LegendItem(color: Colors.grey.shade200, label: AppLocalizations.of(context)!.noRecord),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool? isOnTime;
  final bool isToday;
  final bool hasRewardAchievement;

  const _DayCell({
    required this.day,
    this.isOnTime,
    required this.isToday,
    required this.hasRewardAchievement,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    const textColor = Colors.black87;
    
    if (isOnTime == null) {
      backgroundColor = Colors.grey.shade200;
    } else if (isOnTime!) {
      backgroundColor = Colors.green.shade100;
    } else {
      backgroundColor = Colors.red.shade100;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
          if (isOnTime != null)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Icon(
                isOnTime! ? Icons.check : Icons.close,
                size: 16,
                color: isOnTime! ? Colors.green : Colors.red,
              ),
            ),
          if (hasRewardAchievement)
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.emoji_events,
                size: 12,
                color: Colors.amber,
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

extension FirstWhereOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return null;
    }
    return it.current;
  }
}
