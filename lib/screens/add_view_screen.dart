import 'package:flutter/material.dart';


class AddViewScreen extends StatelessWidget {
  const AddViewScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: Text(
          "this is the Add/View Screen",
          style: TextStyle(fontSize: 25),
        ),
      ),
    );


  }
}