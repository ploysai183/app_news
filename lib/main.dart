import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        
      ),
      home: const HomeScreen(),
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _newsService = NewsService();
  late Future<List<dynamic>> _newsData;

  @override
  void initState() {
    super.initState();
    _newsData = _newsService.fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News App',
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _newsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load news'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var article = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      title: Text(
                        article['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        article['description'] ?? 'No Description',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class NewsService {
  final String _apiKey = '67aca3e32fae475192c291a6c2d1af28';
  final String _baseUrl = 'https://newsapi.org/v2/everything?q=tesla&from=2024-07-14&sortBy=publishedAt&apiKey=';

  Future<List<dynamic>> fetchNews() async {
    final response = await http.get(Uri.parse(_baseUrl + _apiKey));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['articles'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}