import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/reward.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRewardDialog(context),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final rewards = appState.rewards;
          final currentStreak = appState.currentStreak;

          if (rewards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_border, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No rewards yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add a reward',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddRewardDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Reward'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              final isEarned = currentStreak >= reward.requiredStreakLength;
              final daysRemaining = reward.requiredStreakLength - currentStreak;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isEarned ? Colors.green : Colors.grey.shade300,
                    child: Icon(
                      isEarned ? Icons.star : Icons.star_border,
                      color: isEarned ? Colors.white : Colors.grey,
                    ),
                  ),
                  title: Text(
                    reward.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isEarned ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    isEarned
                        ? '🎉 Earned!'
                        : daysRemaining > 0
                            ? '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} to go'
                            : 'Almost there!',
                    style: TextStyle(
                      color: isEarned ? Colors.green : Colors.grey,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${reward.requiredStreakLength} days',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            _confirmDelete(context, appState, reward);
                          }
                        },
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

  void _showAddRewardDialog(BuildContext context) {
    final nameController = TextEditingController();
    final streakController = TextEditingController(text: '7');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Reward'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Reward Name',
                hintText: 'e.g., Movie night with popcorn',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: streakController,
              decoration: const InputDecoration(
                labelText: 'Required Streak (days)',
                hintText: 'e.g., 7',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final streakText = streakController.text.trim();
              
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reward name')),
                );
                return;
              }

              final streak = int.tryParse(streakText);
              if (streak == null || streak <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number')),
                );
                return;
              }

              final reward = Reward(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                requiredStreakLength: streak,
              );

              Provider.of<AppState>(context, listen: false).addReward(reward);
              Navigator.of(ctx).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reward "$name" added!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState appState, Reward reward) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reward?'),
        content: Text('Are you sure you want to delete "${reward.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.deleteReward(reward.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reward deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
