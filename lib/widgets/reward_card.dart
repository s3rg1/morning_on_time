import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/reward.dart';
import '../l10n/app_localizations.dart';
import 'reward_management_dialog.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final reward = appState.currentReward;
    final latestCompletedReward = appState.latestCompletedReward;

    if (reward == null) {
      if (latestCompletedReward == null || latestCompletedReward.completionDate == null) {
        return const SizedBox.shrink();
      }

      final locale = Localizations.localeOf(context).toString();
      final completionDate = DateFormat('MMM d', locale).format(latestCompletedReward.completionDate!);

      return Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade100,
              Colors.green.shade200,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Achievement',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Completed on $completionDate',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '✅ ${latestCompletedReward.name}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showRewardDialog(context),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(AppLocalizations.of(context)!.manage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade800,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentStreak = appState.currentStreak;
    final progressPercent = reward.progressPercentage(currentStreak);
    final isAchieved = reward.isAchieved(currentStreak);

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isAchieved
              ? [
                  const Color(0xFFFFC837),
                  const Color(0xFFFFB300),
                ]
              : [
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isAchieved ? Colors.amber : Colors.blue).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            // Header with manage button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.rewardGoal,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showRewardDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(AppLocalizations.of(context)!.manage),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            Container(
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withValues(alpha: 0.3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressPercent / 100,
                  minHeight: 14,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(progressPercent, isAchieved),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Progress percentage text
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${progressPercent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dynamic progress message
            Text(
              _getProgressMessage(context, reward, currentStreak),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isAchieved ? Colors.white : Colors.black87,
              ),
            ),

            // Action buttons when achieved
            if (isAchieved) ...[
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () => _setNextReward(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFFB300),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Set Next Reward',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (!isAchieved && reward.completionDate != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Last: ${reward.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getProgressMessage(BuildContext context, Reward reward, int currentStreak) {
    final loc = AppLocalizations.of(context)!;
    
    if (reward.isAchieved(currentStreak)) {
      return loc.rewardCongratulations(reward.name);
    }

    final daysRemaining = reward.daysRemaining(currentStreak);

    if (reward.isAlmostThere(currentStreak)) {
      return loc.rewardAlmostThere(reward.name);
    }

    if (reward.isHalfway(currentStreak)) {
      return loc.rewardHalfway(daysRemaining, reward.name);
    }

    final daysWord = daysRemaining == 1 ? loc.day : loc.days;
    return loc.rewardDaysRemaining(daysRemaining, daysWord, reward.name);
  }

  Color _getProgressColor(double percent, bool isAchieved) {
    if (isAchieved) return Colors.white;
    if (percent >= 75) return const Color(0xFF58CC02); // Duolingo green
    if (percent >= 50) return const Color(0xFF1CB0F6); // Duolingo blue
    if (percent >= 25) return const Color(0xFFFF9600); // Duolingo orange
    return Colors.orange.shade300;
  }

  void _showRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RewardManagementDialog(),
    );
  }

  void _setNextReward(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Mark current as completed
    await appState.markRewardAsCompleted();
    
    // Show dialog to create new reward
    if (context.mounted) {
      _showRewardDialog(context);
    }
  }
}
