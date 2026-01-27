class DayRecord {
  final DateTime date;
  final bool wasOnTime;
  final DateTime? arrivalTime;

  DayRecord({
    required this.date,
    required this.wasOnTime,
    this.arrivalTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'wasOnTime': wasOnTime,
      'arrivalTime': arrivalTime?.toIso8601String(),
    };
  }

  factory DayRecord.fromJson(Map<String, dynamic> json) {
    return DayRecord(
      date: DateTime.parse(json['date'] as String),
      wasOnTime: json['wasOnTime'] as bool,
      arrivalTime: json['arrivalTime'] != null 
          ? DateTime.parse(json['arrivalTime'] as String)
          : null,
    );
  }
}
