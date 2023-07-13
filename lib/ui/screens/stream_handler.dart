import 'package:do_it/ui/screens/home_page/home_page.dart';
import 'package:do_it/ui/screens/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StreamHandler extends StatelessWidget {
  const StreamHandler({super.key});

  void saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    dynamic photoUrl = user?.photoURL;
    dynamic name = user?.displayName;
    if (photoUrl != null && name != null) {
      dynamic userEmail = user?.email;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .set({'photo_url': photoUrl, 'name': name}, SetOptions(merge: true)).then((value) {
        debugPrint("User's data successfully stored in Firestore.");
      }).catchError((error) {
        debugPrint("Failed to store user's data:\n${error.toString()}");
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              saveUserData();
              return const HomePage();
            } else if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong!"));
            } else {
              return const LoginPage();
            }
          },
        ),
      );
}
