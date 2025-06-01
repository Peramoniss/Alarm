import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> login({required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "Email inválido";
        case "wrong-password":
          return "Senha inválida";
      }
      return e.code;
    }

    return null;
  }

  Future<String?> cadastrar({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await userCredential.user!.updateDisplayName(nome);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "Email já usado.";
      }
      return e.code;
    }

    return null;
  }

  Future<String?> trocarSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "E-mail não encontrado";
      }
      return e.code;
    }
    return null;
  }

  Future<String?> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  Future<String?> deletar({required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: _firebaseAuth.currentUser!.email!,
        password: senha,
      );
      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }
}