import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:mylibrary/db/entity.dart';
import 'package:sqflite/sqflite.dart';

class BackupManager {
  final Database _database;
  final DirectoryLocation pickedDirectory;

  BackupManager(this._database, this.pickedDirectory);

  Future<void> backup() async {
    final workbook = Excel.createExcel();
    final worksheet = workbook['Books'];

    final books = await _database.rawQuery('SELECT * FROM books');

    for (var j = 0; j < Book.propsString().length; j++) {
      worksheet
          .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 0))
          .value = Book.propsString()[j];
    }

    for (var i = 0; i < books.length; i++) {
      final book = Book.fromMap(books[i]);

      final imageBytes = await book.loadImageBytes();
      // final imagePath = path.join(_backupFolder, '${book.id}.jpg');
      // final imageFile = File(imagePath);
      // await imageFile.writeAsBytes(imageBytes);

      final filePath = await FlutterFileDialog.saveFileToDirectory(
        directory: pickedDirectory,
        data: imageBytes,
        mimeType: "image/jpeg",
        fileName: "${book.bookFileName}",
        replace: true,
      );

      for (var j = 0; j < book.props.length; j++) {
        worksheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value = book.props[j];
      }
    }

    final fileBytes = workbook.save();

    if (fileBytes != null) {
      final filePath = await FlutterFileDialog.saveFileToDirectory(
        directory: pickedDirectory,
        data: Uint8List.fromList(fileBytes),
        mimeType:
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        fileName: "${DateTime.now().toIso8601String()}.xlsx",
        replace: true,
      );

      print('Backup file saved to ${filePath}');
    }
  }
}
