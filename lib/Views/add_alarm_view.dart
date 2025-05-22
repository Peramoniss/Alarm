import '../Models/alarm.dart';
import '../Services/repository.dart';
import '../Services/random_name_service.dart';
import 'package:flutter/material.dart';



///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class AddAlarmView extends StatefulWidget {
  const AddAlarmView({super.key});

  @override
  State<AddAlarmView> createState() => _AddAlarmViewState();
}



///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class _AddAlarmViewState extends State<AddAlarmView> {
  Repository repository = Repository();
  Alarm? editingAlarm;
  bool _alarmActivated = false;
  bool _initialized = false;
  bool _isLoadingName = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late bool isEdit;
  var parametros; 
  
  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> inserir() async {
    Map<String, dynamic> row = {
      Repository.columnName: _nameController.text,
      Repository.columnActive: _alarmActivated == true ? 1 : 0
    };

    await repository.insertAlarm(row);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  ///
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
          _alarmActivated = editingAlarm!.active == 1 ? true : false;
        }
      }
      _initialized = true;
    } 
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
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
                  enabled: !_isLoadingName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: _isLoadingName
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: Icon(Icons.casino),
                            tooltip: 'Gerar nome aleatório',
                            onPressed: () async {
                              setState(() {
                                _isLoadingName = true;
                              });

                              final randomName = await RandomNameService.fetchRandomName();

                              setState(() {
                                _nameController.text = randomName;
                                _isLoadingName = false;
                              });
                            },
                          ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo é obrigatório.';
                    }
                    return null;
                  },
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
                      value: _alarmActivated,
                      onChanged: (bool value) {
                        setState(() {
                          _alarmActivated = value;
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
                        editingAlarm!.active = _alarmActivated == true ? 1 : 0;
                        repository.updateAlarm(editingAlarm!);

                      } else {
                        Map<String, dynamic> row = {
                          Repository.columnName: _nameController.text,
                          Repository.columnActive: _alarmActivated == true ? 1 : 0
                        };

                        await repository.insertAlarm(row);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Alarme adicionado!'),
                          duration: Duration(milliseconds: 1500),
                        ),
                      );

                      Navigator.pop(context, true); // 'true' informs that the state has changed and must rebuild the screen.
                    }
                  },

                  child: Text(
                    'Salvar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
