import '../Models/alarm.dart';
import '../Models/day.dart';
import '../Models/hour.dart';
import '../Services/repository.dart';
import '../Models/routes.dart';
import 'package:flutter/material.dart';



///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class DetailAlarmView extends StatefulWidget{
  const DetailAlarmView({super.key});

  @override
  State<DetailAlarmView> createState() => _DetailAlarmViewState();
}



///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class _DetailAlarmViewState extends State<DetailAlarmView> {
  Repository repository = Repository();
  List<Hour> hours = []; 
  List<Day> days = []; 
  Alarm? alarm;
  String nextOccurrenceText = "Sem horários ou dias";
  
  /////////////////////////////////////////////////////////////////////////////////////////

  void loadHours(int id) async {
    hours = await repository.getAllHoursFromAlarm(id);
    days = await repository.getAllDaysFromAlarm(id);
    nextOccurrenceText = await getNextAlarmOccurrence(days, hours);
    days = await repository.getAllDaysFromAlarm(id);
    if (mounted) setState(() {});
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  int switchWeekday(Day day){
    int weekday;
    switch (day.week_day.toLowerCase()) {
      case 'segunda':
        weekday = 1;
        break;
      case 'terca':
        weekday = 2;
        break;
      case 'quarta':
        weekday = 3;
        break;
      case 'quinta':
        weekday = 4;
        break;
      case 'sexta':
        weekday = 5;
        break;
      case 'sabado':
        weekday = 6;
        break;
      case 'domingo':
        weekday = 7;
        break;
      default:
        weekday = 1;
        break;
    }

    return weekday;
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<String> getNextAlarmOccurrence(List<Day> days, List<Hour> hours) async {
    if (alarm == null || alarm!.active == 0) return "Desativado";
    if (days.isEmpty || hours.isEmpty) return "Sem horários ou dias";

    DateTime now = DateTime.now().toLocal();
    List<DateTime> futureOccurrences = [];
    int today = now.weekday;

    for (var day in days) {
      for (var hour in hours) {
        List<String> parts = hour.time.split(':');
        int hourPart = int.parse(parts[0]);
        int minutePart = int.parse(parts[1].split(' ')[0]);
        int weekday;

        weekday = switchWeekday(day);

        int dayDiff = ((weekday - today + 7) % 7).toInt();

        DateTime candidateDate = now.add(Duration(days: dayDiff));
        DateTime candidate = DateTime(
          candidateDate.year,
          candidateDate.month,
          candidateDate.day,
          hourPart,
          minutePart,
        );

        if (candidate.isBefore(now)) {
          candidate = candidate.add(Duration(days: 7));
        }

        futureOccurrences.add(candidate);
      }
    }

    futureOccurrences.sort();
    DateTime next = futureOccurrences.first;

    String weekDayText = Repository().weekDays[next.weekday - 1];
    String hourText = '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}';

    for (var day in days){
      int weekday = switchWeekday(day);
      int dayDiff = ((weekday - today + 7) % 7).toInt();
      
      day.today = dayDiff == 0 ? 1 : 0;
      await Repository().updateDay(day);
    }

    return "$weekDayText, $hourText";
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  void _confirmAlarmDeletion(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir este alarme?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await repository.deleteAlarm(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarme excluído!')),
      );

      Navigator.pop(context);
    }
  }
  
  /////////////////////////////////////////////////////////////////////////////////////////
  
  void _confirmHourDeletion(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir este horário?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await repository.deleteHour(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Horário excluído!')),
      );
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  void _confirmDayDeletion(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir este dia?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await repository.deleteDay(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Horário excluído!')),
      );
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    var parameters;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (ModalRoute.of(context)!.settings.arguments is Alarm) {
        parameters = ModalRoute.of(context)!.settings.arguments as Alarm;
        alarm = parameters;
      }
    }

    loadHours(parameters.id);

    return Scaffold(

      /////////////////////////////////////////////////////////////////////////////////////
      // APP BAR                                                                         //
      /////////////////////////////////////////////////////////////////////////////////////
      
      appBar: AppBar(
        title: Text('Detalhes do alarme'),
      ),


      /////////////////////////////////////////////////////////////////////////////////////
      // BODY                                                                            //
      /////////////////////////////////////////////////////////////////////////////////////
      
      body: SingleChildScrollView(
        child:       
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Center(
                    child: Text(
                      "Nome do alarme",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),

                  ///////////////////////////////////////////////////////////////////////////
                  
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            parameters.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ]
                    )
                  ),

                  ///////////////////////////////////////////////////////////////////////////
                  
                  SizedBox(height: 20),

                  ///////////////////////////////////////////////////////////////////////////
                  
                  Center(
                    child: Text(
                      "Próximo horário do alarme",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),

                  ///////////////////////////////////////////////////////////////////////////
                  
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            nextOccurrenceText,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ]
                    )
                  ),

                  ///////////////////////////////////////////////////////////////////////////

                  SizedBox(height: 20),

                  ///////////////////////////////////////////////////////////////////////////
                  
                  Center(
                    child: Text(
                      "Lista de horários",
                      style: TextStyle(fontSize: 18),
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
                        if (hours.isEmpty)
                          Center(
                            child: Text(
                              'Nenhum horário adicionado ainda.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        else
                          ...hours.map((hour) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 190, 190, 190),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),

                                title: Text(
                                  hour.time,
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),

                                subtitle: Text(hour.answered == 1
                                  ? 'Respondido'
                                  : 'Não respondido',
                                  style: TextStyle(color: Colors.black),
                                ),

                                onLongPress: () {
                                  _confirmHourDeletion(context, hour.id!);
                                }
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  
                  ///////////////////////////////////////////////////////////////////////////
                  
                  SizedBox(height: 20),
                  
                  ///////////////////////////////////////////////////////////////////////////

                  Center(
                    child: Text(
                      "Lista de dias",
                      style: TextStyle(fontSize: 18),
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
                        if (days.isEmpty)
                          Center(
                            child: Text(
                              'Nenhum dia adicionado ainda.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        else
                          ...days.map((day) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 190, 190, 190),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),

                                title: Text(
                                  Repository().getWeekDay(day.week_day),
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),

                                subtitle: Text(day.today == 0
                                  ? 'Não toca hoje'
                                  : 'Toca hoje',
                                  style: TextStyle(color: Colors.black),
                                ),

                                onLongPress: () {
                                  _confirmDayDeletion(context, day.id!);
                                },
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  /////////////////////////////////////////////////////////////////////////
                  
                  SizedBox(height: 40),

                  /////////////////////////////////////////////////////////////////////////

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, Routes.editAlarm,
                              arguments: {'alarm': parameters});
                        },
                        child: Text(
                          'Editar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          _confirmAlarmDeletion(context, parameters.id);
                        },
                        child: Text(
                          'Excluir',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
      )
    );
  }
}
