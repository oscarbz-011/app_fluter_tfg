import 'package:flutter/material.dart';





class Details extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final String date;
  // final String source;
  // final String url;

  const Details({super.key, 
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    // required this.source,
    // required this.url,
  });

  @override
  Widget build(BuildContext context) {
    
    
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de la noticia'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Image.network(image),
                  Text('$title', textAlign: TextAlign.justify, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14,),
                  Text('$description',textAlign: TextAlign.justify, style: const TextStyle(fontSize: 16,
                  )),
                  const SizedBox(height: 14,),
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
