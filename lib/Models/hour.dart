class Hour {
  int? id;
  String time;
  int answered;
  int alarmId;

  
  Hour({
    this.id,
    required this.time,
    this.answered = 0,
    required this.alarmId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'time': time,
      'answered': answered,
      'alarm_id': alarmId
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
