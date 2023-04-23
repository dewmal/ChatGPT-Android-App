import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mylibrary/db/database_helper.dart';
import 'package:mylibrary/db/entity.dart';
import 'package:mylibrary/pages/book_preview.dart';
import 'package:path_provider/path_provider.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({Key? key}) : super(key: key);

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late List<Book> _books;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await DatabaseHelper.instance.getAllBooks();
    setState(() {
      _books = books;
    });
  }

  Future<void> _deleteBook(int id) async {
    final book = _books.firstWhere((book) => book.id == id);
    final imagePath = book.imagePath;
    final appDir = await getApplicationDocumentsDirectory();
    final imageFile = File('$appDir/$imagePath');

    await imageFile.delete();
    await DatabaseHelper.instance.deleteBook(id);

    setState(() {
      _books.removeWhere((book) => book.id == id);
    });
  }

  Future<void> _showImagePreview(Book book) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookPreviewPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_books.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Book List'),
        ),
        body: const Center(
          child: Text('No books found.'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book List'),
      ),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return ListTile(
            leading: Image.file(File(book.imagePath)),
            title: Text(book.bookName),
            subtitle: Text(book.authorName),
            onTap: () => _showImagePreview(book),
            trailing: IconButton(
              onPressed: () => _deleteBook(book.id!),
              icon: const Icon(Icons.delete),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
