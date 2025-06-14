import '../Models/alarm.dart';
import '../Models/day.dart';
import '../Models/hour.dart';
import '../Services/database.dart';


///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class Repository {
  static final DatabaseHelper _database = DatabaseHelper();
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnActive = 'active';
  static const columnTime = 'time';
  static const columnAnswered = 'answered';
  static const columnAlarmId = 'alarm_id';
  static const columnToday = 'today';
  static const columnWeekDay = 'week_day';
  static const columnDaysPassed = 'days_passed';
  static const columnNum = 'num';

  /////////////////////////////////////////////////////////////////////////////////////////

  final List<String> weekDays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  /////////////////////////////////////////////////////////////////////////////////////////

  String getWeekDay(String inputDay) {
    final Map<String, String> dayMap = {
      'segunda': 'Segunda-feira',
      'terca': 'Terça-feira',
      'quarta': 'Quarta-feira',
      'quinta': 'Quinta-feira',
      'sexta': 'Sexta-feira',
      'sabado': 'Sábado',
      'domingo': 'Domingo',
    };

    return dayMap[inputDay.toLowerCase()] ?? inputDay;
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<int> insertAlarm(Map<String, dynamic> row) async {
    return await _database.insertAlarm(row);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<int> deleteAlarm(int alarmId) async { 
    return _database.deleteAlarm(alarmId);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<void> updateAlarm(Alarm alarm) async {
    await _database.editAlarm(alarm);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<int> insertHour(Map<String, dynamic> row) async {
    return await _database.insertHour(row);
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> updateHour(Hour hour) async {
    await _database.editHour(hour);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<int> deleteHour(int hourId) async { 
    return await _database.deleteHour(hourId);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<int> insertDay(Map<String, dynamic> row) async {
    return await _database.insertDay(row);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  Future<void> updateDay(Day day) async {
    return await _database.editDay(day);
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<int> deleteDay(int dayId) async { 
    return await _database.deleteDay(dayId);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<List<Alarm>> getAllAlarms() async {
    return await _database.getAllAlarms();
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> deleteAllData() async {
    await _database.deleteAllData();
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getAllAlarmsJson() async {
    return await _database.getAllAlarmsJson();
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<List<Hour>> getAllHoursFromAlarm(int alarmId) async {
    return await _database.getAllHoursFromAlarm(alarmId);
  }
  
  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<List<Day>> getAllDaysFromAlarm(int alarmId) async {
    return await _database.getAllDaysFromAlarm(alarmId);
  }
}
