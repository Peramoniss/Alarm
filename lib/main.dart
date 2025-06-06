import 'package:despertador/Models/routes.dart';
import 'package:despertador/Views/add_alarm_view.dart';
import 'package:despertador/Views/edit_alarm_view.dart';
import 'package:despertador/Views/add_edit_hour_view.dart';
import 'package:despertador/Views/detail_alarm_view.dart';
import 'package:despertador/Views/edit_alarm_view.dart';
import 'package:despertador/Views/add_edit_hour_view.dart';
import 'package:despertador/Views/detail_alarm_view.dart';
import 'package:despertador/Views/list_alarm_view.dart';
import 'package:despertador/login_screen.dart';
import 'package:despertador/notificacoes/gerenciador_notificacoes.dart';
import 'package:despertador/notificacoes/principal_gpt.dart';
import 'package:despertador/notificacoes/resumonotif.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:despertador/background/parte1_iso.dart';


///////////////////////////////////////////////////////////////////////////////////////////


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GerenciadorPush().iniciar();
  runApp(const MyApp());
}


///////////////////////////////////////////////////////////////////////////////////////////


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Despertador',
      initialRoute: Routes.backtest, //trocar para notification, home, para testar depois
      navigatorKey: Routes.nav,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 231, 231, 231),

        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 4, 102, 200),
          foregroundColor: Colors.white,
          shape: StadiumBorder(),
          elevation: 2,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 4, 102, 200),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.0), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
        ),
      ),
      
      routes: {
        Routes.home: (context) => LoginScreen(),
        Routes.viewAlarm: (context) => AlarmView(),
        Routes.addAlarm: (context) => AddAlarmView(),
        Routes.editAlarm: (context) => EditAlarmView(),
        Routes.addHour: (context) => AddHourView(),
        Routes.detailAlarm: (context) => DetailAlarmView(),
        Routes.notification: (context) => MainNotification(),
        Routes.resumonotif: (context) => ResumoNotificacao(),
        Routes.backtest: (context) => Parte1ComIsolate(),
      },
    );
  }
}

