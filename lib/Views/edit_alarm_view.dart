import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/day.dart';
import 'package:despertador/Models/hour.dart';
import 'package:despertador/Services/database.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../Models/routes.dart';

class EditAlarmView extends StatefulWidget {
  const EditAlarmView({super.key});

  @override
  State<EditAlarmView> createState() => _EditAlarmViewState();
}

class _EditAlarmViewState extends State<EditAlarmView> {
  List<String> selectedDays = [];
  List<Hour> hours = [];
  List<Day> days = [];

  final List<String> allDays = [
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo'
  ];

  void loadHours(int id) async {
    hours = await DatabaseHelper.getHours(id);
    days = await DatabaseHelper.getDays(id);
    if (mounted) setState(() {});
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late Alarm alarm;
  var parameters;
  bool _initialized = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_initialized == false) {
      var parameters;
      parameters = ModalRoute.of(context)!.settings.arguments;
      if (parameters is Map<String, dynamic>) {
        alarm = parameters['alarm'] as Alarm;
      }

      loadHours(alarm.id!);
      
      _initialized = true;
      _nameController.text = alarm.name;

    }
  }

  @override
  Widget build(BuildContext context) {
      loadHours(alarm.id!);

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar alarme'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
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
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Ativação",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      value: alarm.active == 1 ? true : false,
                      onChanged: (bool value) {
                        setState(() {
                          alarm.active = value ? 1 : 0;
                        });
                      },
                      activeColor: const Color.fromARGB(255, 4, 102, 200),
                      inactiveThumbColor: const Color.fromARGB(255, 134, 134, 134),
                      inactiveTrackColor: const Color.fromARGB(255, 218, 218, 218),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Lista de horários",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      hours.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum horário adicionado ainda.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : Column(
                              children: hours.map((hour) {
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 4, 102, 200),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      hour.time,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      hour.answered == 1
                                          ? 'Respondido'
                                          : 'Não respondido',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.white),
                                      onPressed: () async {
                                        await DatabaseHelper.deleteHour(hour.id!);
                                        setState(() {
                                          
                                          hours.remove(hour);
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.addHour,
                                        arguments: {
                                          'alarm': alarm,
                                          'hour': hour,
                                          'editMode': true,
                                        },
                                      ).then((value) {
                                        if (value == true) {
                                          loadHours(alarm.id!);
                                        }
                                      });
                                    }
                                  ),
                                );
                              }).toList(),
                            ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            final formattedTime =
                                '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

                            Map<String, dynamic> row = {
                              DatabaseHelper.columnTime: formattedTime,
                              DatabaseHelper.columnAnswered: 0,
                              DatabaseHelper.columnAlarmId: alarm.id,
                            };

                            final id = await DatabaseHelper.insertHour(row);
                            hours.add(Hour(alarmId: alarm.id!, time: formattedTime));
                            setState(() {});
                          }
                        },
                        child: Text(
                          'Adicionar',
                          style: TextStyle(fontSize: 16, color: Colors.black),
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
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 206, 206, 206),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      days.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum dia adicionado ainda.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : Column(
                              children: days.map((day) {
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 4, 102, 200),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      day.week_day,
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.white),
                                      onPressed: () async {
                                        await DatabaseHelper.deleteDay(day.id!);
                                        setState(() {
                                          
                                          days.remove(day);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                      SizedBox(height: 12),
                      ElevatedButton(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300, // Adjust height as needed
          child: ListView.builder(
            itemCount: allDays.length,
            itemBuilder: (context, index) {
              final day = allDays[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  color: const Color.fromARGB(255, 4, 102, 200),
                  child: ListTile(
                    title: Text(
                      day,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        days.contains(day)
                            ? Icons.check_circle
                            : Icons.add_circle,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                         Map<String, dynamic> row = {
                            DatabaseHelper.columnWeekDay: day,
                            DatabaseHelper.columnToday: 0,
                            DatabaseHelper.columnAlarmId: alarm.id,
                          };
                          var id = await DatabaseHelper.insertDay(row);
                        setState(() {
                          // Add the day to the days list if it's not already selected
                          if (!days.contains(day)) {
                            selectedDays.add(day);
    
                          }
                        });
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  },
  child: Text(
    'Adicionar',
    style: TextStyle(fontSize: 16, color: Colors.black),
  ),
),

                    ],
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        // Salvar alterações
                        alarm.name = _nameController.text;
                        DatabaseHelper.editAlarm(alarm);
                      },
                      child: Text(
                        'Salvar',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
