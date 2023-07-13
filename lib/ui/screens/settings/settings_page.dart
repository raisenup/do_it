import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light(useMaterial3: true);

  ThemeData get currentTheme => _currentTheme;

  ThemeProvider() {
    initAsync();
  }

  void initAsync() async {
    var result = await getIsBlackThemeOn();
    setTheme(result);
  }

  void saveUserTheme(bool isBlackThemeOn) async {
    final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    await db
        .collection('users')
        .doc(user?.email)
        .set({'black_theme': isBlackThemeOn}, SetOptions(merge: true));
  }

  Future<bool> getIsBlackThemeOn() async {
    final user = FirebaseAuth.instance.currentUser;

    bool? res;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.email)
        .get()
        .then((value) {
      res = value.data()?['black_theme'];
    });
    if (res != null) {
      return res!;
    } else {
      return false;
    }
  }

  void setTheme(bool isBlackThemeOn) {
    _currentTheme = isBlackThemeOn
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    notifyListeners();
  }

  void toggleTheme() {
    _currentTheme = _currentTheme == ThemeData.light(useMaterial3: true)
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    saveUserTheme(currentTheme == ThemeData.dark(useMaterial3: true));
    notifyListeners();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isBlackThemeOn = false;

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL!),
              ),
              title: Text(user.email!),
              subtitle: Text(
                user.displayName!,
                style: const TextStyle(color: Color(0xff7d7d7d)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Black theme",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Switch(
                      value: themeProvider.currentTheme ==
                          ThemeData.dark(useMaterial3: true),
                      onChanged: (value) {
                        setState(() {
                          themeProvider.toggleTheme();
                        });
                      },
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
