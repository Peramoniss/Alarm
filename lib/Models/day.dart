class Day {
  int? id;
  String week_day;
  int? today = 0;
  int alarmId;
  
  Day({
    this.id,
    required this.week_day,
    required this.alarmId,
    this.today
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'today': today,
      'week_day': week_day
    };
  }

  factory Day.fromMap(Map<String, dynamic> map) {
    return Day(
      id: map['id'],
      week_day: map['week_day'],
      today: map['today'],
      alarmId: map['alarm_id'],
    );
  }

  Day copy() {
    return Day(
      id: id,
      week_day: week_day,
      today: today,
      alarmId: alarmId,
    );
  }
}
