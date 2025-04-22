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

  /*factory Hour.fromMap(Map<String, dynamic> map) {
    return Hour(
      id: map['id'] as int,
      name: map['name'] as String,
      active: map['active'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Hour.fromJson(String source) => Hour.fromMap(json.decode(source) as Map<String, dynamic>);*/
}
