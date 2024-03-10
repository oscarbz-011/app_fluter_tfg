import 'package:app_flutter/src/report/Report.dart';
import 'package:app_flutter/src/news/news.dart';
import 'package:app_flutter/src/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/src/map/map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrashTrack App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 39, 71)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Bienvenido a TrashTrack App!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrashTrack App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 39, 71)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuView(),
        '/map': (context) => const MapWidget(),
        '/news': (context) => const NewsWidget(),
        '/report': (context) => const Report(),
      },
      //home:
    );
    }
}

