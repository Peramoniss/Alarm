import 'package:despertador/Models/routes.dart';
import 'package:despertador/Views/add_alarm_view.dart';
import 'package:despertador/Views/add_hour_view.dart';
import 'package:despertador/Views/list_hour_view.dart';
import 'package:despertador/Views/list_alarm_view.dart';
import 'package:flutter/material.dart';


///////////////////////////////////////////////////////////////////////////////////////////


void main() {
  runApp(const MyApp());
}


///////////////////////////////////////////////////////////////////////////////////////////


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Despertador',
      initialRoute: Routes.home,
      navigatorKey: Routes.nav,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 230, 230, 230),

        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: StadiumBorder(),
          elevation: 2,
        ),
      ),
      
      routes: {
        Routes.home: (context) => AlarmView(),
        Routes.addAlarm: (context) => AddAlarmView(),
        Routes.addHour: (context) => AddHourView(),
        Routes.getHours: (context) => HoursView(),
      },
    );
  }
}