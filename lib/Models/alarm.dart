import 'package:despertador/Models/day.dart';
import 'package:despertador/Models/hour.dart';
import 'package:flutter/material.dart';

class Alarm {
  int? id;
  String name;
  int active;
  
  Alarm({
    this.id,
    required this.name,
    required this.active
  });

  String getProximoDia(List<Day> days) {
    final diasSemana = ['segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo'];
    final hojeIndex = DateTime.now().weekday % 7;

    List<int> diasSelecionadosIndex = days.map((d) => diasSemana.indexOf(d.week_day)).toList();

    int menorDiferenca = 7;
    String? proximoDia;

    for (int dia in diasSelecionadosIndex) {
      int diferenca = (dia - hojeIndex + 7) % 7;
      if (diferenca == 0) diferenca = 7;

      if (diferenca < menorDiferenca) {
        menorDiferenca = diferenca;
        proximoDia = diasSemana[dia];
      }
    }

    return proximoDia ?? '';
  }

  String getClosestHour(List<Hour> hours) {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    Hour? proximo;
    int menorDiferenca = 1440;

    for (final hour in hours) {
      final partes = hour.time.split(':');
      final hora = int.parse(partes[0]);
      final minuto = int.parse(partes[1].split(" ")[0]);
      final totalMinutos = hora * 60 + minuto;

      int diferenca = totalMinutos - nowMinutes;
      if (diferenca < 0) {
        diferenca += 1440;
      }

      if (diferenca < menorDiferenca) {
        menorDiferenca = diferenca;
        proximo = hour;
      }
    }

    return proximo?.time ?? '';
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'] as int?,
      name: map['name'] as String,
      active: map['active'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'active': active,
    };
  }

  /*String toJson() => json.encode(toMap());

  factory Alarm.fromJson(String source) => Alarm.fromMap(json.decode(source) as Map<String, dynamic>);*/
}
