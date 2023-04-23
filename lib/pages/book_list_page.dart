import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:mylibrary/db/database_helper.dart';
import 'package:mylibrary/db/entity.dart';
import 'package:mylibrary/pages/book_preview.dart';
import 'package:path_provider/path_provider.dart';

import '../db/backup_manager.dart';

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

    Future<void> _backup() async {
      final database = await DatabaseHelper.instance.database;

      if (!await FlutterFileDialog.isPickDirectorySupported()) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup is not supported.')));
        return;
      }

      final pickedDirectory = await FlutterFileDialog.pickDirectory();
      if (pickedDirectory != null) {
        final backupManager = BackupManager(database, pickedDirectory);
        await backupManager.backup();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Backup completed.')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book List'),
        actions: [
          IconButton(
            onPressed: _backup,
            icon: const Icon(Icons.backup),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return ListTile(
            leading: FutureBuilder<Uint8List>(
              future: book.loadImageBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return Image.memory(snapshot.data!);
                } else {
                  return const Icon(Icons.image);
                }
              },
            ),
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
