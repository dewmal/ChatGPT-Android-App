import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class Book {
  int? id;
  final String bookName;
  final String authorName;
  final String imagePath;

  Book({
    this.id,
    required this.bookName,
    required this.authorName,
    required this.imagePath,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      bookName: map['bookName'],
      authorName: map['authorName'],
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookName': bookName,
      'authorName': authorName,
      'imagePath': imagePath,
    };
  }

  Future<Uint8List> loadImageBytes() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageFile = File('${appDir.path}/$imagePath');
    return await imageFile.readAsBytes();
  }
}
