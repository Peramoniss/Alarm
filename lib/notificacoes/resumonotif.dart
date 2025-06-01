import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ResumoNotificacao extends StatefulWidget {
  const ResumoNotificacao({super.key});

  @override
  State<ResumoNotificacao> createState() => _ResumoNotificacaoState();
}

class _ResumoNotificacaoState extends State<ResumoNotificacao> {
  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments is RemoteMessage) {
      final conteudo =
          ModalRoute.of(context)!.settings.arguments as RemoteMessage;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Notificação Push'),
        ),
        body: Column(
          children: [
            Center(child: Text(conteudo.notification!.title.toString())),
            Center(child: Text(conteudo.notification!.body.toString())),
            Center(child: Text(conteudo.data.toString())),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notificação Local'),
        ),
        body: Column(
          children: [
            Center(
                child: Text(
                    ModalRoute.of(context)!.settings.arguments.toString())),
          ],
        ),
      );
    }
  }
}
