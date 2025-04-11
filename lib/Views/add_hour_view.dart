import 'package:despertador/Models/global.dart';
import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/hour.dart';
import 'package:despertador/Services/database.dart';
import 'package:flutter/material.dart';
import '../Models/routes.dart';


///////////////////////////////////////////////////////////////////////////////////////////



class AddHourView extends StatefulWidget {
  const AddHourView({super.key});

  @override
  State<AddHourView> createState() => _AddHourViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////


class _AddHourViewState extends State<AddHourView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();


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
  ];*/

  Future<void> _selecionarHora(BuildContext context) async {
    TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horaSelecionada != null) {
      setState(() {
        _timeController.text = horaSelecionada.format(context);
      });
    }
  }

  bool _initialized = false;
  late Alarm alarm;
  Hour? editingHour;
  late bool isEdit;
  var parametros; 

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    if (_initialized == false){
      parametros = ModalRoute.of(context)!.settings.arguments;
      if (parametros is Map<String, dynamic>) {
        alarm = parametros['alarm'] as Alarm;
        editingHour = parametros['hour'] as Hour?;
        isEdit = parametros['editMode'] as bool;
        if (editingHour != null && isEdit == true) {
          _timeController.text = editingHour!.time;
        }
      }
      _initialized = true;
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Horário' : 'Adicionar Horário')),
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
                controller: _timeController,
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
              ),

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
                    // Hour temp = Hour(time: _timeController.text, alarmId: parametros.id);
                    if (isEdit == true){
                      editingHour!.time = _timeController.text;
                      DatabaseHelper.editHour(editingHour!);
                    }else{
                      Map<String, dynamic> row = {
                        DatabaseHelper.columnTime: _timeController.text,
                        DatabaseHelper.columnAlarmId: alarm.id,
                        DatabaseHelper.columnAnswered: 0
                      };

                      final id = await DatabaseHelper.insertHour(row);
                    }

                    Navigator.pop(context, true); //true informs that the state has changed and must rebuild the screen
                  }
                },
                child: Text('Salvar horário'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}