// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:app_flutter/src/news_details/details.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class NewsWidget extends StatefulWidget {
//   const NewsWidget({super.key});

//   @override
//   State<NewsWidget> createState() => _NewsWidgetState();
// }

// class _NewsWidgetState extends State<NewsWidget> {
//   @override
//   void initState() {
//     fetchNews();
//     super.initState();
//   }

//   // Future<List<dynamic>> getNews() async {
//   List<dynamic> news = [];

//   void fetchNews() async {
//     //String api_url = dotenv.get('API_URL', fallback: "");
//     String api_url = "http://192.168.100.123:8000/api/";
//     // String url = api_url + 'news';
//     // final uri = Uri.parse(url);
//     final response = await http.get(Uri.parse(api_url + 'news'));
//     final body = response.body;
//     final json = jsonDecode(body);
//     setState(() {
//       news = json;
//       print(news);
//     });
//   }

//   /// Builds the news screen widget.
//   ///
//   /// This method returns a Scaffold widget that displays a list of news articles.
//   /// If the list of news is empty, a CircularProgressIndicator is shown in the center of the screen.
//   /// Otherwise, a ListView.builder is used to display each news article using the postCard widget.
//   ///
//   /// The context parameter is the build context.
//   /// The news parameter is the list of news articles.
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Noticias'),
//         ),
//         body: Container(
//           child: news.isEmpty
//               ? Container(
//                   alignment: Alignment.center,
//                   child: const CircularProgressIndicator(),
//                 )
//               : ListView.builder(
//                   scrollDirection: Axis.vertical,
//                   reverse: true,
//                   itemCount: news.length,
//                   itemBuilder: (context, index) {
//                     return postCard(news, index);
//                   },
//                 ),
//         ));
//   }

//   // Tarjeta de noticias
//   Widget postCard(List<dynamic> news, int index) => GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => Details(
//                 title: news[index]['title'],
//                 description: news[index]['description'],
//                 image: news[index]['picture'],
//                 date: news[index]['created_at'],
//                 // source: news[index]['source'],
//                 // url: news[index]['url'],
//               ),
//             ),
//           );
//           print(news[index]);
//         },
//         child: Card(
//             elevation: 10,
//             margin: EdgeInsets.all(14),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             child: Container(
//               width: 300,
//               padding: EdgeInsets.all(14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Column(
//                     children: <Widget>[
//                       SizedBox(
//                         height: 290,
//                         width: 100,
//                         child: Image.network(
//                           news[index]['picture'],
//                           fit: BoxFit.cover,
//                         )
//                       ),
//                       // Image.network(
//                       //   news[index]['picture'],
//                       //   width: 300,
//                       //   height: 100,
//                       // ),
//                       Text(
//                         news[index]['title'],
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             )),
//       );
// }
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
  late Stream<List<dynamic>> newsStream;

  @override
  void initState() {
    super.initState();
    newsStream = fetchNews();
  }

  Stream<List<dynamic>> fetchNews() async* {
    // Mantén un bucle infinito para actualizar las noticias continuamente
    while (true) {
      await Future.delayed(Duration(
          seconds: 10)); // Espera 10 segundos antes de buscar nuevas noticias

      try {
        String api_url = "http://192.168.100.123:8000/api/";
        final response = await http.get(Uri.parse(api_url + 'news'));
        final body = response.body;
        final json = jsonDecode(body);
        yield json; // Emitir la lista de noticias actualizada
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
                    /*"${news[index]['created_by']} · */"${news[index]['created_at']}",
                    style: Theme.of(context).textTheme.bodySmall),
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
}

void main() {
  runApp(MaterialApp(
    home: NewsWidget(),
  ));
}
