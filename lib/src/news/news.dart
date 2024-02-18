import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_flutter/src/news_details/details.dart';

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
    const url = 'http://192.168.100.123:8000/api/news';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    setState(() {
    news = json;
    print(news);
  });
   
  }


  /// Builds the news screen widget.
  ///
  /// This method returns a Scaffold widget that displays a list of news articles.
  /// If the list of news is empty, a CircularProgressIndicator is shown in the center of the screen.
  /// Otherwise, a ListView.builder is used to display each news article using the postCard widget.
  ///
  /// The context parameter is the build context.
  /// The news parameter is the list of news articles.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
      ),
      body: Container(
        child: news.isEmpty
          ? Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          )
          : ListView.builder( 
            scrollDirection: Axis.vertical,   
            reverse: true,
            itemCount: news.length,
            
            itemBuilder: (context, index) {
            return postCard(news, index);
          },
        ),
      )
    );
  }

  // Tarjeta de noticias
  Widget postCard(List<dynamic> news, int index) =>
    
    GestureDetector(
      onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Details(
                title: news[index]['title'],
                description: news[index]['description'],
                image: news[index]['picture'],
                // date: news[index]['date'],
                // source: news[index]['source'],
                // url: news[index]['url'],
              ),
            ),
          );
          print(news[index]);
        },
      child: Card(
        elevation: 10,
        margin: EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Image.network(news[index]['picture'], width: 100, height: 100,),
                  Text(news[index]['title'], 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    );
}