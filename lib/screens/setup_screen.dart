import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/app_settings.dart';
import 'scheduled_alarms_screen.dart';

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

  void _saveSettings() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final settings = AppSettings(
        wakeUpTime: _wakeUpTime,
        leaveHomeTime: _leaveHomeTime,
        arrivalDeadline: _arrivalDeadline,
        activeDaysOfWeek: _activeDaysOfWeek,
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
        
        // Check volume and warn if too low
        await _checkVolumeAndWarn();
        
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

  Future<void> _checkVolumeAndWarn() async {
    try {
      final volume = await VolumeController().getVolume();
      
      // Warn if volume is below 30%
      if (volume < 0.3 && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.volume_down, color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text('Low Volume'),
              ],
            ),
            content: Text(
              'Your media volume is at ${(volume * 100).round()}%.\n\n'
              'Consider increasing it to hear morning voice messages.',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK, I\'ll adjust it'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Silently fail if volume check is not available
      print('Volume check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Icon(Icons.close, color: Colors.grey.shade700, size: 20),
          ),
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
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF9600),
                        Color(0xFFFFC837),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.wb_sunny,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.setupDescription,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  AppLocalizations.of(context)!.activeDays,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Day toggles
              Wrap(
                spacing: 6,
                runSpacing: 8,
                children: [
                  _DayToggle(
                    label: AppLocalizations.of(context)!.monday,
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
                    label: AppLocalizations.of(context)!.tuesday,
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
                    label: AppLocalizations.of(context)!.wednesday,
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
                    label: AppLocalizations.of(context)!.thursday,
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
                    label: AppLocalizations.of(context)!.friday,
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
                    label: AppLocalizations.of(context)!.saturday,
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
                    label: AppLocalizations.of(context)!.sunday,
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
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _activeDaysOfWeek = {1, 2, 3, 4, 5}; // Weekdays
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1CB0F6),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: const Color(0xFF1CB0F6),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.weekdaysOnly,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _activeDaysOfWeek = {1, 2, 3, 4, 5, 6, 7}; // Every day
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1CB0F6),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: const Color(0xFF1CB0F6),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.everyDay,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF58CC02),
                      Color(0xFF46A302),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.startTheJourney,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Testing link (remove before production)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ScheduledAlarmsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.alarm, size: 18),
                label: Text(
                  AppLocalizations.of(context)!.viewScheduledAlarms,
                  style: const TextStyle(fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1CB0F6).withOpacity(0.15),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: const Color(0xFF1CB0F6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1CB0F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  time.format(context),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 28),
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
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF58CC02),
                    Color(0xFF46A302),
                  ],
                )
              : null,
          color: isActive ? null : Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.green : Colors.grey[400]!,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
