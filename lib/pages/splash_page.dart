import 'package:flutter/material.dart';
import 'package:project_lw/pages/main_page.dart';

class SplashPage extends StatefulWidget {

  static void push(final BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SplashPage._();
    },));
  }

  static SplashPage buildMe() {
    return SplashPage._();
  }

  SplashPage._();

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(const Duration(seconds: 2));
      MainPage.push(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Splash'),
      ),
    );
  }
}
