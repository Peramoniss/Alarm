import '../Models/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class MainNotification extends StatefulWidget {
  const MainNotification({super.key});

  @override
  State<MainNotification> createState() => _MainNotificationState();
}

class _MainNotificationState extends State<MainNotification> {
  final notificacoesLocais = FlutterLocalNotificationsPlugin();

  Future<void> configurarNotificacaoLocal() async {
    const AndroidInitializationSettings cfgAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings cfgiOs = DarwinInitializationSettings();

    const initializationSettings =
        InitializationSettings(android: cfgAndroid, iOS: cfgiOs);

    await notificacoesLocais.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: funcaoRespostaDaNotificacao,
    );
  }

  void funcaoRespostaDaNotificacao(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      Logger().i('notification payload: $payload');
    } else {
      Logger().i('funcaoRespostaDaNotificacao');
    }

    if (context.mounted) {
      Navigator.of(context).pushNamed(Routes.resumonotif, arguments: payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text('Hello Push Notifications!'),
          ),
          ElevatedButton(
            onPressed: () async {
              await configurarNotificacaoLocal();
            },
            child: const Text('Iniciar Cfg Local'),
          ),
          ElevatedButton(
            onPressed: () async {
              const AndroidNotificationDetails canalAgora =
                  AndroidNotificationDetails(
                'canalAgoraId',
                'Notificações Agora',
                channelDescription: 'notificações bem importantes e no momento exato',
                importance: Importance.max,
                priority: Priority.high,
              );

              const NotificationDetails notificationDetails =
                  NotificationDetails(android: canalAgora);

              await notificacoesLocais.show(
                10,
                'Título Agora',
                'Conteúdo em ${DateTime.now()}',
                notificationDetails,
                payload: 'Parâmetro que foi no payload',
              );
            },
            child: const Text('Notificação Agora'),
          ),
          ElevatedButton(
            onPressed: () async {
              const AndroidNotificationDetails canalRecorrente =
                  AndroidNotificationDetails(
                'canalRecorrenciaId',
                'Tempo real',
                channelDescription: 'Todos os avisos em tempo real para os acontecimentos',
              );

              const NotificationDetails notificationDetails =
                  NotificationDetails(android: canalRecorrente);

              await notificacoesLocais.periodicallyShow(
                1254,
                'Acontecendo agora',
                'Nvidia (NVDA) +0.8% de alta em ${DateTime.now()}',
                RepeatInterval.everyMinute,
                notificationDetails,
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              );
            },
            child: const Text('Recorrente Igual'),
          ),
          ElevatedButton(
            onPressed: () async {
              tz.initializeTimeZones();
              final quando = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 15));

              const canalAgendada = NotificationDetails(
                android: AndroidNotificationDetails(
                  'canalSchedule',
                  'Programadas',
                  channelDescription: 'Aqueles avisos de tempos em tempos',
                ),
              );

              await notificacoesLocais.zonedSchedule(
                147,
                'Título da Agendada',
                'Notificação que foi gerado faz a uns segundos e entregue agora',
                quando,
                canalAgendada,
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
              );
            },
            child: const Text('Agendada'),
          ),
          ElevatedButton(
            onPressed: () async {
              await notificacoesLocais.cancelAll();
            },
            child: const Text('Cancelar Todas'),
          ),
        ],
      ),
    );
  }
}