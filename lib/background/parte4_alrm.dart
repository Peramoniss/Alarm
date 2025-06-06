import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

const String isolateName = 'isolate';

ReceivePort port = ReceivePort();

class Parte4ComAlarm extends StatelessWidget {
  const Parte4ComAlarm({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: _AlarmHomePage(),
    );
  }
}

class _AlarmHomePage extends StatefulWidget {
  const _AlarmHomePage();

  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<_AlarmHomePage> {
  int _counter = 0;
  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.granted;

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();
    _checkExactAlarmPermission();
    port.listen((_) async => await _incrementCounter());
  }

  void _checkExactAlarmPermission() async {
    final currentStatus = await Permission.scheduleExactAlarm.status;
    setState(() {
      _exactAlarmPermissionStatus = currentStatus;
    });
  }

  Future<void> _incrementCounter() async {
    Logger().i('counter++');
    setState(() {
      _counter++;
    });
  }

  static SendPort? uiSendPort;

  @pragma('vm:entry-point')
  static Future<void> callback() async {
    Logger().i('Executou a função de callback');

    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parte 4 - Alarme'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Execuções: $_counter',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_exactAlarmPermissionStatus.isDenied)
              Text(
                'SCHEDULE_EXACT_ALARM: Sem permissão',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              )
            else
              Text(
                'SCHEDULE_EXACT_ALARM: Com permissão',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _exactAlarmPermissionStatus.isDenied
                  ? () async {
                      await Permission.scheduleExactAlarm
                          .onGrantedCallback(() => setState(() {
                                _exactAlarmPermissionStatus =
                                    PermissionStatus.granted;
                              }))
                          .request();
                    }
                  : null,
              child: const Text('Gerenciar Permissão'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await AndroidAlarmManager.oneShot(
                  const Duration(seconds: 5),
                  101010, //ID do nosso alarme
                  callback,
                  exact: true,
                );
              },
              child: const Text('Agendar uma execução'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
