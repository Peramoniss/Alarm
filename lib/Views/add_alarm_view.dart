import 'package:despertador/Models/global.dart';
import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Services/database.dart';
import 'package:flutter/material.dart';
import '../Models/routes.dart';


///////////////////////////////////////////////////////////////////////////////////////////



class AddAlarmView extends StatefulWidget {
  const AddAlarmView({super.key});

  @override
  State<AddAlarmView> createState() => _AddAlarmViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////


class _AddAlarmViewState extends State<AddAlarmView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _marcado = false;


  /*
  final List<bool> _daysController = List.filled(7, false);

  final List<String> _dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  Future<void> _selecionarHora(BuildContext context) async {
    TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horaSelecionada != null) {
      setState(() {
        _hourController.text = horaSelecionada.format(context);
      });
    }
  }*/
  

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
        editingAlarm = parametros['alarm'] as Alarm?;
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
      appBar: AppBar(title: Text('Adicionar Alarme')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextFormField(
              //   controller: _idController,
              //   decoration: InputDecoration(labelText: 'ID'),
              //   validator: (value) =>
              //       value == null || value.isEmpty ? 'Required' : null,
              // ),

              ///////////////////////////////////////////////////////////////////////////
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),

              ///////////////////////////////////////////////////////////////////////////

              CheckboxListTile(
                title: Text('Ativar alarme'),
                value: _marcado,
                onChanged: (bool? novoValor) {
                  setState(() {
                    _marcado = novoValor ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              
              /*TextFormField(
                controller: _hourController,
                decoration: InputDecoration(
                  labelText: 'Horário',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selecionarHora(context),
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'Selecione um horário' : null,
              ),*/

              SizedBox(height: 16),

              ///////////////////////////////////////////////////////////////////////////
              
              /*Text('Repeat on:'),
              Column(
                children: List.generate(7, (index) {
                  return CheckboxListTile(
                    title: Text(_dayNames[index]),
                    value: _daysController[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _daysController[index] = value ?? false;
                      });
                    },
                  );
                }),
              ),*/

              ///////////////////////////////////////////////////////////////////////////

              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    if (isEdit == true){
                      editingAlarm!.name = _nameController.text;
                      editingAlarm!.active = _marcado == true ? 1 : 0;
                      DatabaseHelper.editAlarm(editingAlarm!);
                    }else{
                      Alarm temp = Alarm(name: _nameController.text, active: _marcado == true ? 1 : 0);

                      Map<String, dynamic> row = {
                        DatabaseHelper.columnName: _nameController.text,
                        DatabaseHelper.columnActive: _marcado == true ? 1 : 0
                      };

                      final id = await DatabaseHelper.insertAlarm(row);
                    }

                    Navigator.pop(context, true); //true informs that the state has changed and must rebuild the screen
                  }
                },
                child: Text('Salvar alarme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}