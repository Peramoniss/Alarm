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
  List<int> listOfNumberOfHoursByAlarm = [];
  List<int> listOfNumberOfDaysByAlarm = [];

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> loadAlarms() async {
    listOfAlarms = await DatabaseHelper.getAlarms();
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> loadNumberOfHoursByAlarm() async {
    listOfNumberOfHoursByAlarm.clear();

    for (var alarm in listOfAlarms) {
      List<Hour> horas = await DatabaseHelper.getHours(alarm.id!);
      listOfNumberOfHoursByAlarm.add(horas.length); 
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<void> loadNumberOfDaysByAlarm() async {
    listOfNumberOfDaysByAlarm.clear();

    for (var alarm in listOfAlarms) {
      List<Day> days = await DatabaseHelper.getDays(alarm.id!);
      listOfNumberOfDaysByAlarm.add(days.length); 
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<void> _initializeData() async {
    await loadAlarms();
    await loadNumberOfHoursByAlarm();
    await loadNumberOfDaysByAlarm();

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
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          color: listOfAlarms[index].active == 1 ? const Color.fromARGB(255, 43, 131, 219) : const Color.fromARGB(255, 97, 128, 151),  
                          child: ListTile(

                            title: Text(
                              listOfAlarms[index].name,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),

                            subtitle: Text(
                              listOfNumberOfHoursByAlarm.length == listOfAlarms.length && listOfNumberOfDaysByAlarm.length == listOfAlarms.length
                                  ? '${listOfNumberOfHoursByAlarm[index]} horário(s) e ${listOfNumberOfDaysByAlarm[index]} dia(s) da semana'
                                  : 'Carregando...',
                              style: TextStyle(color: Colors.white),
                            ),

                            trailing: Icon(
                              listOfAlarms[index].active == 1 ? Icons.check_circle_outlined : Icons.cancel_outlined,
                              color: Colors.white,
                            ),

                            // Go to the alarm details screen.
                            onTap: () {
                              Navigator.pushNamed(context, Routes.detailAlarm, arguments: listOfAlarms[index])
                              .then((value) async {
                                await loadAlarms();
                                await loadNumberOfHoursByAlarm();
                                await loadNumberOfDaysByAlarm();
                                if (mounted) setState(() {});
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
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
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
