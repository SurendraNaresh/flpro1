import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DataCrud {
  late Database _db;
  DataCrud() {
    // Initialize sqflite ffi database factory
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Public method to initialize the database
  Future<void> initDatabase() async {
    _db = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), './ddir/camp.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY, data TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertRecord(String password) async {
    await _db.insert(
      'records',
      {'data': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRecords() async {
    return await _db.query('records');
  }

  Future<void> deleteRecord(int id) async {
    await _db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllRecords() async {
    await _db.delete('records');
  }
}
