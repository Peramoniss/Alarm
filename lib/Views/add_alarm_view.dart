import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Services/database.dart';
import 'package:flutter/material.dart';


///////////////////////////////////////////////////////////////////////////////////////////


class AddAlarmView extends StatefulWidget {
  const AddAlarmView({super.key});

  @override
  State<AddAlarmView> createState() => _AddAlarmViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////


class _AddAlarmViewState extends State<AddAlarmView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _marcado = false;

  Future<void> inserir() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: _nameController.text,
      DatabaseHelper.columnActive: _marcado == true ? 1 : 0
    };

    final id = await DatabaseHelper.insertAlarm(row);
  }


  bool _initialized = false;
  Alarm? editingAlarm;
  late bool isEdit;
  var parametros; 

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    if (_initialized == false){
      parametros = ModalRoute.of(context)!.settings.arguments;
      if (parametros is Map<String, dynamic>) {
        editingAlarm = parametros['alarmObject'] as Alarm?;
        isEdit = parametros['editMode'] as bool;
        if (editingAlarm != null && isEdit == true) {
          _nameController.text = editingAlarm!.name;
          _marcado = editingAlarm!.active == 1 ? true : false;
        }
      }
      _initialized = true;
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /////////////////////////////////////////////////////////////////////////////////////
      // APP BAR                                                                         //
      /////////////////////////////////////////////////////////////////////////////////////
      
      appBar: AppBar(
        title: Text('Adicionar alarme')
      ),


      /////////////////////////////////////////////////////////////////////////////////////
      // BODY                                                                            //
      /////////////////////////////////////////////////////////////////////////////////////
      
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                Center(
                  child: Text(
                    "Nome",
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

                SizedBox(height: 16),

                ///////////////////////////////////////////////////////////////////////////
                
                Center(
                  child: Text(
                    "Ativar alarme",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      value: _marcado,
                      onChanged: (bool value) {
                        setState(() {
                          _marcado = value ?? false;
                        });
                      },
                      activeColor: const Color.fromARGB(255, 4,102,200),
                      inactiveThumbColor: const Color.fromARGB(255, 134, 134, 134),
                      inactiveTrackColor: const Color.fromARGB(255, 218, 218, 218),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                ///////////////////////////////////////////////////////////////////////////
                
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {

                      if (isEdit == true) {
                        editingAlarm!.name = _nameController.text;
                        editingAlarm!.active = _marcado == true ? 1 : 0;
                        DatabaseHelper.editAlarm(editingAlarm!);

                      } else {
                        Alarm temp = Alarm(name: _nameController.text, active: _marcado == true ? 1 : 0);

                        Map<String, dynamic> row = {
                          DatabaseHelper.columnName: _nameController.text,
                          DatabaseHelper.columnActive: _marcado == true ? 1 : 0
                        };

                        final id = await DatabaseHelper.insertAlarm(row);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Alarme adicionado!')),
                      );

                      Navigator.pop(context, true); // 'true' informs that the state has changed and must rebuild the screen.
                    }
                  },

                  child: Text(
                    'Salvar',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}