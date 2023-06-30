import 'package:do_it/ui/screens/stream_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() {
    Future.delayed(const Duration(milliseconds: 2000)).then((value) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StreamHandler()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset("assets/images/bgs/splash_bg.svg"),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "do it.",
              style: GoogleFonts.righteous(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 70,
                ),
              ),
            ),
          ),
          const Center(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.5,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff6750A4),
                    
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
