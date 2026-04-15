import 'package:flutter/material.dart';


class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: Text(
          "this is the Activity Screen",
          style: TextStyle(fontSize: 25),
        ),
      ),
    );


  }
}