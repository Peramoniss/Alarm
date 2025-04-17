import 'package:despertador/Models/alarm.dart';
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
  List<Alarm> alarms = []; 
  
  void loadAlarms() async {
    alarms = await DatabaseHelper.getAlarms();
    setState(() {});
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
            children: <Widget>[
              SizedBox(height: 10),

              Text(
                'Alarme em 10 horas e 33 minutos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                )
              ),


              SizedBox(height: 16),

              
              Expanded(
                child: ListView.separated(
                  itemCount: alarms.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: alarms[index].active == 1 ? const Color.fromARGB(255, 4, 102, 200) : const Color.fromARGB(255, 74, 103, 126),  
                        child: ListTile(

                          title: Text(
                            '${alarms[index].name} - id: ${alarms[index].id}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),

                          trailing: Icon(
                            alarms[index].active == 1 ? Icons.check_circle_outlined : Icons.cancel_outlined,
                            color: Colors.white,
                          ),

                          onTap: () {
                            Navigator.pushNamed(context, Routes.detailAlarm, arguments: alarms[index]).then((value) {
                              if (value == true) {
                                setState(() {
                                });
                              }
                            });
                          },

                          onLongPress: () {
                            Navigator.pushNamed(context, Routes.addAlarm, arguments: {'alarm': alarms[index], 'editMode': true}).then((value) {
                              if (value == true) {
                                setState(() {
                                });
                              }
                            });
                          },

                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
            ],
          ),
        ),
      
      ),
      

      /////////////////////////////////////////////////////////////////////////////////////
      // FLOATING ACTION BUTTON                                                          //
      /////////////////////////////////////////////////////////////////////////////////////
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addAlarm, arguments: {'alarm': null, 'editMode': false}).then((value) {
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