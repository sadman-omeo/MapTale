import 'package:flutter/material.dart';


class LandmarksScreen extends StatelessWidget {
  const LandmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: Text(
          "this is the Landmark Screen",
          style: TextStyle(fontSize: 25),
        ),
      ),
    );


  }
}