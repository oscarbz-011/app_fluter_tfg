import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_flutter/src/news_details/details.dart';

class NewsWidget extends StatefulWidget {
  const NewsWidget({Key? key}) : super(key: key);

  @override
  State<NewsWidget> createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  late StreamController<List<dynamic>> _newsStreamController;
  late Stream<List<dynamic>> newsStream;

  @override
  void initState() {
    super.initState();
    _newsStreamController = StreamController<List<dynamic>>();
    newsStream = _newsStreamController.stream;
    fetchNews();
  }

  void fetchNews() async {
    // Mantén un bucle infinito para actualizar las noticias continuamente
    while (true) {
      await Future.delayed(Duration(seconds: 10));

      try {
        String api_url = "http://192.168.100.123:8000/api/";
        final response = await http.get(Uri.parse(api_url + 'news'));
        final body = response.body;
        final json = jsonDecode(body);
        _newsStreamController.add(json); // Emitir los datos al Stream
      } catch (e) {
        // Manejar cualquier error que ocurra al buscar las noticias
        print('Error al obtener noticias: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: newsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<dynamic> news = snapshot.data ?? [];
            return ListView.builder(
              reverse: true,
              itemCount: news.length,
              itemBuilder: (context, index) {
                return postCard(news, index);
              },
            );
          }
        },
      ),
    );
  }

  Widget postCard(List<dynamic> news, int index) {
    // Tu código para construir la tarjeta de noticias
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details(
              title: news[index]['title'],
              description: news[index]['description'],
              image: news[index]['picture'],
              date: news[index]['created_at'],
            ),
          ),
        );
        print(news[index]);
      },
      child: Container(
        // Tarjeta de noticias
        height: 136,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news[index]['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                    /*"${news[index]['created_by']} · */ "${news[index]['created_at']}",
                    style: Theme.of(context).textTheme.bodyText1),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icons.bookmark_border_rounded,
                    Icons.share,
                    Icons.more_vert
                  ].map((e) {
                    return InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(e, size: 16),
                      ),
                    );
                  }).toList(),
                )
              ],
            )),
            Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(news[index]['picture']),
                    ))),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newsStreamController
        .close(); // Cerrar el controlador de Stream cuando se destruye el Widget
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: NewsWidget(),
  ));
}
