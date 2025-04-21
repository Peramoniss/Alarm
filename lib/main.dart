import 'package:despertador/Models/routes.dart';
import 'package:despertador/Views/add_alarm_view.dart';
import 'package:despertador/Views/edit_alarm_view.dart';
import 'package:despertador/Views/add_edit_hour_view.dart';
import 'package:despertador/Views/detail_alarm_view.dart';
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
        Routes.home: (context) => AlarmView(),
        Routes.addAlarm: (context) => AddAlarmView(),
        Routes.editAlarm: (context) => EditAlarmView(),
        Routes.addHour: (context) => AddHourView(),
        Routes.detailAlarm: (context) => DetailAlarmView(),
      },
    );
  }
}
