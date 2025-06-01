import 'principal.dart';
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:logger/logger.dart';

class GerenciadorPush {
  final _firebaseMsg = FirebaseMessaging.instance;

  Future<void> iniciar() async {
    NotificationSettings msgCfg = await _firebaseMsg.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final log = Logger();

    log.i('PERMISSÃO USUÁRIO: ${msgCfg.authorizationStatus}');

    final tokenUsuario = await obterTokenDoUsuario();

    log.i('TOKEN: $tokenUsuario');
    
    configurarIteracaoComNotificacao();
  }

  Future<String?> obterTokenDoUsuario() async {
    return await _firebaseMsg.getToken();
  }

  Future<void> configurarIteracaoComNotificacao() async {    
    //Quando o app nem esta aberto
    await _firebaseMsg.getInitialMessage().then(processarNotificacao);   

    //Quando esta em foco
    FirebaseMessaging.onMessage.listen(processarNotificacao);

    //Quando esta em background
    FirebaseMessaging.onMessageOpenedApp.listen(processarNotificacao);
  }

  void processarNotificacao(RemoteMessage? msg) {    
    //Quando tocar na notificação
    //Se tipo = aviso: Abre a tela resumoNotificacao.dart
    //Se não: abre o app na sua tela principal
    if (msg?.data['tipo'] == 'aviso') {
      chaveDeNavegacao.currentState?.pushNamed('/aviso', arguments: msg);
    } 
  }
}
