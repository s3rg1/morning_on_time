import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class RewardManagementDialog extends StatefulWidget {
  const RewardManagementDialog({super.key});

  @override
  State<RewardManagementDialog> createState() => _RewardManagementDialogState();
}

class _RewardManagementDialogState extends State<RewardManagementDialog> {
  late TextEditingController _nameController;
  late int _selectedDays;

  // Quick reward templates
  final List<Map<String, dynamic>> _templates = [
    {'emoji': '🍿', 'name': 'Movie night'},
    {'emoji': '🍕', 'name': 'Pizza dinner'},
    {'emoji': '🎮', 'name': 'Extra game time'},
    {'emoji': '🏞️', 'name': 'Park visit'},
    {'emoji': '🎨', 'name': 'Art project'},
    {'emoji': '🍦', 'name': 'Ice cream outing'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize with current reward or defaults
    final appState = Provider.of<AppState>(context, listen: false);
    final currentReward = appState.currentReward;
    
    _nameController = TextEditingController(
      text: currentReward?.name ?? 'Movie night with popcorn 🍿',
    );
    _selectedDays = currentReward?.requiredStreakLength ?? 5;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Reward'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reward name input
            const Text(
              'Reward Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Pizza night 🍕',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            // Quick templates
            const Text(
              'Quick Suggestions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _templates.map((template) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _nameController.text = '${template['name']} ${template['emoji']}';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          template['emoji'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          template['name'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Streak days selector
            const Text(
              'Days Required',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrease button
                  IconButton(
                    onPressed: _selectedDays > 3
                        ? () => setState(() => _selectedDays--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.blue.shade700,
                    iconSize: 32,
                  ),
                  const SizedBox(width: 16),
                  
                  // Current value
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '$_selectedDays day${_selectedDays != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Increase button
                  IconButton(
                    onPressed: _selectedDays < 30
                        ? () => setState(() => _selectedDays++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.blue.shade700,
                    iconSize: 32,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum: 3 days  •  Maximum: 30 days',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveReward,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveReward() async {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reward name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    
    try {
      await appState.updateCurrentReward(
        name: name,
        requiredStreak: _selectedDays,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reward updated: $name'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving reward: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
