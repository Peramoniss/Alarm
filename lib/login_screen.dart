import 'package:despertador/Models/routes.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'login_service.dart';
import 'login_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: LoginForm(),
      );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthService servico = AuthService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
                'Informe um usuário (email) e uma senha para se cadastrar ou para realizar o login'),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              String email = _emailController.text;
              String password = _passwordController.text;
              var a = await servico.cadastrar(
                      email: email, senha: password, nome: 'Nome do Usuário');
                  
                if (a == null) {
                  Navigator.pushNamed(
                    context,
                    Routes.viewAlarm,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(a),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
            },
            child: const Text('Cadastrar'),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              var l = Logger();
              String email = _emailController.text;
              String password = _passwordController.text;
              l.i('message=====');
              var a = await servico.login(email: email, senha: password);
 l.i('message=====$a');
                print(a);
                if (a == null) {
                  Navigator.pushNamed(
                    context,
                    Routes.viewAlarm,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(a),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}