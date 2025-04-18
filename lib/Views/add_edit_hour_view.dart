import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/hour.dart';
import 'package:despertador/Services/database.dart';
import 'package:flutter/material.dart';


///////////////////////////////////////////////////////////////////////////////////////////


class AddHourView extends StatefulWidget {
  const AddHourView({super.key});

  @override
  State<AddHourView> createState() => _AddHourViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////


class _AddHourViewState extends State<AddHourView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _timeController = TextEditingController();
  late Alarm alarm;
  late bool isEdit;
  var parametros;
  bool _initialized = false;
  Hour? editingHour;
  

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _timeController.text = selectedTime.format(context);
      });
    }
  }

  
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

      /////////////////////////////////////////////////////////////////////////////////////
      // APP BAR                                                                         //
      /////////////////////////////////////////////////////////////////////////////////////
      
      appBar: AppBar(
        title: Text(isEdit ? 'Editar horário' : 'Adicionar horário')
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
                    "Horário",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),

                SizedBox(height: 4),
                
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
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
                      if (isEdit == true) {
                        editingHour!.time = _timeController.text;
                        DatabaseHelper.editHour(editingHour!);
                      } else {
                        Map<String, dynamic> row = {
                          DatabaseHelper.columnTime: _timeController.text,
                          DatabaseHelper.columnAlarmId: alarm.id,
                          DatabaseHelper.columnAnswered: 0
                        };

                        final id = await DatabaseHelper.insertHour(row);
                      }

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