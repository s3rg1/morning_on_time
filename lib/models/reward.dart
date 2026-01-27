class Reward {
  final String id;
  final String name;
  final int requiredStreakLength;
  final bool isActive;

  Reward({
    required this.id,
    required this.name,
    required this.requiredStreakLength,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'requiredStreakLength': requiredStreakLength,
      'isActive': isActive,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      name: json['name'] as String,
      requiredStreakLength: json['requiredStreakLength'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Reward copyWith({
    String? id,
    String? name,
    int? requiredStreakLength,
    bool? isActive,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      requiredStreakLength: requiredStreakLength ?? this.requiredStreakLength,
      isActive: isActive ?? this.isActive,
    );
  }
}
