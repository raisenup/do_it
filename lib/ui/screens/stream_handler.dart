import 'package:do_it/ui/screens/home_page/home_page.dart';
import 'package:do_it/ui/screens/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StreamHandler extends StatelessWidget {
  const StreamHandler({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder:(context, snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      else if (snapshot.hasData) {
        return const HomePage();
      }
      else if (snapshot.hasError) {
        return const Center(child: Text("Something went wrong!"));
      }
      else {
        return const LoginPage();
      }
    },),
  );
}
