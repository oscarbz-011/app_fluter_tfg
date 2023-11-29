import 'package:app_flutter/pages/Report.dart';
import 'package:app_flutter/pages/news.dart';
import 'package:app_flutter/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/pages/map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
      title: 'Flutter Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 115, 74, 187)),
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

