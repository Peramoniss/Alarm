import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/hour.dart';
import 'package:despertador/Services/database.dart';
import 'package:flutter/material.dart';
import '../Models/routes.dart';


///////////////////////////////////////////////////////////////////////////////////////////


class DetailAlarmView extends StatefulWidget{
  const DetailAlarmView({super.key});

  @override
  State<DetailAlarmView> createState() => _DetailAlarmViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////


class _DetailAlarmViewState extends State<DetailAlarmView> {
  List<Hour> hours = []; 
  
  void loadHours(int id) async {
    hours = await DatabaseHelper.getHours(id);
    if (mounted) setState(() {});
  }

  void _confirmAlarmDeletion(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir este alarme?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),

          TextButton(
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await DatabaseHelper.deleteAlarm(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarme excluído!')),
      );

      Navigator.pop(context);
    }
  }


  void _confirmarExclusaoHorario(BuildContext context, int alarmId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir este horário?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );


    if (confirm == true) {
      await DatabaseHelper.deleteHour(alarmId);
      //loadHours(alarmId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Horário excluído!')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    var parameters = null;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (ModalRoute.of(context)!.settings.arguments is Alarm) {
        parameters = ModalRoute.of(context)!.settings.arguments as Alarm;
      }
    }

    loadHours(parameters.id);

    return Scaffold(

      /////////////////////////////////////////////////////////////////////////////////////
      // APP BAR                                                                         //
      /////////////////////////////////////////////////////////////////////////////////////
      
      appBar: AppBar(
        title: Text('Detalhes do alarme'),
        actions: [
          /*PopupMenuButton<String>(
            onSelected: (value) {
              // Trate a seleção aqui
              if (value == 'editar') {
                // Navegar ou fazer algo
              } else if (value == 'deletar') {
                // Outro comportamento
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'editar',
                child: Text('Editar'),
              ),
              PopupMenuItem(
                value: 'deletar',
                child: Text('Excluir'),
              ),
            ],
          ),*/
        ],
      ),


      /////////////////////////////////////////////////////////////////////////////////////
      // BODY                                                                            //
      /////////////////////////////////////////////////////////////////////////////////////
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Center(
                  child: Text(
                    "Nome do alarme",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),

                SizedBox(height: 4),

                Center(
                  child: Text(
                    parameters.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  )
                ),
                
                SizedBox(height: 20),

                ///////////////////////////////////////////////////////////////////////////

                Center(
                  child: Text(
                    "Próximo horário do alarme",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  )
                ),

                SizedBox(height: 4),

                Center(
                  child: Text(
                    'Segunda-feira, 10:38',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  )
                ),

                SizedBox(height: 20),

                ///////////////////////////////////////////////////////////////////////////
                
                Center(
                  child: Text(
                    "Lista de horários",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  )
                ),

                SizedBox(height: 4),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 206, 206, 206),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hours.isEmpty

                      ? 
                      
                      Center(child: 
                        Text(
                          'Nenhum horário adicionado ainda.',
                          style: TextStyle(fontSize: 16),
                        )
                      )

                      : 
                      
                      ListView.builder(
                        itemCount: hours.length,
                        itemBuilder: (context, index) {
                          final hour = hours[index];
                          return ListTile(
                            title: Text(hour.time),
                            subtitle: Text(hour.answered == 1
                                ? 'Respondido'
                                : 'Não respondido'),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.addHour,
                                arguments: {
                                  'alarm': parameters,
                                  'hour': hour,
                                  'editMode': true,
                                },
                              ).then((value) {
                                if (value == true) {
                                  loadHours(parameters.id);
                                }
                              });
                            },
                            onLongPress: () {
                              _confirmarExclusaoHorario(context, hour.id!);
                            },
                          );
                        },
                      ),
                    ],
                  )
                ),

                SizedBox(height: 20),

                ///////////////////////////////////////////////////////////////////////////

                Center(
                  child: Text(
                    "Lista de dias",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  )
                ),

                SizedBox(height: 4),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 206, 206, 206),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hours.isEmpty

                      ? 
                      
                      Center(child: 
                        Text(
                          'Nenhum dia adicionado ainda.',
                          style: TextStyle(fontSize: 16),
                        )
                      )

                      : 
                      
                      ListView.builder(
                        itemCount: hours.length,
                        itemBuilder: (context, index) {
                          final hour = hours[index];
                          return ListTile(
                            title: Text(hour.time),
                            subtitle: Text(hour.answered == 1
                                ? 'Respondido'
                                : 'Não respondido'),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.addHour,
                                arguments: {
                                  'alarm': parameters,
                                  'hour': hour,
                                  'editMode': true,
                                },
                              ).then((value) {
                                if (value == true) {
                                  loadHours(parameters.id);
                                }
                              });
                            },
                            onLongPress: () {
                              _confirmarExclusaoHorario(context, hour.id!);
                            },
                          );
                        },
                      ),
                    ],
                  )
                ),

                SizedBox(height: 40),

                ///////////////////////////////////////////////////////////////////////////

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pushNamed(context, Routes.editAlarm, arguments: {'alarm': parameters});
                      },
                      child: Text(
                        'Editar',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {
                        _confirmAlarmDeletion(context, parameters.id);
                      },
                      child: Text(
                        'Excluir',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),

                  ],
                ),

              ],
            ),
          ),
        ],
      ),

      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addHour, arguments: {
                                'alarm': parameters,
                                'hour': null,
                                'editMode': false
                              },).then((value) {
          if (value == true) {
            setState(() {});
          }
        });
        },
        child: Icon(Icons.add),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      */
    );
  }
}