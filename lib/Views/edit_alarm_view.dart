import '../Models/alarm.dart';
import '../Models/day.dart';
import '../Models/hour.dart';
import '../Services/repository.dart';
import '../Models/routes.dart';
import '../Services/random_name_service.dart';
import 'package:flutter/material.dart';


///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class EditAlarmView extends StatefulWidget {
  const EditAlarmView({super.key});

  @override
  State<EditAlarmView> createState() => _EditAlarmViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class _EditAlarmViewState extends State<EditAlarmView> {
  Repository repository = Repository();
  List<String> selectedDays = [];
  List<Hour> hours = [];
  List<Day> days = [];
  List<Hour> editedHours = [];
  List<Day> editedDays = [];
  bool _initialized = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late Alarm alarm;
  var parameters;

  /////////////////////////////////////////////////////////////////////////////////////////

  final List<String> allDays = [
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo'
  ];

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> loadData(int id) async {
    final fetchedHours = await repository.getAllHoursFromAlarm(id);
    final fetchedDays = await repository.getAllDaysFromAlarm(id);

    setState(() {
      hours = fetchedHours;
      days = fetchedDays;

      editedHours = fetchedHours.map((h) => h.copy()).toList();
      editedDays = fetchedDays.map((d) => d.copy()).toList();
    });
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_initialized == false) {
      var parameters;
      parameters = ModalRoute.of(context)!.settings.arguments;
      if (parameters is Map<String, dynamic>) {
        alarm = parameters['alarm'] as Alarm;
      }

      loadData(alarm.id!);
      
      _initialized = true;
      _nameController.text = alarm.name;

    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      if (args != null && args['alarm'] != null) {
        setState(() {
          alarm = args['alarm'] as Alarm;
        });
        loadData(alarm.id!);
      }
    });
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      /////////////////////////////////////////////////////////////////////////////////////
      // APP BAR                                                                         //
      /////////////////////////////////////////////////////////////////////////////////////
      
      appBar: AppBar(
        title: Text('Editar alarme'),
      ),


      /////////////////////////////////////////////////////////////////////////////////////
      // BODY                                                                            //
      /////////////////////////////////////////////////////////////////////////////////////
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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

                ///////////////////////////////////////////////////////////////////////////
                
                SizedBox(height: 20),

                ///////////////////////////////////////////////////////////////////////////

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

                ///////////////////////////////////////////////////////////////////////////

                SizedBox(height: 20),

                ///////////////////////////////////////////////////////////////////////////

                Center(
                  child: Text(
                    "Lista de horários",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),

                SizedBox(height: 4),

                ///////////////////////////////////////////////////////////////////////////

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
                      editedHours.isEmpty

                      ? 
                      
                      Center(
                        child: Text(
                          'Nenhum horário adicionado ainda.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )

                      : 
                      
                      Column(
                        children: editedHours.map((hour) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 4, 102, 200),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              
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
                                  setState(() {
                                    editedHours.remove(hour);
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
                                    loadData(alarm.id!);
                                  }
                                });
                              }

                            ),
                          );
                        }).toList(),
                      ),

                      /////////////////////////////////////////////////////////////////////
                      
                      SizedBox(height: 12),

                      /////////////////////////////////////////////////////////////////////

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
                              Repository.columnTime: formattedTime,
                              Repository.columnAnswered: 0,
                              Repository.columnAlarmId: alarm.id,
                            };

                            await repository.insertHour(row);
                            editedHours.add(Hour(alarmId: alarm.id!, time: formattedTime));
                            setState(() {});
                          }
                        },

                        child: Text(
                          'Adicionar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                ///////////////////////////////////////////////////////////////////////////
                
                SizedBox(height: 20),
                
                ///////////////////////////////////////////////////////////////////////////
                
                Center(
                  child: Text(
                    "Lista de dias",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),

                SizedBox(height: 4),

                ///////////////////////////////////////////////////////////////////////////

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
                      editedDays.isEmpty
                      ? 
                      
                      Center(
                        child: Text(
                          'Nenhum dia adicionado ainda.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )

                      : 
                      
                      Column(
                        children: editedDays.map((day) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 4, 102, 200),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              
                              title: Text(
                                Repository().getWeekDay(day.week_day),
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),

                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () async {
                                  setState(() {
                                    editedDays.remove(day);
                                  });
                                },
                              ),

                            ),
                          );
                        }).toList(),
                      ),

                      /////////////////////////////////////////////////////////////////////
                      
                      SizedBox(height: 12),

                      /////////////////////////////////////////////////////////////////////

                      ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: SizedBox(
                                  height: 300,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ListView.builder(
                                      itemCount: Repository().weekDays.length,
                                      itemBuilder: (context, index) {
                                        final dayToDisplay = Repository().weekDays[index];
                                        final dayToInsert = allDays[index];

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            top: index == 0 ? 8.0 : 5.0,
                                            bottom: 5.0,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Container(
                                              color: const Color.fromARGB(255, 190, 190, 190),
                                              child: ListTile(
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),

                                                title: Text(
                                                  dayToDisplay,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(255, 43, 43, 43),
                                                  ),
                                                ),

                                                trailing: IconButton(
                                                  icon: Icon(
                                                    editedDays.any((d) => d.week_day == dayToInsert)
                                                        ? Icons.check_circle
                                                        : Icons.add_circle,
                                                    color: const Color.fromARGB(255, 43, 43, 43),
                                                  ),

                                                  onPressed: () async {
                                                    if (!editedDays.any((d) => d.week_day == dayToInsert)) {
                                                      Map<String, dynamic> row = {
                                                        Repository.columnWeekDay: dayToInsert,
                                                        Repository.columnToday: 0,
                                                        Repository.columnAlarmId: alarm.id,
                                                      };
                                                      await repository.insertDay(row);
                                                      Navigator.pop(context);
                                                    }
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },

                        child: const Text(
                          'Adicionar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                ///////////////////////////////////////////////////////////////////////////

                SizedBox(height: 20),
                
                ///////////////////////////////////////////////////////////////////////////
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[

                    /// RANDOM DATA GENERATION BUTTON /////////////////////////////////////
                    
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });

                        _nameController.text = await RandomNameService.fetchRandomName();

                        String temp_text = await RandomNameService.fetchRandomName();
                        alarm.active = temp_text.codeUnitAt(0) % 2;

                        for (int i = 0; i < 2; i++) {
                          temp_text = await RandomNameService.fetchRandomName();
                          int index = temp_text.codeUnitAt(0) % 7;
                          String dayToAdd = allDays[index];

                          if (!editedDays.any((d) => d.week_day == dayToAdd)) {
                            editedDays.add(Day(alarmId: alarm.id!, week_day: dayToAdd, today: 0));
                          }
                        }

                        for (int i = 0; i < 2; i++) {
                          temp_text = await RandomNameService.fetchRandomName();
                          int hour = temp_text.codeUnitAt(0) % 24;
                          int minutes = (temp_text.codeUnitAt(0) + temp_text.codeUnitAt(1) + temp_text.codeUnitAt(2)) % 60;
                          final String formattedTime = '${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

                          if (!editedHours.any((h) => h.time == formattedTime)) {
                            editedHours.add(Hour(alarmId: alarm.id!, time: formattedTime, answered: 0));
                          }
                        }

                        setState(() {
                          isLoading = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Dados gerados com sucesso!')),
                        );
                      },
                      child: Text(
                        'Gerar dados aleatórios',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),

                    SizedBox(height: 20),

                    /// SAVE CHANGES BUTTON ///////////////////////////////////////////////

                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                        isLoading = true;
                        });

                        alarm.name = _nameController.text;
                        await repository.updateAlarm(alarm);

                        final existingHours = await repository.getAllHoursFromAlarm(alarm.id!);

                        for (final h in existingHours) {
                          await repository.deleteHour(h.id!);
                        }

                        for (final h in editedHours) {
                          Map<String, dynamic> row = {
                            Repository.columnTime: h.time,
                            Repository.columnAnswered: h.answered,
                            Repository.columnAlarmId: alarm.id,
                          };
                          await repository.insertHour(row);
                        }

                        final existingDays = await repository.getAllDaysFromAlarm(alarm.id!);

                        for (final d in existingDays) {
                          await repository.deleteDay(d.id!);
                        }

                        for (final d in editedDays) {
                          Map<String, dynamic> row = {
                            Repository.columnWeekDay: d.week_day,
                            Repository.columnToday: d.today ?? 0,
                            Repository.columnAlarmId: alarm.id,
                          };
                          await repository.insertDay(row);
                        }

                        setState(() {
                          isLoading = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Edição realizada com sucesso!')),
                        );
                      },

                      child: Text(
                        'Salvar',
                        style: TextStyle(fontSize: 18),
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
