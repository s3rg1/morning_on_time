import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isRequestingPermissions = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequestingPermissions = true;
    });

    try {
      // 1. Request notification permission
      final notificationPlugin = FlutterLocalNotificationsPlugin();
      final androidImplementation = notificationPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      bool? notificationGranted = false;
      if (androidImplementation != null) {
        notificationGranted = await androidImplementation.requestNotificationsPermission();
      }

      // 2. Request battery optimization exemption
      final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
      bool batteryGranted = batteryStatus.isGranted;
      
      if (!batteryGranted) {
        // Request the permission - this will open settings
        final result = await Permission.ignoreBatteryOptimizations.request();
        batteryGranted = result.isGranted;
      }

      setState(() {
        _isRequestingPermissions = false;
      });

      // 3. Check if both permissions are granted
      if (notificationGranted == true && batteryGranted) {
        // Both permissions granted - mark onboarding complete and navigate to setup
        if (mounted) {
          final appState = Provider.of<AppState>(context, listen: false);
          await appState.completeOnboarding();
          
          Navigator.of(context).pushReplacementNamed('/setup');
        }
      } else {
        // Show retry dialog
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      }
    } catch (e) {
      setState(() {
        _isRequestingPermissions = false;
      });
      
      if (mounted) {
        _showPermissionErrorDialog(e.toString());
      }
    }
  }

  void _showPermissionDeniedDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.onboardingPermissionsRequired),
        content: Text(l10n.onboardingPermissionsRequiredMessage),
        actions: [
          TextButton(
            onPressed: () {
              SystemNavigator.pop(); // Exit app
            },
            child: Text(l10n.onboardingExitApp),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissions();
            },
            child: Text(l10n.onboardingTryAgain),
          ),
        ],
      ),
    );
  }

  void _showPermissionErrorDialog(String error) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.onboardingError),
        content: Text(l10n.onboardingErrorMessage(error)),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            if (_currentPage < 4)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildProblemStatementPage(),
                  _buildSolutionPage(),
                  _buildHowItWorksPage(),
                  _buildPermissionsPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(l10n.onboardingBack),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  // Next/Grant button
                  if (_currentPage < 3)
                    FilledButton(
                      onPressed: _nextPage,
                      child: Text(l10n.onboardingNext),
                    )
                  else
                    FilledButton(
                      onPressed: _isRequestingPermissions ? null : _requestPermissions,
                      child: _isRequestingPermissions
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.onboardingGrantPermissions),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemStatementPage() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time_filled,
              size: 100,
              color: Colors.orange.shade400,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Headline
          Text(
            l10n.onboardingProblemHeadline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Body text
          _buildProblemPoint(
            Icons.event_busy,
            l10n.onboardingProblemPoint1,
          ),
          const SizedBox(height: 16),
          _buildProblemPoint(
            Icons.warning_amber,
            l10n.onboardingProblemPoint2,
          ),
          const SizedBox(height: 16),
          _buildProblemPoint(
            Icons.child_care,
            l10n.onboardingProblemPoint3,
          ),
        ],
      ),
    );
  }

  Widget _buildProblemPoint(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.orange.shade700,
          size: 28,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSolutionPage() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              size: 100,
              color: Colors.green.shade600,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Headline
          Text(
            l10n.onboardingSolutionHeadline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Body text
          _buildSolutionPoint(
            Icons.favorite,
            l10n.onboardingSolutionPoint1,
          ),
          const SizedBox(height: 16),
          _buildSolutionPoint(
            Icons.volume_up,
            l10n.onboardingSolutionPoint2,
          ),
          const SizedBox(height: 16),
          _buildSolutionPoint(
            Icons.trending_up,
            l10n.onboardingSolutionPoint3,
          ),
          const SizedBox(height: 16),
          _buildSolutionPoint(
            Icons.auto_awesome,
            l10n.onboardingSolutionPoint4,
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionPoint(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.green.shade700,
          size: 28,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksPage() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Headline
          Text(
            l10n.onboardingHowItWorksHeadline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Timeline
          _buildTimelineStep(
            '🌅',
            l10n.onboardingHowItWorksPoint1,
            Colors.blue,
          ),
          _buildTimelineDivider(),
          _buildTimelineStep(
            '⏰',
            l10n.onboardingHowItWorksPoint2,
            Colors.orange,
          ),
          _buildTimelineDivider(),
          _buildTimelineStep(
            '🚪',
            l10n.onboardingHowItWorksPoint3,
            Colors.purple,
          ),
          _buildTimelineDivider(),
          _buildTimelineStep(
            '🎯',
            l10n.onboardingHowItWorksPoint4,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String emoji, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 8, bottom: 8),
      child: Container(
        width: 2,
        height: 24,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildPermissionsPage() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  size: 40,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.battery_charging_full,
                  size: 40,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Headline
          Text(
            l10n.onboardingPermissionsHeadline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            l10n.onboardingPermissionsIntro,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Permission 1: Notifications
          _buildPermissionCard(
            icon: Icons.notifications,
            iconColor: Colors.blue,
            title: l10n.onboardingPermissionNotifications,
            description: l10n.onboardingPermissionNotificationsDesc,
          ),
          
          const SizedBox(height: 16),
          
          // Permission 2: Battery
          _buildPermissionCard(
            icon: Icons.battery_full,
            iconColor: Colors.green,
            title: l10n.onboardingPermissionBattery,
            description: l10n.onboardingPermissionBatteryDesc,
          ),
          
          const SizedBox(height: 24),
          
          // Explanation box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade900,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.onboardingPermissionExplanation,
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
