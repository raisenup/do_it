import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GithubSignInProvider extends ChangeNotifier {
  User? _user;

  User get user => _user!;

  Future githubLogin(BuildContext context) async {
    final provider = GithubAuthProvider();
    provider.addScope("user");
    FirebaseAuth.instance.signInWithProvider(provider);
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
