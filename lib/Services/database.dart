import 'package:despertador/Models/alarm.dart';
import 'package:despertador/Models/hour.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  static iniciarBD() async {
    String caminhoBD = await getDatabasesPath();
    String path = join(caminhoBD, arquivoDoBancoDeDados);

    _bancoDeDados = await openDatabase(path,
        version: currentVersion,
        onCreate: funcaoCriacaoBD);
        //onUpgrade: funcaoAtualizarBD,
        //onDowngrade: funcaoDowngradeBD);
  }

  static Future funcaoCriacaoBD(Database db, int version) async {
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
        $columnNum INTEGER,
        $columnDaysPassed INTEGER,
        $columnToday INTEGER NOT NULL,
        $columnAlarmId INTEGER NOT NULL,
        FOREIGN KEY ($columnAlarmId) REFERENCES $alarmTable($columnId) ON DELETE CASCADE
      )
    ''');

  }

  /*//atualiza programa. Por enquanto não é necessário
  Future funcaoAtualizarBD(Database db, int oldVersion, int newVersion) async {
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

  static Future<int> insertAlarm(Map<String, dynamic> row) async {
    await iniciarBD();
    return await _bancoDeDados.insert(alarmTable, row);
  }

  static Future<int> insertHour(Map<String, dynamic> row) async {
    await iniciarBD();
    return await _bancoDeDados.insert(hourTable, row);
  }

  static Future<int> insertDay(Map<String, dynamic> row) async {
    await iniciarBD();
    return await _bancoDeDados.insert(dayTable, row);
  }


  static Future<int> deleteAlarm(int id) async { 
    await iniciarBD();
    //aparentemente o cascade já deleta tudo, então isso seria desnecessário, só a deleção do retorno deveria funcionar
    //await _bancoDeDados.delete(hourTable, where: '$columnAlarmId = ?', whereArgs: [id]);
    //TODO: DELETAR TODOS DA DAYTABLE -> _bancoDeDados.delete(dayTable, where: '$columnAlarmId = ?', whereArgs: [id]);
    return _bancoDeDados.delete(alarmTable, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<int> deleteHour(int id) async { 
    await iniciarBD();
    return await _bancoDeDados.delete(hourTable, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<List<Alarm>> getAlarms() async {
    await iniciarBD();

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

  static Future<List<Hour>> getHours(int id) async {
    await iniciarBD();

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


  static Future<void> editHour(Hour hour) async {
    await iniciarBD();

    await _bancoDeDados.update(
      hourTable,
      hour.toMap(),
      where: 'id = ?',
      whereArgs: [hour.id],
    );
  }

  static Future<void> editAlarm(Alarm alarm) async {
    await iniciarBD();

    await _bancoDeDados.update(
      alarmTable,
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }
}
