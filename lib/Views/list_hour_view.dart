import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/global.dart';
import 'package:despertador/Models/hour.dart';
import 'package:despertador/Services/database.dart';
import 'package:flutter/material.dart';
import '../Models/routes.dart';


///////////////////////////////////////////////////////////////////////////////////////////


class HoursView extends StatefulWidget{
  const HoursView({super.key});

  @override
  State<HoursView> createState() => _HoursViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////




class _HoursViewState extends State<HoursView> {
  
  List<Hour> hours = []; 
  
  void loadHours(int id) async {
    hours = await DatabaseHelper.getHours(id);
    if (mounted) setState(() {}); // if you want to rebuild the UI
  }

  void _confirmarExclusao(BuildContext context, int id) async {
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
      //loadHours(alarmId);
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
    }
  }


  @override
  Widget build(BuildContext context) {
    var parametros = null;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (ModalRoute.of(context)!.settings.arguments is Alarm) {
        parametros = ModalRoute.of(context)!.settings.arguments as Alarm;
      }
    }

    loadHours(parametros.id);

    return Scaffold(

      /////////////////////////////////////////////////////////////////////////////////////
      // APP BAR                                                                         //
      /////////////////////////////////////////////////////////////////////////////////////
      
      appBar: AppBar(
        title: Text('Horários para ${parametros.name}'),
      ),


      /////////////////////////////////////////////////////////////////////////////////////
      // BODY                                                                            //
      /////////////////////////////////////////////////////////////////////////////////////
      
      body: Stack(
    children: [
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              'Alarme em 10 horas e 35 minutos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Expanded(
              child: hours.isEmpty
                  ? Center(child: Text('Nenhum horário adicionado ainda.'))
                  : ListView.builder(
                      itemCount: hours.length,
                      itemBuilder: (context, index) {
                        final hour = hours[index];
                        return ListTile(
                          title: Text(hour.time),
                          subtitle: Text(hour.answered == 1 ? 'Respondido' : 'Não respondido'),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.addHour, arguments: {'alarm': parametros, 'hour': hour, 'editMode': true},)
                            .then((value) {
                              if (value == true) {
                                loadHours(parametros.id);
                              }
                            });
                          },
                          onLongPress: () {
                            _confirmarExclusaoHorario(context, hours[index].id!);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: IconButton(
                  iconSize: 48, // makes it big
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => {
                    _confirmarExclusao(context, parametros.id)
                  }
                ),
              ),
            ),
          ],
        ),
      

      /////////////////////////////////////////////////////////////////////////////////////
      // FLOATING ACTION BUTTON                                                          //
      /////////////////////////////////////////////////////////////////////////////////////
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addHour, arguments: {
                                'alarm': parametros,
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
    );
  }
}