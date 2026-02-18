class Reward {
  final String id;
  final String name;
  final int requiredStreakLength;
  final DateTime creationDate;
  final DateTime? completionDate;
  final bool isActive;

  Reward({
    required this.id,
    required this.name,
    required this.requiredStreakLength,
    required this.creationDate,
    this.completionDate,
    this.isActive = true,
  });

  // Calculate days remaining to reach the reward
  int daysRemaining(int currentStreak) {
    if (currentStreak >= requiredStreakLength) return 0;
    return requiredStreakLength - currentStreak;
  }

  // Calculate progress percentage
  double progressPercentage(int currentStreak) {
    if (currentStreak >= requiredStreakLength) return 100.0;
    return (currentStreak / requiredStreakLength) * 100;
  }

  // Check if reward is achieved
  bool isAchieved(int currentStreak) {
    return currentStreak >= requiredStreakLength;
  }

  // Check if reward is at halfway point
  bool isHalfway(int currentStreak) {
    return progressPercentage(currentStreak) >= 50 && !isAchieved(currentStreak);
  }

  // Check if reward is almost there (1 day remaining)
  bool isAlmostThere(int currentStreak) {
    return daysRemaining(currentStreak) == 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'requiredStreakLength': requiredStreakLength,
      'creationDate': creationDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      name: json['name'] as String,
      requiredStreakLength: json['requiredStreakLength'] as int,
      creationDate: DateTime.parse(json['creationDate'] as String),
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Reward copyWith({
    String? id,
    String? name,
    int? requiredStreakLength,
    DateTime? creationDate,
    DateTime? completionDate,
    bool? isActive,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      requiredStreakLength: requiredStreakLength ?? this.requiredStreakLength,
      creationDate: creationDate ?? this.creationDate,
      completionDate: completionDate ?? this.completionDate,
      isActive: isActive ?? this.isActive,
    );
  }

  // Create default reward for first launch
  // Pass localized name from calling code
  factory Reward.defaultReward({String? name}) {
    return Reward(
      id: 'default_reward',
      name: name ?? 'Movie night with popcorn 🍿', // Fallback if not provided
      requiredStreakLength: 5,
      creationDate: DateTime.now(),
      isActive: true,
    );
  }
}
