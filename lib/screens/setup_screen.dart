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
              const Spacer(),
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
