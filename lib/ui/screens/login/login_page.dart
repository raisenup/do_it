import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:do_it/core/login/github_sign_in.dart';
import 'package:do_it/core/login/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Column(
              children: [
                Text(
                  "Welcome!",
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 28),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    "Login to your account to continue.",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Color(0xff747474)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                width: 350,
                height: 50,
                child: TextButton.icon(
                  onPressed: () {
                    final provider = Provider.of<GoogleSignInProvider>(
                        context,
                        listen: false);
                    provider.googleLogin();
                  },
                  label: Text(
                    "Sign in with Google",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  icon: SvgPicture.asset(
                    "assets/images/icons/login/google.svg",
                    colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                  ),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Colors.black.withOpacity(0.05)),
                    shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90.0),
                        side: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                width: 350,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    final provider = Provider.of<GithubSignInProvider>(
                        context,
                        listen: false);
                    provider.githubLogin(context);
                  },
                  label: const Text(
                    "Sign in with GitHub",
                    style: TextStyle(
                      color: Color(0xffffffff),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    "assets/images/icons/login/github.svg",
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
