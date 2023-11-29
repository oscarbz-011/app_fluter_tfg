import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsWidget extends StatefulWidget {
  const NewsWidget({super.key});

  @override
  State<NewsWidget> createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  @override
  void initState() {
    fetchNews();
    super.initState();
  }
  // Future<List<dynamic>> getNews() async {
  List<dynamic> news = [];

  void fetchNews() async {
    //const url = 'http://192.168.100.98:8000/api/news';
    const url = 'http://192.168.0.51:8000/api/news';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    setState(() {
    news = json;
    print(news);
    
  });
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
      ),
      body: ListView.builder(
        itemCount: news.length,
        itemBuilder: (context, index) {
          // return ListTile(
          //   leading: CircleAvatar(
          //     //backgroundImage: NetworkImage(news[index]['picture']['thumbnail']),
          //     child: Text('${index + 1}'),
          //   ),
          //   title: Text(news[index]['title']),
          //   subtitle: Text(news[index]['description']),
          // );
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(15),
            elevation: 10,
            child: Column(
              children: <Widget>[
                Image(
                  image: NetworkImage(news[index]['picture']),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(news[index]['title']),
                ),
              ],
            ),
          );
        },
      )
    );
  }
}