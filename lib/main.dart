import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/add_view_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/landmarks_screen.dart';



void main() {
  runApp(const MapTaleApp());
}

class MapTaleApp extends StatelessWidget {
  const MapTaleApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // check if needed????????
      title: 'MapTale',
      theme: ThemeData(


        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,  // Check if needed?????????????
      ),
      home: const MyHomeScreen(title: 'MAP TALE'),
    );
  }
}



class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int _Selectedindex = 0;

  final List<Widget> _screens = const [

    MapScreen(),
    LandmarksScreen(),
    ActivityScreen(),
    AddViewScreen()

  ];


  void _tapped(int index){
    setState(() {
      _Selectedindex = index;
    });
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: _screens[_Selectedindex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _Selectedindex,
        backgroundColor: Colors.blueGrey,
        onDestinationSelected: _tapped,
        destinations: const[
          NavigationDestination(
            icon: Icon(Icons.map, color: Colors.black),
            label: "MAP",
          ),
          NavigationDestination(
              icon: Icon(Icons.place),
              label: "LANDMARKS"
          ),
          NavigationDestination(
              icon: Icon(Icons.history),
              label: "Activity"
          ),
          NavigationDestination(
              icon: Icon(Icons.add_location_alt), label: "ADD/VIEW"
          ),
        ],
      ),

    );
  }
}
