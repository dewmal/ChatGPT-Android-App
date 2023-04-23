import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mylibrary/db/database_helper.dart';
import 'package:mylibrary/db/entity.dart';
import 'package:mylibrary/pages/book_list_page.dart';
import 'package:path_provider/path_provider.dart';

class ImagePreview extends StatefulWidget {
  final String imagePath;

  ImagePreview({required this.imagePath});

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final _formKey = GlobalKey<FormState>();
  final _bookNameController = TextEditingController();
  final _authorNameController = TextEditingController();

  void _saveImage() async {
    final bookName = _bookNameController.text;
    final authorName = _authorNameController.text;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final appDir = await getApplicationDocumentsDirectory();
    final savedImage =
        await File(widget.imagePath).copy('${appDir.path}/$fileName');
    final savedImagePath = savedImage.path;

    final book = Book(
      id: null,
      bookName: bookName,
      authorName: authorName,
      imagePath: savedImagePath,
    );

    await DatabaseHelper.instance.insertBook(book);

    Navigator.of(context).pop();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const BookListPage()));
  }

  // void _saveImage() {
  //   final bookName = _bookNameController.text;
  //   final authorName = _authorNameController.text;
  //   // TODO: Save the image and book/author details
  //   Navigator.of(context).pop();
  // }

  @override
  void dispose() {
    _bookNameController.dispose();
    _authorNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.file(File(widget.imagePath)),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _bookNameController,
                decoration: const InputDecoration(
                  labelText: 'Book Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the book name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _authorNameController,
                decoration: const InputDecoration(
                  labelText: 'Author Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the author name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveImage();
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
