import 'dart:isolate';

import 'package:flutter/material.dart';

class Parte1ComIsolate extends StatefulWidget {
  const Parte1ComIsolate({super.key});

  @override
  State<Parte1ComIsolate> createState() => _Parte1ComIsolateState();
}

class _Parte1ComIsolateState extends State<Parte1ComIsolate> {
  String msg = 'Não executou ainda';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Parte 1 - Isolate'),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  msg,
                  textAlign: TextAlign.center,
                ),
                const CircularProgressIndicator(),
                ElevatedButton(
                    onPressed: () {
                      var total = funcaoDeSoma();
                      setState(() {
                        msg = '${DateTime.now()} | PADRÃO | $total';
                      });
                    },
                    child: const Text('Executar Soma')),
                ElevatedButton(
                    onPressed: () async {
                      final receivePort = ReceivePort();

                      Isolate.spawn(
                          funcaoDeSomaViaIsolate, receivePort.sendPort);

                      receivePort.listen((total) {
                        setState(() {
                          msg = '${DateTime.now()} | ISOLATE | $total';
                        });
                      });
                    },
                    child: const Text('Executar Soma (Isolate)'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  double funcaoDeSoma() {
    var total = 0.0;
    for (var i = 0; i < 1000000000; i++) {
      total += i;
    }
    return total;
  }
}

funcaoDeSomaViaIsolate(SendPort sp) {
  var total = 0.0;
  for (var i = 0; i < 1000000000; i++) {
    total += i;
  }
  sp.send(total);
}
