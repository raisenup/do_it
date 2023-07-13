import 'package:do_it/ui/screens/settings/settings_page.dart';
import 'package:do_it/ui/screens/stream_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:do_it/core/login/github_sign_in.dart';
import 'package:do_it/core/login/google_sign_in.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
          ChangeNotifierProvider(create: (_) => GithubSignInProvider()),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: "do it.",
              theme: themeProvider.currentTheme,
              darkTheme: ThemeData.dark(useMaterial3: true),
              debugShowCheckedModeBanner: false,
              home: const Scaffold(
                body: StreamHandler(),
              ),
            );
          },
        ),
      );
}
