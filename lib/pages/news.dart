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
            // return ListTile(
            //   leading: CircleAvatar(
            //     //backgroundImage: NetworkImage(news[index]['picture']['thumbnail']),
            //     child: Text('${index + 1}'),
            //   ),
            //   title: Text(news[index]['title']),
            //   subtitle: Text(news[index]['description']),
            // );
            return postCard(news, index);
          },
        ),
      )
    );
  }
  Widget postCard(List<dynamic> news, int index) =>
    // Card(
            
    //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //           margin: EdgeInsets.all(15),
    //           elevation: 10,
    //           child: Column(
    //             children: <Widget>[
    //               Image(
    //                 image: NetworkImage(news[index]['picture']),
    //               ),
    //               Container(
    //                 padding: EdgeInsets.all(10),
    //                 child: Text(news[index]['title']),
    //               ),
                  
    //             ],
                
    //           ),
              
    // );
    Card(
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
    );
}