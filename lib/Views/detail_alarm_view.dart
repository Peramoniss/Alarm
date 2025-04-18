import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/day.dart';
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
  List<Day> days = []; 
  Alarm? alarm;

  void loadHours(int id) async {
    // alarm = await DatabaseHelper.getAlarm(id);
    hours = await DatabaseHelper.getHours(id);
    days = await DatabaseHelper.getDays(id);
    if (mounted) setState(() {});
  }


  @override
  void initState() {
    super.initState();

    // Exemplo: Pegando o id da rota, se você passou via argumentos
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        int id = args['id']; // Ou 'alarmId'
        loadHours(id);
      }
    });
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


  void _confirmarExclusaoHorario(BuildContext context, int id) async {
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
      await DatabaseHelper.deleteHour(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Horário excluído!')),
      );
    }
  }


  void _confirmarExclusaoDia(BuildContext context, int id) async {
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
      await DatabaseHelper.deleteDay(id);
      //loadHours(alarmId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Horário excluído!')),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    var parameters;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (ModalRoute.of(context)!.settings.arguments is Alarm) {
        parameters = ModalRoute.of(context)!.settings.arguments as Alarm;
      }
    }
    loadHours(parameters.id);

    String? closest;
    //String closest = "00:00";
    if (alarm != null) {
      String closest = alarm!.getClosestHour(hours);
      // faça algo com closest
    } else {
      print('Alarme ainda não carregado');
    }
    // if (closest.isEmpty) {
    //   closest = "00:00";
    // }

    if (alarm != null) {
      String diaMaisProximo = alarm!.getProximoDia(days);
      // faça algo com closest
    } else {
      print('Alarme ainda não carregado');
    }



    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do alarme'),
      ),
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
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Próximo horário do alarme",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                SizedBox(height: 4),

                Center(
                  child: Text(
                    //'${diaMaisProximo}, ${closest}',,
                    "Segunda-feira, 09:00",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  ),
                ),

                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Lista de horários",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                SizedBox(height: 4),

                // CORREÇÃO AQUI - Adicionar o SizedBox
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
                          ? Center(
                              child: Text(
                                'Nenhum horário adicionado ainda.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : SizedBox(
                              height: 80, // Altura fixa para o ListView
                              child: ListView.builder(
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
                                      _confirmarExclusaoHorario(
                                          context, hour.id!);
                                    },
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Lista de dias",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                SizedBox(height: 4),

                // CORREÇÃO AQUI - Adicionar o SizedBox
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
                      days.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum dia adicionado ainda.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : SizedBox(
                              height: 80, // Altura fixa para o ListView
                              child: ListView.builder(
                                itemCount: days.length,
                                itemBuilder: (context, index) {
                                  final day = days[index];
                                  return ListTile(
                                    title: Text(day.week_day),
                                    subtitle: Text(day.today == 1
                                        ? 'Toca hoje'
                                        : 'Não toca hoje'),
                                    // onTap: () {
                                    //   Navigator.pushNamed(
                                    //     context,
                                    //     Routes.addHour,
                                    //   ).then((value) {
                                    //     if (value == true) {
                                    //       loadHours(parameters.id);
                                    //     }
                                    //   });
                                    // },
                                    onLongPress: () {
                                      _confirmarExclusaoDia(context, day.id!);
                                    },
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pushNamed(context, Routes.editAlarm,
                            arguments: {'alarm': parameters});
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
    );
  }
}
