import 'package:mylibrary/db/entity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'book_database.db';
  static const _databaseVersion = 1;

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
      CREATE TABLE ${Book.table} (
         ${Book.columnId} INTEGER PRIMARY KEY,
        ${Book.columnBookName} TEXT NOT NULL,
        ${Book.columnAuthorName} TEXT NOT NULL,
        ${Book.columnImagePath} TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert(Book.table, book.toMap());
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final result = await db.query(Book.table);

    return result.map((book) => Book.fromMap(book)).toList();
  }

  Future<void> deleteBook(int id) async {
    final db = await database;
    await db.delete(Book.table, where: '${Book.columnId} = ?', whereArgs: [id]);
  }
}
