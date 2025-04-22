import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/day.dart';
import 'package:despertador/Models/hour.dart';
import 'package:despertador/Services/repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/routes.dart';


///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class AlarmView extends StatefulWidget{
  const AlarmView({super.key});

  @override
  State<AlarmView> createState() => _AlarmViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class _AlarmViewState extends State<AlarmView> {
  Repository repository = Repository();
  List<Alarm> listOfAlarms = [];
  List<int> listOfNumberOfHoursByAlarm = [];
  List<int> listOfNumberOfDaysByAlarm = [];
  late String nextAlarmText;
  late String nextAlarmDayText;
  late String nextAlarmHourText;
  bool _allAlarmsDisabled = true;

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> loadAlarms() async {
    listOfAlarms = await repository.getAllAlarms();
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> loadNumberOfHoursByAlarm() async {
    listOfNumberOfHoursByAlarm.clear();

    for (var alarm in listOfAlarms) {
      List<Hour> horas = await repository.getAllHoursFromAlarm(alarm.id!);
      listOfNumberOfHoursByAlarm.add(horas.length); 
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<void> loadNumberOfDaysByAlarm() async {
    listOfNumberOfDaysByAlarm.clear();

    for (var alarm in listOfAlarms) {
      List<Day> days = await repository.getAllDaysFromAlarm(alarm.id!);
      listOfNumberOfDaysByAlarm.add(days.length); 
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> findNextAlarm() async {
    await loadAlarms();
    await loadNumberOfDaysByAlarm();
    await loadNumberOfHoursByAlarm();

    DateTime now = DateTime.now();

    Alarm? nextAlarm;
    int? smallestDifferenceInSeconds;

    for (var alarm in listOfAlarms) {
      if (alarm.active == 1) {
        List<Day> days = await repository.getAllDaysFromAlarm(alarm.id!);
        List<Hour> hours = await repository.getAllHoursFromAlarm(alarm.id!);

        for (var day in days) {
          String weekDay = day.week_day;
          int dayIndex = _getDayIndex(weekDay);

          for (var hour in hours) {
            TimeOfDay alarmTime = _parseTimeOfDay(hour.time);

            DateTime alarmDateTime = _getNextAlarmDateTime(now, dayIndex, alarmTime);

            int differenceInSeconds = alarmDateTime.isAfter(now)
              ? alarmDateTime.difference(now).inSeconds
              : alarmDateTime.add(Duration(days: 7)).difference(now).inSeconds;

            if (smallestDifferenceInSeconds == null || differenceInSeconds < smallestDifferenceInSeconds) {
              smallestDifferenceInSeconds = differenceInSeconds;
              nextAlarm = alarm;
            }
          }
        }
      }
    }

    if (nextAlarm != null) {
      nextAlarmText = await _formatNextAlarmText(nextAlarm, now);
      setState(() {
        _allAlarmsDisabled = false;
      });
    } else {
      nextAlarmText = 'Todos os alarmes estão desativados.';
      setState(() {
        _allAlarmsDisabled = true;
      });
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  int _getDayIndex(String weekDay) {
    const daysOfWeek = {
      'segunda': 1,
      'terca': 2,
      'quarta': 3,
      'quinta': 4,
      'sexta': 5,
      'sabado': 6,
      'domingo': 7
    };

    return daysOfWeek[weekDay.toLowerCase()] ?? 1; // Default para segunda-feira
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1].split(' ')[0]));
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  DateTime _getNextAlarmDateTime(DateTime now, int dayIndex, TimeOfDay alarmTime) {
    DateTime nextAlarmDateTime = DateTime(now.year, now.month, now.day, alarmTime.hour, alarmTime.minute);
  
    if (nextAlarmDateTime.weekday < dayIndex) {
      nextAlarmDateTime = nextAlarmDateTime.add(Duration(days: dayIndex - nextAlarmDateTime.weekday));
    } else if (nextAlarmDateTime.weekday > dayIndex) {
      nextAlarmDateTime = nextAlarmDateTime.add(Duration(days: 7 - nextAlarmDateTime.weekday + dayIndex));
    }

    return nextAlarmDateTime;
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<String> _formatNextAlarmText(Alarm alarm, DateTime now) async {
    List<Day> days = await repository.getAllDaysFromAlarm(alarm.id!);
    List<Hour> hours = await repository.getAllHoursFromAlarm(alarm.id!);
    Day nextDay = days.firstWhere((d) => d.week_day == alarm.getProximoDia(days));
    Hour nextHour = hours.firstWhere((h) => h.time == alarm.getClosestHour(hours));
    DateFormat timeFormat = DateFormat('hh:mm');
    DateTime parsedTime = timeFormat.parse(nextHour.time);
    DateTime nextAlarmTime = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
    String formattedTime = DateFormat('HH:mm').format(nextAlarmTime);
    nextAlarmDayText = Repository().getWeekDay(nextDay.week_day).toLowerCase();
    nextAlarmHourText = formattedTime;
    return '${Repository().getWeekDay(nextDay.week_day)}, $formattedTime';
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  String _getDayPrefix(String day) {
    if (day == 'Sábado' || day == 'Domingo') {
      return 'no';
    } else {
      return 'na';
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  String _getHourPrefix(String hourText) {
    final hour = int.tryParse(hourText.split(':')[0]) ?? 0;

    if (hour == 0 || hour == 1) {
      return 'à';
    } else {
      return 'às';
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<void> _initializeData() async {
    await loadAlarms();
    await loadNumberOfHoursByAlarm();
    await loadNumberOfDaysByAlarm();
    await findNextAlarm();

    setState(() {});
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  void _showHelpInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),

          title: const Text('Ajuda'),
          
          content: const Text(
            'Para adicionar um novo alarme, toque no botão flutuante no canto inferior direito da tela. '
            'Para ativar ou desativar um alarme existente, pressione e segure por alguns segundos. '
            'Se preferir editar os detalhes de um alarme, toque sobre ele.',
            style: TextStyle(fontSize: 14)
          ),

          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /////////////////////////////////////////////////////////////////////////////////////
      // APP BAR                                                                         //
      /////////////////////////////////////////////////////////////////////////////////////
      
      appBar: AppBar(
        title: Text('Alarmes'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'helpButton') {
                _showHelpInfo(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'helpButton',
                child: Text('Ajuda'),
              ),
            ],
          ),
        ],
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
                Expanded(
                  child: ListView.separated(
                    itemCount: listOfAlarms.length + 1, // +1 for the text.
                    
                    separatorBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox.shrink();
                      }
                      return const Divider();
                    },

                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                          child: Column(
                            children: [
                              Text(
                                _allAlarmsDisabled
                                    ? nextAlarmText
                                    : 'Próximo alarme ${_getDayPrefix(nextAlarmDayText)} \n'
                                      '$nextAlarmDayText ${_getHourPrefix(nextAlarmHourText)} $nextAlarmHourText',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 24),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        );
                      }

                      final alarmIndex = index - 1;

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          color: listOfAlarms[alarmIndex].active == 1
                              ? const Color.fromARGB(255, 0, 75, 150)
                              : const Color.fromARGB(255, 67, 118, 156),
                          child: ListTile(
                            title: Text(
                              listOfAlarms[alarmIndex].name,
                              style: TextStyle(color: Colors.white),
                            ),

                            subtitle: Text(
                              listOfNumberOfHoursByAlarm.length == listOfAlarms.length &&
                                      listOfNumberOfDaysByAlarm.length == listOfAlarms.length
                                  ? '${listOfNumberOfHoursByAlarm[alarmIndex]} horário(s) e ${listOfNumberOfDaysByAlarm[alarmIndex]} dia(s) da semana'
                                  : 'Carregando...',
                              style: TextStyle(color: Colors.white),
                            ),

                            trailing: Icon(
                              listOfAlarms[alarmIndex].active == 1
                                  ? Icons.check_circle_outlined
                                  : Icons.cancel_outlined,
                              color: Colors.white,
                            ),

                            onTap: () {
                              Navigator.pushNamed(context, Routes.detailAlarm,
                                      arguments: listOfAlarms[alarmIndex])
                                  .then((value) async {
                                await loadAlarms();
                                await loadNumberOfHoursByAlarm();
                                await loadNumberOfDaysByAlarm();
                                await findNextAlarm();
                                if (mounted) setState(() {});
                              });
                            },

                            onLongPress: () async {
                              if (listOfAlarms[alarmIndex].active == 1) {
                                listOfAlarms[alarmIndex].active = 0;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Alarme desativado.'),
                                    duration: Duration(milliseconds: 1500),
                                  ),
                                );
                              } else {
                                listOfAlarms[alarmIndex].active = 1;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Alarme ativado.'),
                                    duration: Duration(milliseconds: 1500),
                                  ),
                                );
                              }

                              repository.updateAlarm(listOfAlarms[alarmIndex]);
                              await findNextAlarm();
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      );
                    },
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
            .then((value) async {
              if (value == true) {
                await loadAlarms();
                await loadNumberOfHoursByAlarm();
                await loadNumberOfDaysByAlarm();
                await findNextAlarm();
                if (mounted) setState(() {});
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
