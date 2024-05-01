import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'newlogs.dart';
import 'dart:io';
import 'dart:convert';

class DataCrud {
  late Database _db;
  final String appDocumentsDir = Directory.current.path; //await getApplicationDocumentsDirectory();
  var databaseFactory;
  late Logger? vlog = Logger('datacrud', p.join(appDocumentsDir,'dbLog.csv'));
 
 DataCrud() {
    // Initialize sqflite ffi database factory
    if (Platform.isLinux || Platform.isWindows){
      sqfliteFfiInit();
    }  
    databaseFactory = databaseFactoryFfi;
  }
  // Public method to initialize the database
  // Public method to initialize the database
  Future<dynamic> initDatabase() async {
    _db = await _initDatabase();
  }
  Future<Database> _initDatabase() async {
//  final dbPath = p.join(await getApplicationDocumentsDirectory(), './ddir/myDb.db');
  final dbPath = p.join(appDocumentsDir, './ddir/myDb.db');
    try {
      final db = await databaseFactory.openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) => db.execute(
          'CREATE TABLE IF NOT EXISTS records(id INTEGER AUTOINCREMENT PRIMARY KEY, info TEXT)'),
    );
    return db; // Return the opened database
  } catch (error, stackTrace) {
    vlog?.addData('dbErrors:', jsonEncode({
      "data": {
        "db_name": dbPath,
        "_initDB": error.toString(),
        "Errors": stackTrace.toString(),
      }
    }));
    vlog?.writeLog();
    rethrow; // Rethrow the exception to signal failure
  }
}
//   Future<dynamic> _initDatabase() async {
//     return await databaseFactory.openDatabase(
//       p.join(await appDocumentsDir, './ddir/myDb.db')
//         ..then(
//           (db) {
//               db.execute('CREATE TABLE records(id INTEGER AUTOINCREMENT, PRIMARY KEY, info TEXT)',);
//            }
//         )
//         ..onError((error, stackTrace) {
//                vlog?.addData('dbErrors:': jsonEncode({"data":
//                "db_name": ${db.toString()},
//                "_initDB": ${error},
//                "Errors":${stackTrace},
//                }));
//                vlog.writeLog();
//          })
//       );
//  }
  Future<void> insertRecord(String data) async {
    await _db.insert(
      'records',
      {'data': data},
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
class Person {
  final int id;
  final Map<String, dynamic> info;
  Person({required this.info}) : id = nextId++ { // Use static counter for ID
    if (info.isEmpty) {
      throw ArgumentError('Person info cannot be empty.');
    }
  }
  static int nextId = 1; // Initialize counter to avoid conflicts
  factory Person.fromJson(Map<String, dynamic>? json) {
    final info = json?['info'] as Map<String, dynamic>?;
    if (info != null) {
      return Person(info: info);
    } else {
      throw Exception('Missing or invalid "info" field in JSON data');
    }
  }
  Map<String, dynamic> toMap() {
    return {'Person-$id': info}; // Always use "Person-$id" for unique key
  }
}
void main() async{
  
  final p1 = Person.fromJson({"info":{"Name":"Anita", "City":"Madrid","Age": 36}});
  final p2 = Person.fromJson({"info":{"Name":"Chad", "City":"Nairobi", "Age": 43}});
  try {
	  final dataCrud = DataCrud();
	  await dataCrud.initDatabase();
    // Insert or replace the record in the database
    await dataCrud.insertRecord(jsonEncode(p1.toMap()));
    await dataCrud.insertRecord(jsonEncode(p2.toMap()));
	  print("Data saved to SQLite database");

  }catch(err){
    print('Database errors: ${err}');
  }

}