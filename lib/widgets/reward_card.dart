import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/reward.dart';
import 'reward_management_dialog.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final reward = appState.currentReward;

    // Don't show card if no reward exists
    if (reward == null) return const SizedBox.shrink();

    final currentStreak = appState.currentStreak;
    final daysRemaining = reward.daysRemaining(currentStreak);
    final progressPercent = reward.progressPercentage(currentStreak);
    final isAchieved = reward.isAchieved(currentStreak);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isAchieved ? Colors.amber.shade50 : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            // Header with manage button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🎁 Reward Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showRewardDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Manage'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercent / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progressPercent, isAchieved),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Progress percentage text
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${progressPercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dynamic progress message
            Text(
              _getProgressMessage(reward, currentStreak),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isAchieved ? Colors.amber.shade900 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            // Action buttons when achieved
            if (isAchieved) ...[
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _setNextReward(context),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Set Next Reward'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],

            // Last completed reward badge (if exists)
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

  String _getProgressMessage(Reward reward, int currentStreak) {
    if (reward.isAchieved(currentStreak)) {
      return '🎉 Congratulations! You earned ${reward.name}';
    }

    final daysRemaining = reward.daysRemaining(currentStreak);

    if (reward.isAlmostThere(currentStreak)) {
      return 'Almost there! 🚀 1 day to earn ${reward.name}';
    }

    if (reward.isHalfway(currentStreak)) {
      return 'Halfway there! 🔥 $daysRemaining days to earn ${reward.name}';
    }

    return 'Only $daysRemaining day${daysRemaining != 1 ? 's' : ''} to earn ${reward.name}';
  }

  Color _getProgressColor(double percent, bool isAchieved) {
    if (isAchieved) return Colors.amber.shade700;
    if (percent >= 75) return Colors.green;
    if (percent >= 50) return Colors.blue;
    if (percent >= 25) return Colors.orange;
    return Colors.grey.shade400;
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
