import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/hour.dart';
import 'package:despertador/Services/database.dart';
import 'package:flutter/material.dart';
import '../Models/routes.dart';


///////////////////////////////////////////////////////////////////////////////////////////


class EditAlarmView extends StatefulWidget{
  const EditAlarmView({super.key});

  @override
  State<EditAlarmView> createState() => _EditAlarmViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////


class _EditAlarmViewState extends State<EditAlarmView> {
  List<String> selectedDays = [];
  List<Hour> hours = []; 

  final List<String> allDays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late Alarm alarm;
  var parameters;
  bool _initialized = false;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    if (_initialized == false){
      parameters = ModalRoute.of(context)!.settings.arguments;
      if (parameters is Map<String, dynamic>) {
        alarm = parameters['alarm'] as Alarm;     
      }
      _initialized = true;
      _nameController.text = alarm.name;
    } 
  }

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
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
                                //_marcado = value ?? false;
                              });
                            },
                            activeColor: const Color.fromARGB(255, 4,102,200),
                            inactiveThumbColor: const Color.fromARGB(255, 134, 134, 134),
                            inactiveTrackColor: const Color.fromARGB(255, 218, 218, 218),
                          ),
                        ],
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            hours.isEmpty

                            ?
                            
                            Center(
                              child: Text(
                                'Nenhum horário adicionado ainda.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )

                            : 
                            
                            SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  itemCount: hours.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final hour = hours[index];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Container(
                                        color: const Color.fromRGBO(4, 102, 200, 1),  
                                        child: ListTile(
                                          title: Text(
                                            hour.time,
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                          
                                          subtitle: Text(hour.answered == 1
                                              ? 'Respondido'
                                              : 'Não respondido',
                                              style: TextStyle(fontSize: 16, color: Colors.white)
                                          ),

                                          trailing: SizedBox(
                                            width: 80,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit, color: Colors.white),
                                                  onPressed: () {
                                                    // ação de editar
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.white),
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedDays.removeAt(index);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),

                                          onLongPress: () {
                                            setState(() {
                                              hours.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),



                            SizedBox(height: 12),

                            ElevatedButton(
                              onPressed: () async {
                                final TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                if (pickedTime != null) {
                                  final formattedTime = pickedTime.hour.toString().padLeft(2, '0') + ':' + pickedTime.minute.toString().padLeft(2, '0');

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
                            selectedDays.isEmpty

                            ? 
                            
                            Center(
                              child: Text(
                                'Nenhum dia adicionado ainda.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )

                            :

                            ListView.builder(
                              itemCount: selectedDays.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final day = selectedDays[index];
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
                                        icon: Icon(Icons.delete, color: Colors.white),
                                        onPressed: () {
                                          setState(() {
                                            selectedDays.removeAt(index);
                                          });
                                        },
                                      ),

                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 12),

                            ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ListView.builder(
                                      itemCount: allDays.length,
                                      itemBuilder: (context, index) {
                                        final day = allDays[index];
                                        return ListTile(
                                          title: Text(day),
                                          onTap: () {
                                            if (!selectedDays.contains(day)) {
                                              setState(() {
                                                selectedDays.add(day);
                                              });
                                            }
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
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

                      ///////////////////////////////////////////////////////////////////////////
                      
                      SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () async {
                              //Navigator.pop(context, true);
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
                )
              ),
            ),
          ],
        ),
      )

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