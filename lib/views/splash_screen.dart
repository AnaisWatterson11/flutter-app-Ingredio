import 'package:flutter/material.dart';

class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Your logo
            Image(
              image: AssetImage('assets/icon/icon_no_bg.png'),
              width: 180,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 46, 116, 57)),
            ),
          ],
        ),
      ),
    );
  }
}
