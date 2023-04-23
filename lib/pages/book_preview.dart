import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mylibrary/db/entity.dart';

class BookPreviewPage extends StatelessWidget {
  final Book book;

  const BookPreviewPage({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.bookName),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: BookImagePreview(book: book),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Book name: ${book.bookName}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Author name: ${book.authorName}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

class BookImagePreview extends StatefulWidget {
  final Book book;

  const BookImagePreview({Key? key, required this.book}) : super(key: key);

  @override
  _BookImagePreviewState createState() => _BookImagePreviewState();
}

class _BookImagePreviewState extends State<BookImagePreview> {
  late Future<Uint8List> _imageBytesFuture;

  @override
  void initState() {
    super.initState();
    _imageBytesFuture = widget.book.loadImageBytes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageBytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text('No data found.'),
          );
        } else {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
      },
    );
  }
}
