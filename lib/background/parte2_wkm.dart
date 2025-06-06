import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

const tarefaImediata = "tarefabk1";
const tarefaComProblema = "tarefabk2";
const tarefaDeUmaVez = "tarefabk3";
const tarefaRecorrenteDelay1Min = "tarefabk4";
const tarefaRecorrenteCada30Minutos = "tarefabk5";

@pragma('vm:entry-point')
void backgroundCallback() {
  var log = Logger();
  log.i('callbackDispatcher: INICIANDO....');

  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case tarefaImediata:
        log.i("Tarefa Imediata Executada | Dados = $inputData");

        if (inputData!['pago'] == true) {
          log.i('Pedido foi pago');
        }
        break;

      case tarefaComProblema:
        return Future.error('Ocorreu um problema ao executar a tarefa');

      case tarefaDeUmaVez:
        log.i(
            "Tarefa com o delay de 10 segundos para executar e que executa apenas uma vez: EXECUTOU");
        break;

      case tarefaRecorrenteDelay1Min:
        log.i(
            "Tarefa com atraso de 1 minuto para iniciar depois que soliciou e com recorrência (15 min): EXECUTOU");
        break;

      case tarefaRecorrenteCada30Minutos:
        log.i("Tarefa recorrente de 30min: EXECUTOU");
        break;
    }

    return Future.value(true);
  });
}

class Parte2ComWorkmanager extends StatefulWidget {
  const Parte2ComWorkmanager({super.key});

  @override
  State<Parte2ComWorkmanager> createState() => _Parte2ComWorkmanagerState();
}

class _Parte2ComWorkmanagerState extends State<Parte2ComWorkmanager> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Parte 2 - Workmanager"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ElevatedButton(
                  child: const Text("Iniciar o Workmanager"),
                  onPressed: () {
                    Workmanager().initialize(
                      backgroundCallback,
                      isInDebugMode: true,
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  child: const Text("Tarefa Imediata"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      tarefaImediata,
                      tarefaImediata,
                      inputData: <String, dynamic>{
                        'idDoPedido': 1,
                        'pago': true,
                        'valor': 145.0,
                        'obs': 'Entregar em horário comercial',
                      },
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text("Tarefa com Problema"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      tarefaComProblema,
                      tarefaComProblema,
                    );
                  },
                ),
                ElevatedButton(
                    child: const Text("Executar 1 vez - delay de 10 sec"),
                    onPressed: () {
                      Workmanager().registerOneOffTask(
                        tarefaDeUmaVez,
                        tarefaDeUmaVez,
                        initialDelay: const Duration(seconds: 10),
                      );
                    }),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Workmanager().registerPeriodicTask(
                      tarefaRecorrenteDelay1Min,
                      tarefaRecorrenteDelay1Min,
                      initialDelay: const Duration(minutes: 1),
                      frequency: const Duration(minutes: 15),
                    );
                  },
                  child: const Text("Recorrente - Delay de 1 min"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Workmanager().registerPeriodicTask(
                      tarefaRecorrenteCada30Minutos,
                      tarefaRecorrenteCada30Minutos,
                      frequency: const Duration(minutes: 30),
                    );
                  },
                  child: const Text("Recorrente - a cada 30 min"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Logger().i('Cancelando as tarefas.....');
                    await Workmanager().cancelAll();

                    //Cancela todas tarefas com a tag deinida
                    //await Workmanager().cancelByTag('');

                    //Cancela uma tarefa via nome
                    //await Workmanager().cancelByUniqueName('');
                  },
                  child: const Text("Cancelar Tudo"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
