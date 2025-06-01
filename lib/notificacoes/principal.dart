import 'package:flutter/material.dart';
import 'resumonotif.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final chaveDeNavegacao = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var notificacoesLocais = FlutterLocalNotificationsPlugin();

  Future<void> configurarNotificacaoLocal() async {
    const AndroidInitializationSettings cfgAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const cfgiOs = DarwinInitializationSettings();

    var initializationSettings =
        const InitializationSettings(android: cfgAndroid, iOS: cfgiOs);

    await notificacoesLocais.initialize(initializationSettings,
        onDidReceiveNotificationResponse: funcaoRespostaDaNotificacao);
  }

  void funcaoRespostaDaNotificacao(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      Logger().i('notification payload: $payload');
    } else {
      Logger().i('funcaoRespostaDaNotificacao');
    }

    chaveDeNavegacao.currentState?.pushNamed('/aviso', arguments: payload);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Center(
            child: Text('Hello Push Notifications!'),
          ),
          ElevatedButton(
              onPressed: () async {
                await configurarNotificacaoLocal();
              },
              child: const Text('Iniciar Cfg Local')),
          ElevatedButton(
              onPressed: () async {
                const AndroidNotificationDetails canalAgora =
                    AndroidNotificationDetails(
                  'canalAgoraId',
                  'Notificações Agora',
                  channelDescription:
                      'notificações bem importantes e no momento exato',
                  importance: Importance.max,
                  priority: Priority.high,
                );

                const NotificationDetails notificationDetails =
                    NotificationDetails(android: canalAgora);

                await notificacoesLocais.show(10, 'Título Agora',
                    'Conteúdo em ${DateTime.now()}', notificationDetails,
                    payload: 'Parâmetro que foi no payload');
              },
              child: const Text('Notificação Agora')),
          ElevatedButton(
              onPressed: () async {
                const AndroidNotificationDetails canalRecorrente =
                    AndroidNotificationDetails(
                        'canalRecorrenciaId', 'Tempo real',
                        channelDescription:
                            'Todos os avisos em tempo real para os acontecimentos');
                const NotificationDetails notificationDetails =
                    NotificationDetails(android: canalRecorrente);

                await notificacoesLocais.periodicallyShow(
                    1254,
                    'Acontecendo agora',
                    'Nvidia (NVDA) +0.8% de alta em ${DateTime.now()}',
                    RepeatInterval.everyMinute,
                    notificationDetails,
                    androidScheduleMode:
                        AndroidScheduleMode.exactAllowWhileIdle);
              },
              child: const Text('Recorrente Igual')),
          ElevatedButton(
              onPressed: () async {
                //Inicializa pacote de timezone para usarmos depois nas
                //notificações agendadas via .zonedSchedule()
                tz.initializeTimeZones();

                var quando = tz.TZDateTime.now(tz.local)
                    .add(const Duration(seconds: 15));

                var canalAgendada = const NotificationDetails(
                    android: AndroidNotificationDetails(
                        'canalSchedule', 'Programadas',
                        channelDescription:
                            'Aqueles avisos de tempos em tempos'));

                await notificacoesLocais.zonedSchedule(
                    147,
                    'Título da Agendada',
                    'Notificação que foi gerado faz a uns segundos e entregue agora',
                    quando,
                    canalAgendada,
                    androidScheduleMode:
                      AndroidScheduleMode.exactAllowWhileIdle
                      );
              },
              child: const Text('Agendada')),
          ElevatedButton(
              onPressed: () async {
                //Para cancelar uma notificação específica
                //await flutterLocalNotificationsPlugin.cancel(ID_DA_NOTIFICACAO);

                await notificacoesLocais.cancelAll();
              },
              child: const Text('Cancelar Todas')),
        ]),
      ),

      //Usamos a chave de navegação para que o gerenciadorpush faça o controle das rotas e não se preocupe com o contexto
      navigatorKey: chaveDeNavegacao,

      //Relaçao Chave/Tela para a navegação
      routes: {
        '/aviso': (context) => const ResumoNotificacao(),
      },
    );
  }
}
