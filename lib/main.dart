import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livros',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BookListScreen(),
    );
  }
}

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> books = [];
  TextEditingController urlController = TextEditingController(text: 'https://kfq5lol2ci.execute-api.us-east-1.amazonaws.com/dev/livros');

  @override
  void initState() {
    super.initState();
    fetchBooks(urlController.text);
  }

  Future<void> fetchBooks(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          books = jsonResponse.map((book) => Book.fromJson(book)).toList();
          print(books);
        });
      } else {
        throw Exception('Falhou: ' + response.statusCode.toString());
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Falha, tente novamente mais tarde",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
      print (e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App de livros')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              decoration: InputDecoration(labelText: 'Backend URL'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                fetchBooks(urlController.text);
              },
              child: Text('Buscar livros'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(books[index].titulo),
                    subtitle: Text('Autor: ${books[index].autor} | Edição: ${books[index].edicao}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Book {
  final String id;
  final String titulo;
  final String autor;
  final String edicao;

  Book({required this.id, required this.titulo, required this.autor, required this.edicao});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['LivroID'],
      titulo: json['titulo'],
      autor: json['autor'],
      edicao: json['edicao'],
    );
  }
}
