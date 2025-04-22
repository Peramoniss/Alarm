import '../Models/alarm.dart';
import '../Models/hour.dart';
import '../Services/repository.dart';
import 'package:flutter/material.dart';


///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class AddHourView extends StatefulWidget {
  const AddHourView({super.key});

  @override
  State<AddHourView> createState() => _AddHourViewState();
}


///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class _AddHourViewState extends State<AddHourView> {
  Repository repository = Repository();
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

                SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Hour(time: _timeController.text, alarmId: alarm.id!);
                      if (isEdit == true) {
                        editingHour!.time = _timeController.text;
                        repository.updateHour(editingHour!);
                      } else {
                        Map<String, dynamic> row = {
                          Repository.columnTime: _timeController.text,
                          Repository.columnAlarmId: alarm.id,
                          Repository.columnAnswered: 0
                        };

                        await repository.insertHour(row);
                      }

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