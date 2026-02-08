import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/app_settings.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay _leaveHomeTime = const TimeOfDay(hour: 7, minute: 45);
  TimeOfDay _arrivalDeadline = const TimeOfDay(hour: 8, minute: 0);
  Set<int> _activeDaysOfWeek = {1, 2, 3, 4, 5}; // Default: Weekdays (Mon-Fri)
  Set<DateTime> _skipDates = {};

  @override
  void initState() {
    super.initState();
    // Load previously saved settings if they exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.settings != null) {
        setState(() {
          _wakeUpTime = appState.settings!.wakeUpTime;
          _leaveHomeTime = appState.settings!.leaveHomeTime;
          _arrivalDeadline = appState.settings!.arrivalDeadline;
          _activeDaysOfWeek = Set<int>.from(appState.settings!.activeDaysOfWeek);
          _skipDates = Set<DateTime>.from(appState.settings!.skipDates);
        });
      }
    });
  }

  Future<void> _selectTime(BuildContext context, String field) async {
    TimeOfDay initial;
    switch (field) {
      case 'wake':
        initial = _wakeUpTime;
        break;
      case 'leave':
        initial = _leaveHomeTime;
        break;
      case 'arrival':
        initial = _arrivalDeadline;
        break;
      default:
        return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      setState(() {
        switch (field) {
          case 'wake':
            _wakeUpTime = picked;
            _validateAndAdjustTimes('wake');
            break;
          case 'leave':
            _leaveHomeTime = picked;
            _validateAndAdjustTimes('leave');
            break;
          case 'arrival':
            _arrivalDeadline = picked;
            _validateAndAdjustTimes('arrival');
            break;
        }
      });
    }
  }

  void _validateAndAdjustTimes(String changedField) {
    // Convert TimeOfDay to minutes for easy comparison
    int wakeMinutes = _wakeUpTime.hour * 60 + _wakeUpTime.minute;
    int leaveMinutes = _leaveHomeTime.hour * 60 + _leaveHomeTime.minute;
    int arrivalMinutes = _arrivalDeadline.hour * 60 + _arrivalDeadline.minute;

    switch (changedField) {
      case 'wake':
        // If wake-up is after leave time, adjust leave time to 15 min after wake
        if (wakeMinutes >= leaveMinutes) {
          int newLeaveMinutes = wakeMinutes + 15;
          _leaveHomeTime = TimeOfDay(
            hour: (newLeaveMinutes ~/ 60) % 24,
            minute: newLeaveMinutes % 60,
          );
          leaveMinutes = newLeaveMinutes;
        }
        // If leave is after arrival, adjust arrival to 15 min after leave
        if (leaveMinutes >= arrivalMinutes) {
          int newArrivalMinutes = leaveMinutes + 15;
          _arrivalDeadline = TimeOfDay(
            hour: (newArrivalMinutes ~/ 60) % 24,
            minute: newArrivalMinutes % 60,
          );
        }
        break;

      case 'leave':
        // If leave is before wake-up, adjust wake-up to 15 min before leave
        if (leaveMinutes <= wakeMinutes) {
          int newWakeMinutes = leaveMinutes - 15;
          if (newWakeMinutes < 0) newWakeMinutes = 0;
          _wakeUpTime = TimeOfDay(
            hour: newWakeMinutes ~/ 60,
            minute: newWakeMinutes % 60,
          );
        }
        // If leave is after arrival, adjust arrival to 15 min after leave
        if (leaveMinutes >= arrivalMinutes) {
          int newArrivalMinutes = leaveMinutes + 15;
          _arrivalDeadline = TimeOfDay(
            hour: (newArrivalMinutes ~/ 60) % 24,
            minute: newArrivalMinutes % 60,
          );
        }
        break;

      case 'arrival':
        // If arrival is before leave time, adjust leave time to 15 min before arrival
        if (arrivalMinutes <= leaveMinutes) {
          int newLeaveMinutes = arrivalMinutes - 15;
          if (newLeaveMinutes < 0) newLeaveMinutes = 0;
          _leaveHomeTime = TimeOfDay(
            hour: newLeaveMinutes ~/ 60,
            minute: newLeaveMinutes % 60,
          );
          leaveMinutes = newLeaveMinutes;
          
          // If leave is now before wake-up, adjust wake-up too
          if (leaveMinutes <= wakeMinutes) {
            int newWakeMinutes = leaveMinutes - 15;
            if (newWakeMinutes < 0) newWakeMinutes = 0;
            _wakeUpTime = TimeOfDay(
              hour: newWakeMinutes ~/ 60,
              minute: newWakeMinutes % 60,
            );
          }
        }
        break;
    }
  }

  DateTime _getTomorrowDate() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  String _getTomorrowDateString() {
    final tomorrow = _getTomorrowDate();
    final weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[tomorrow.weekday]} ${tomorrow.month}/${tomorrow.day}';
  }

  bool _isSkippingTomorrow() {
    final tomorrow = _getTomorrowDate();
    return _skipDates.any((skipDate) {
      final normalizedSkipDate = DateTime(skipDate.year, skipDate.month, skipDate.day);
      return normalizedSkipDate == tomorrow;
    });
  }

  void _saveSettings() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final settings = AppSettings(
        wakeUpTime: _wakeUpTime,
        leaveHomeTime: _leaveHomeTime,
        arrivalDeadline: _arrivalDeadline,
        activeDaysOfWeek: _activeDaysOfWeek,
        skipDates: _skipDates,
      );
      
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.settingUpRoutine),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      
      await appState.saveSettings(settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.routineSaved),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate back to home after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSavingSettings(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.wb_sunny,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.setupDescription,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _TimeCard(
                icon: Icons.alarm,
                title: AppLocalizations.of(context)!.wakeUpTime,
                time: _wakeUpTime,
                onTap: () => _selectTime(context, 'wake'),
              ),
              const SizedBox(height: 16),
              _TimeCard(
                icon: Icons.directions_run,
                title: AppLocalizations.of(context)!.leaveHomeTime,
                time: _leaveHomeTime,
                onTap: () => _selectTime(context, 'leave'),
              ),
              const SizedBox(height: 16),
              _TimeCard(
                icon: Icons.school,
                title: AppLocalizations.of(context)!.latestArrivalTime,
                time: _arrivalDeadline,
                onTap: () => _selectTime(context, 'arrival'),
              ),
              const SizedBox(height: 32),
              // Active Days Section
              Text(
                'Active Days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              // Day toggles
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DayToggle(
                    label: 'Mon',
                    day: 1,
                    isActive: _activeDaysOfWeek.contains(1),
                    onToggle: (active) {
                      setState(() {
                        if (active) {
                          _activeDaysOfWeek.add(1);
                        } else {
                          _activeDaysOfWeek.remove(1);
                        }
                      });
                    },
                  ),
                  _DayToggle(
                    label: 'Tue',
                    day: 2,
                    isActive: _activeDaysOfWeek.contains(2),
                    onToggle: (active) {
                      setState(() {
                        if (active) {
                          _activeDaysOfWeek.add(2);
                        } else {
                          _activeDaysOfWeek.remove(2);
                        }
                      });
                    },
                  ),
                  _DayToggle(
                    label: 'Wed',
                    day: 3,
                    isActive: _activeDaysOfWeek.contains(3),
                    onToggle: (active) {
                      setState(() {
                        if (active) {
                          _activeDaysOfWeek.add(3);
                        } else {
                          _activeDaysOfWeek.remove(3);
                        }
                      });
                    },
                  ),
                  _DayToggle(
                    label: 'Thu',
                    day: 4,
                    isActive: _activeDaysOfWeek.contains(4),
                    onToggle: (active) {
                      setState(() {
                        if (active) {
                          _activeDaysOfWeek.add(4);
                        } else {
                          _activeDaysOfWeek.remove(4);
                        }
                      });
                    },
                  ),
                  _DayToggle(
                    label: 'Fri',
                    day: 5,
                    isActive: _activeDaysOfWeek.contains(5),
                    onToggle: (active) {
                      setState(() {
                        if (active) {
                          _activeDaysOfWeek.add(5);
                        } else {
                          _activeDaysOfWeek.remove(5);
                        }
                      });
                    },
                  ),
                  _DayToggle(
                    label: 'Sat',
                    day: 6,
                    isActive: _activeDaysOfWeek.contains(6),
                    onToggle: (active) {
                      setState(() {
                        if (active) {
                          _activeDaysOfWeek.add(6);
                        } else {
                          _activeDaysOfWeek.remove(6);
                        }
                      });
                    },
                  ),
                  _DayToggle(
                    label: 'Sun',
                    day: 7,
                    isActive: _activeDaysOfWeek.contains(7),
                    onToggle: (active) {
                      setState(() {
                        if (active) {
                          _activeDaysOfWeek.add(7);
                        } else {
                          _activeDaysOfWeek.remove(7);
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Quick presets
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _activeDaysOfWeek = {1, 2, 3, 4, 5}; // Weekdays
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue),
                      ),
                      child: const Text('Weekdays Only'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _activeDaysOfWeek = {1, 2, 3, 4, 5, 6, 7}; // Every day
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue),
                      ),
                      child: const Text('Every Day'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Skip Tomorrow toggle
              SwitchListTile(
                title: const Text('Skip Tomorrow'),
                subtitle: _isSkippingTomorrow()
                    ? Text(
                        'Alarms disabled for ${_getTomorrowDateString()}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      )
                    : const Text('Enable to skip alarms tomorrow'),
                value: _isSkippingTomorrow(),
                onChanged: (bool value) {
                  setState(() {
                    final tomorrow = _getTomorrowDate();
                    if (value) {
                      _skipDates.add(tomorrow);
                    } else {
                      _skipDates.remove(tomorrow);
                    }
                  });
                },
                activeColor: Colors.orange,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.startTheJourney,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeCard({
    required this.icon,
    required this.title,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                time.format(context),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  final String label;
  final int day;
  final bool isActive;
  final Function(bool) onToggle;

  const _DayToggle({
    required this.label,
    required this.day,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(!isActive),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
