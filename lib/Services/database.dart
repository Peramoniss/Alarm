import '../Models/alarm.dart';
import '../Models/day.dart';
import '../Models/hour.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


///////////////////////////////////////////////////////////////////////////////////////////
// CLASS                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////

class DatabaseHelper {
  static const arquivoDoBancoDeDados = 'database.db';
  static const currentVersion = 1;

  static const alarmTable = "ALARM";
  static const hourTable = "HOUR";
  static const dayTable = "DAY";

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

  static late Database _bancoDeDados;

  /////////////////////////////////////////////////////////////////////////////////////////

  static startDatabase() async {
    String caminhoBD = await getDatabasesPath();
    String path = join(caminhoBD, arquivoDoBancoDeDados);

    _bancoDeDados = await openDatabase(path,
        version: currentVersion,
        onCreate: createDatabase,
        //onUpgrade: funcaoAtualizarBD,
        //onDowngrade: funcaoDowngradeBD);
      );
        
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  static Future createDatabase(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');

    await db.execute('''
      CREATE TABLE $alarmTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnActive INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $hourTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTime TEXT NOT NULL,
        $columnAnswered INTEGER NOT NULL,
        $columnAlarmId INTEGER NOT NULL,
        FOREIGN KEY ($columnAlarmId) REFERENCES $alarmTable($columnId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $dayTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnWeekDay TEXT NOT NULL CHECK($columnWeekDay IN ('segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo', 'n_dias')),
        $columnToday INTEGER NOT NULL,
        $columnAlarmId INTEGER NOT NULL,
        FOREIGN KEY ($columnAlarmId) REFERENCES $alarmTable($columnId) ON DELETE CASCADE
      )
    ''');
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  /*Future funcaoAtualizarBD(Database db, int oldVersion, int newVersion) async {
    //controle dos comandos sql para novas versões

    if (oldVersion != currentVersion){
      if (oldVersion < 2) {
        //Executa comandos
      }
    }
  }*/

  /*Future funcaoDowngradeBD(Database db, int oldVersion, int newVersion) async {
    //controle dos comandos sql para voltar versãoes.
    //Estava-se na 2 e optou-se por regredir para a 1
  }*/

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<int> insertAlarm(Map<String, dynamic> row) async {
    await startDatabase();
    return await _bancoDeDados.insert(alarmTable, row);
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<int> insertHour(Map<String, dynamic> row) async {
    await startDatabase();
    return await _bancoDeDados.insert(hourTable, row);
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<int> insertDay(Map<String, dynamic> row) async {
    await startDatabase();
    return await _bancoDeDados.insert(dayTable, row);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  
  Future<int> deleteAlarm(int id) async { 
    await startDatabase();
    //aparentemente o cascade já deleta tudo, então isso seria desnecessário, só a deleção do retorno deveria funcionar
    return _bancoDeDados.delete(alarmTable, where: '$columnId = ?', whereArgs: [id]);
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> deleteAllData() async {
    await startDatabase();

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, arquivoDoBancoDeDados);
    return await deleteDatabase(path);
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<int> deleteHour(int id) async { 
    await startDatabase();
    return await _bancoDeDados.delete(hourTable, where: '$columnId = ?', whereArgs: [id]);
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<int> deleteDay(int id) async { 
    await startDatabase();
    return await _bancoDeDados.delete(dayTable, where: '$columnId = ?', whereArgs: [id]);
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<List<Alarm>> getAllAlarms() async {
    await startDatabase();

    final List<Map<String, Object?>> alarms =
        await _bancoDeDados.query(alarmTable);

    return [
      for (final {
            columnId: pId as int,
            columnName: pName as String,
            columnActive: pActive as int,
          } in alarms)
        Alarm(id: pId, name: pName, active: pActive),
    ];
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getAllAlarmsJson() async {
    await startDatabase();

    final List<Map<String, Object?>> alarms =
        await _bancoDeDados.query(alarmTable);

    List<Map<String, dynamic>> alarmJsonList = [];

    for (final alarm in alarms) {
      final int alarmId = alarm[columnId] as int;

      // Pega as horas associadas ao alarme
      final List<Map<String, Object?>> hours = await _bancoDeDados.query(
        hourTable,
        where: '$columnAlarmId = ?',
        whereArgs: [alarmId],
      );

      // Pega os dias associados ao alarme
      final List<Map<String, Object?>> days = await _bancoDeDados.query(
        dayTable,
        where: '$columnAlarmId = ?',
        whereArgs: [alarmId],
      );

      // Monta o mapa completo
      Map<String, dynamic> alarmJson = Map.from(alarm);
      alarmJson['hours'] = hours;
      alarmJson['days'] = days;

      alarmJsonList.add(alarmJson);
    }

    return alarmJsonList;
  }


  /////////////////////////////////////////////////////////////////////////////////////////

  /*static Future<Alarm> getAlarm(int id) async {
    await startDatabase();

    final result = await _bancoDeDados.query(
      alarmTable,
      where: '$columnId = ?',
      whereArgs: [id]
    );


    final List<Map<String, Object?>> alarms =
        await _bancoDeDados.query(alarmTable, where: '$columnId = ?', whereArgs: [id]);


    Alarm a = [
      for (final {
            columnId: pId as int,
            columnName: pName as String,
            columnActive: pActive as int,
          } in alarms)
        Alarm(id: pId, name: pName, active: pActive),
    ].first;

    print(a);
    return a;
  }*/

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<List<Hour>> getAllHoursFromAlarm(int id) async {
    await startDatabase();

    final List<Map<String, Object?>> hours =
        await _bancoDeDados.query(hourTable, where: '$columnAlarmId = ?', whereArgs: [id]);

    return [
      for (final {
            columnId: pId as int,
            columnTime: pTime as String,
            columnAnswered: pAnswered as int,
          } in hours)
        Hour(id: pId, time: pTime, answered: pAnswered, alarmId: id),
    ];
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<List<Day>> getAllDaysFromAlarm(int id) async {
    await startDatabase();

    final List<Map<String, Object?>> days =
        await _bancoDeDados.query(dayTable, where: '$columnAlarmId = ?', whereArgs: [id]);

    return [
      for (final {
            columnId: pId as int,
            columnWeekDay: pWeekDay as String,
            columnToday: pToday as int
          } in days)
        Day(id: pId, week_day: pWeekDay, alarmId: id, today: pToday),
    ];
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> editHour(Hour hour) async {
    await startDatabase();

    await _bancoDeDados.update(
      hourTable,
      hour.toMap(),
      where: 'id = ?',
      whereArgs: [hour.id],
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> editAlarm(Alarm alarm) async {
    await startDatabase();

    await _bancoDeDados.update(
      alarmTable,
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////

  Future<void> editDay(Day day) async {
    await startDatabase();

    await _bancoDeDados.update(
      dayTable,
      day.toMap(),
      where: 'id = ?',
      whereArgs: [day.id],
    );
  }
}
