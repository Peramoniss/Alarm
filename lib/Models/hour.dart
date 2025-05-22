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

  factory Hour.fromMap(Map<String, dynamic> map) {
    return Hour(
      id: map['id'],
      time: map['time'],
      answered: map['answered'],
      alarmId: map['alarm_id'],
    );
  }

  Hour copy() {
    return Hour(
      id: id,
      time: time,
      answered: answered,
      alarmId: alarmId,
    );
  }
}
