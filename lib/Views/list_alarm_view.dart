import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/day.dart';
import 'package:despertador/Models/hour.dart';
import 'package:despertador/Services/database.dart';
import 'package:flutter/material.dart';
import '../Models/routes.dart';


///////////////////////////////////////////////////////////////////////////////////////////


class AlarmView extends StatefulWidget{
  const AlarmView({super.key});

  @override
  State<AlarmView> createState() => _AlarmViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////


class _AlarmViewState extends State<AlarmView> {
  List<Alarm> listOfAlarms = []; 
  

  void loadAlarms() async {
    listOfAlarms = await DatabaseHelper.getAlarms();
    setState(() {});
  }
  

  int _getDiaIndex(String dia) {
    const dias = {
      'segunda': 1,
      'terca': 2,
      'quarta': 3,
      'quinta': 4,
      'sexta': 5,
      'sabado': 6,
      'domingo': 7
    };
    return dias[dia.toLowerCase()] ?? 1; // Default value: 'segunda'.
  }


  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }


  Future<Alarm?> getAlarmeMaisProximo(List<Alarm> listOfAlarms) async {
    // if (listOfAlarms.isEmpty) return null;

    final now = DateTime.now();
    int? menorDiferenca;
    Alarm? alarmeMaisProximo;

    for (var alarm in listOfAlarms) {
      // Pega os dias e horários do alarme
      List<Day> dias = await DatabaseHelper.getDays(alarm.id!); // Supondo que você tenha isso dentro do objeto
      List<Hour> horarios = await DatabaseHelper.getHours(alarm.id!);

      // Usa o método que você criou para pegar o dia mais próximo
      String proximoDiaStr = alarm.getProximoDia(dias);
      int proximoDiaIndex = _getDiaIndex(proximoDiaStr);

      // Calcula a diferença de dias a partir de hoje
      int diffDias = (proximoDiaIndex - now.weekday + 7) % 7;

      // Pega o horário mais próximo também
      String horaStr = alarm.getClosestHour(horarios);
      TimeOfDay hora = _parseTimeOfDay(horaStr);

      // Cria a data e hora combinadas do próximo disparo
      DateTime dataDisparo = DateTime(now.year, now.month, now.day, hora.hour, hora.minute)
          .add(Duration(days: diffDias));

      int diferencaEmSegundos = dataDisparo.difference(now).inSeconds;

      if (menorDiferenca == null || diferencaEmSegundos < menorDiferenca) {
        menorDiferenca = diferencaEmSegundos;
        alarmeMaisProximo = alarm;
      }
    }

    return alarmeMaisProximo;
  }

  
  @override
  Widget build(BuildContext context) {
    loadAlarms();

    return Scaffold(

      /////////////////////////////////////////////////////////////////////////////////////
      // APP BAR                                                                         //
      /////////////////////////////////////////////////////////////////////////////////////
      
      appBar: AppBar(
        title: Text('Alarmes'),
      ),


      /////////////////////////////////////////////////////////////////////////////////////
      // BODY                                                                            //
      /////////////////////////////////////////////////////////////////////////////////////
      
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: listOfAlarms.isEmpty
              ? // If the alarm list is empty /////////////////////////////////////////////
              
              [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.alarm_outlined, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "Nenhum alarme adicionado!",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              ]

              : // If the alarm list is not empty /////////////////////////////////////////

              [
                SizedBox(height: 10),
                

                Text(
                  'Próximo alarme em 10 horas e 33 minutos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                  )
                ),


                SizedBox(height: 20),
                

                Expanded(
                  child: ListView.separated(
                    itemCount: listOfAlarms.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          color: listOfAlarms[index].active == 1 ? const Color.fromARGB(255, 4, 102, 200) : const Color.fromARGB(255, 74, 103, 126),  
                          child: ListTile(

                            title: Text(
                              '${listOfAlarms[index].name} - id: ${listOfAlarms[index].id}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),

                            trailing: Icon(
                              listOfAlarms[index].active == 1 ? Icons.check_circle_outlined : Icons.cancel_outlined,
                              color: Colors.white,
                            ),

                            // Go to the alarm details screen.
                            onTap: () {
                              Navigator.pushNamed(context, Routes.detailAlarm, arguments: listOfAlarms[index]).then((value) {
                                if (value == true) {
                                  setState(() {
                                  });
                                }
                              });
                            },
                            
                            // Activates or deactivates the alarm.
                            onLongPress: () {
                              if (listOfAlarms[index].active == 1) {
                                listOfAlarms[index].active = 0;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Alarme desativado.'),
                                    duration: Duration(milliseconds: 1500),
                                  ),
                                );
                              } else {
                                listOfAlarms[index].active = 1;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Alarme ativado.'),
                                    duration: Duration(milliseconds: 1500),
                                  ),
                                );
                              }

                              DatabaseHelper.editAlarm(listOfAlarms[index]);

                              setState(() {});
                            }, 

                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  ),
                ),
              ]
          ),
        ),
      
      ),
      

      /////////////////////////////////////////////////////////////////////////////////////
      // FLOATING ACTION BUTTON                                                          //
      /////////////////////////////////////////////////////////////////////////////////////
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addAlarm, arguments: {'alarmObject': null, 'editMode': false})
            .then((value) {
              if (value == true) {
                setState(() {});
              }
            }
          );
        },
        child: Icon(Icons.add),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}