import 'package:flutter/material.dart';
import 'package:app_flutter/src/report/Report.dart';




class Details extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final String date;
  // final String source;
  // final String url;

  const Details({
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    // required this.source,
    // required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de la noticia'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(image),
                Text('$title', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('$description', style: TextStyle(fontSize: 16)),
                Text('Fecha: $date'),
                // Text('Source: $source'),
                // Text('URL: $url'),s
              ],
            ),
          ),
        ),
      ),
    );
  }
}
