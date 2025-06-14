import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Models/alarm.dart';
import '../Models/day.dart';
import '../Models/hour.dart';
import '../Services/repository.dart';
import '../Models/routes.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';



///////////////////////////////////////////////////////////////////////////////////////////
// ENUM                                                                                  //
///////////////////////////////////////////////////////////////////////////////////////////

/*enum _SupportState {
  unknown,
  supported,
  unsupported,
}*/



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
  String _authorized = 'Sem permissão';
  late String nextAlarmText;
  late String nextAlarmDayText;
  late String nextAlarmHourText;
  final LocalAuthentication auth = LocalAuthentication();
  //_SupportState _supportState = _SupportState.unknown;
  //bool? _canCheckBiometrics;
  //bool _isAuthenticating = false;
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

    DateTime now = DateTime.now().toLocal();

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

  DateTime _getNextAlarmDateTime(DateTime now, int targetWeekdayIndex, TimeOfDay alarmTime) {
    int daysUntilNext = (targetWeekdayIndex - now.weekday + 7) % 7;
    DateTime candidateDate = now.add(Duration(days: daysUntilNext));

    DateTime alarmDateTime = DateTime(
      candidateDate.year,
      candidateDate.month,
      candidateDate.day,
      alarmTime.hour,
      alarmTime.minute,
    );

    if (daysUntilNext == 0 && alarmDateTime.isBefore(now)) {
      alarmDateTime = alarmDateTime.add(Duration(days: 1));
    }

    return alarmDateTime;
  }


  /////////////////////////////////////////////////////////////////////////////////////////

  Future<String> _formatNextAlarmText(Alarm alarm, DateTime now) async {
    List<Day> days = await repository.getAllDaysFromAlarm(alarm.id!);
    List<Hour> hours = await repository.getAllHoursFromAlarm(alarm.id!);

    if (alarm.active == 0 || days.isEmpty || hours.isEmpty) {
      return "Desativado";
    }

    List<DateTime> futureOccurrences = [];

    for (var day in days) {
      for (var hour in hours) {
        List<String> parts = hour.time.split(':');
        int hourPart = int.parse(parts[0]);
        int minutePart = int.parse(parts[1].split(' ')[0]);

        int weekday = _getDayIndex(day.week_day); // já usa seu método existente
        int today = now.weekday;
        int dayDiff = ((weekday - today + 7) % 7);

        DateTime candidateDate = now.add(Duration(days: dayDiff));
        DateTime candidate = DateTime(
          candidateDate.year,
          candidateDate.month,
          candidateDate.day,
          hourPart,
          minutePart,
        );

        if (candidate.isBefore(now)) {
          candidate = candidate.add(Duration(days: 7));
        }

        futureOccurrences.add(candidate);
      }
    }

    futureOccurrences.sort();
    DateTime next = futureOccurrences.first;

    nextAlarmDayText = Repository().getWeekDay(_getWeekdayName(next.weekday)).toLowerCase();
    nextAlarmHourText = '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}';

    return '${Repository().getWeekDay(_getWeekdayName(next.weekday))}, $nextAlarmHourText';
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  String _getWeekdayName(int weekdayNumber) {
    const map = {
      1: 'segunda',
      2: 'terca',
      3: 'quarta',
      4: 'quinta',
      5: 'sexta',
      6: 'sabado',
      7: 'domingo',
    };
    return map[weekdayNumber] ?? 'segunda';
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

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        //_isAuthenticating = true;
        _authorized = 'Autenticando';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Olá, por favor autentique.',
        options: const AuthenticationOptions(
          stickyAuth: true,    // Cenário que solicitou a autenticacao, app saiu de cena e voltou depois: Se true = continua pedindo a autenticação. 
          biometricOnly: true, // Remove a opção de usar o PIN.
        ),
      );
      setState(() {
        //_isAuthenticating = false;
        _authorized = 'Autenticando';
      });
    } on PlatformException catch (e) {
      setState(() {
        //_isAuthenticating = false;
        _authorized = 'Erro: ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Autorizado' : 'Não Autorizado';
    setState(() {
      _authorized = message;
    });
  }


  Future<void> _fazerBackup(BuildContext context) async {
  try {
    // 1. Pega os dados
    List<Map<String, dynamic>> alarms = await repository.getAllAlarmsJson();
    String jsonBackup = jsonEncode(alarms);

    // 2. Solicita o nome do arquivo ao usuário
    String? fileName = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempName = '';
        return AlertDialog(
          title: const Text('Nome do arquivo de backup'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "Digite o nome do arquivo"),
            onChanged: (value) {
              tempName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tempName.trim().isEmpty) {
                  // Não permite salvar vazio
                  return;
                }
                Navigator.of(context).pop(tempName.trim());
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (fileName == null || fileName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backup cancelado: nome inválido.")),
      );
      return;
    }

    // 3. Abre seletor de pasta
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    // 4. Verifica se o usuário escolheu alguma pasta
    if (selectedDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backup cancelado.")),
      );
      return;
    }

    // 5. Cria o arquivo com o nome informado
    final file = File('$selectedDirectory/$fileName.json');
    await file.writeAsString(jsonBackup);

    // 6. Mostra mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Backup salvo em: ${file.path}")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro ao salvar backup: $e")),
    );
  }
}



  Future<void> _restaurarBackup() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  String message;

  if (result != null) {
    File file = File(result.files.single.path!);
    String content = await file.readAsString();
    dynamic jsonData = jsonDecode(content);

    await repository.deleteAllData();

    if (jsonData is List) {
      for (var alarmMap in jsonData) {
        // Inserir alarm
        int alarmId = await repository.insertAlarm({
          'name': alarmMap['name'],
          'active': alarmMap['active'],
        });

        // Inserir hours associados
        if (alarmMap['hours'] != null && alarmMap['hours'] is List) {
          for (var hourMap in alarmMap['hours']) {
            await repository.insertHour({
              'time': hourMap['time'],
              'answered': hourMap['answered'],
              'alarm_id': alarmId,
            });
          }
        }

        // Inserir days associados
        if (alarmMap['days'] != null && alarmMap['days'] is List) {
          for (var dayMap in alarmMap['days']) {
            await repository.insertDay({
              'week_day': dayMap['week_day'],
              'today': dayMap['today'],
              'alarm_id': alarmId,
            });
          }
        }
      }
    }

    message = "Backup restaurado com sucesso!";
  } else {
    message = "Erro na seleção de arquivo";
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}


  /////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _initializeData().then((_) {
      _authenticateWithBiometrics();
    });

    _authenticateWithBiometrics();

    // Check if the device supports biometrics.
    /*auth.isDeviceSupported().then((bool isSupported) {
      setState(() {
        if (isSupported) {
          _supportState = _SupportState.supported;
        } else {
          _supportState = _SupportState.unsupported;
        }
      });
    });*/
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  
  @override
  Widget build(BuildContext context) {
    /////////////////////////////////////////////////////////////////////////////////////////
    // AUTHORIZED SCAFFOLD                                                                 //
    /////////////////////////////////////////////////////////////////////////////////////////

    if (_authorized == 'Autorizado'){
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
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => _fazerBackup(context),
                child: const Text('Fazer Backup Local'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  await _restaurarBackup();
                  await _initializeData();
                },
                child: const Text('Restaurar Backup Local'),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: listOfAlarms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.alarm_outlined, size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "Nenhum alarme adicionado!",
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: listOfAlarms.length + 1,
                        separatorBuilder: (context, index) {
                          if (index == 0) {
                            return const SizedBox.shrink();
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
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(height: 10),
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
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  listOfNumberOfHoursByAlarm.length == listOfAlarms.length &&
                                          listOfNumberOfDaysByAlarm.length == listOfAlarms.length
                                      ? '${listOfNumberOfHoursByAlarm[alarmIndex]} horário(s) e ${listOfNumberOfDaysByAlarm[alarmIndex]} dia(s) da semana'
                                      : 'Carregando...',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: Icon(
                                  listOfAlarms[alarmIndex].active == 1
                                      ? Icons.check_circle_outlined
                                      : Icons.cancel_outlined,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.detailAlarm,
                                    arguments: listOfAlarms[alarmIndex],
                                  ).then((value) async {
                                    await loadAlarms();
                                    await loadNumberOfHoursByAlarm();
                                    await loadNumberOfDaysByAlarm();
                                    await findNextAlarm();
                                    if (mounted) setState(() {});
                                  });
                                },
                                onLongPress: () async {
                                  listOfAlarms[alarmIndex].active =
                                      listOfAlarms[alarmIndex].active == 1 ? 0 : 1;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(listOfAlarms[alarmIndex].active == 1
                                          ? 'Alarme ativado.'
                                          : 'Alarme desativado.'),
                                      duration: const Duration(milliseconds: 1500),
                                    ),
                                  );

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
            ],
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



    /////////////////////////////////////////////////////////////////////////////////////////
    // UNAUTHORIZED SCAFFOLD                                                               //
    /////////////////////////////////////////////////////////////////////////////////////////

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
          child:
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gpp_bad_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    
                    Center(
                      child: Text(
                      "Acesso ainda não autorizado!",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    )),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {
                        _authenticateWithBiometrics();
                      },

                      child: Text(
                        'Autenticar novamente',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),


              
            )
        )
      )

    );
  }
}
