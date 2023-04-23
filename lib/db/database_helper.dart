import 'package:mylibrary/db/entity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'book_database.db';
  static const _databaseVersion = 1;

  static const table = 'books';

  static const columnId = 'id';
  static const columnBookName = 'bookName';
  static const columnAuthorName = 'authorName';
  static const columnImagePath = 'imagePath';

  static Database? _database;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, _databaseName);

    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
         $columnId INTEGER PRIMARY KEY,
        $columnBookName TEXT NOT NULL,
        $columnAuthorName TEXT NOT NULL,
        $columnImagePath TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert(table, book.toMap());
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final result = await db.query(table);

    return result.map((book) => Book.fromMap(book)).toList();
  }

  Future<void> deleteBook(int id) async {
    final db = await database;
    await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
