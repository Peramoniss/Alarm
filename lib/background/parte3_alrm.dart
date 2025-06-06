import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:logger/logger.dart';

@pragma('vm:entry-point')
void funcaoDeExecucaoDoAlarme() {
  Logger().i('${DateTime.now()}} | Executou alarme');
}

class Parte3ComAlarm extends StatelessWidget {
  const Parte3ComAlarm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Parte 3 - Alarme'),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await AndroidAlarmManager.periodic(
                          const Duration(minutes: 1),
                          0,
                          funcaoDeExecucaoDoAlarme);
                    },
                    child: const Text('Agendar a cada 1 min'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
