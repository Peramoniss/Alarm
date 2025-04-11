class Alarm {
  int? id;
  String name;
  int active;
  
  Alarm({
    this.id,
    required this.name,
    required this.active
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'active': active,
    };
  }

  /*factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'] as int,
      name: map['name'] as String,
      active: map['active'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Alarm.fromJson(String source) => Alarm.fromMap(json.decode(source) as Map<String, dynamic>);*/
}
