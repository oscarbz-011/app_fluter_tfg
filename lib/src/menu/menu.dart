import 'package:app_flutter/src/report/Report.dart';
import 'package:app_flutter/src/news/news.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/src/map/map.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  @override
  void initState() {
    //supa.auth.signOut();
    super.initState();
  }
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          MapWidget(),
          NewsWidget(),
          Report(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
        NavigationDestination(
          icon: const Icon(Icons.map),
          label: 'Mapa',
        ),
        NavigationDestination(
          icon: const Icon(Icons.article),
          label: 'Noticias',
        ),
        NavigationDestination(
          icon: const Icon(Icons.report),
          label: 'Reportes',
        ),
      ]),
    );
  }
}