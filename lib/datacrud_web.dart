import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'sharedlog.dart';
//import 'newlogs.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
//import 'package:sqflite/sqflite.dart';

class DataCrud {
  static late Database _db;
  static int nxtId = 0; // Initialize counter to avoid conflicts
  var databaseFactory;
  late Logger? vlog = Logger("datacrud", 'dbLog.csv');

  DataCrud() {
    // Initialize sqflite ffi database factory
    if (kIsWeb) {
      // Change default factory on the web
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Getter method to access the database instance (_db)
  Database get db {
    return _db; // Return the _db instance
  }

  // Public method to initialize the database
  Future<dynamic> initDatabase() async {
    try {
      _db = await _initDatabase();
      await _db.execute('CREATE TABLE IF NOT EXISTS infotab(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)');
      vlog?.addData("initDb", "Successfully created table: records in ${_db.toString()}");
      vlog?.writeLog();
    } catch (error, stackTrace) {
      vlog?.addData('dbErrors:', jsonEncode({
        "data": {
          "db_name": _db.toString(),
          "_initDB": error.toString(),
          "Errors": stackTrace.toString(),
        }
      }));
      vlog?.writeLog();
      rethrow; // Rethrow the exception to signal failure
    }
  }

  Future<Database> _initDatabase() async {
    return await databaseFactory.openDatabase('camp.db'); // Simplified path for web
  }

  /// Dynamic insertRecord method that allows overriding in calling modules
  Future<void> insertRecord(String tableName, dynamic data) async {
    if (tableName.toLowerCase() != 'infotab') {
      await insertRecordOverride(_db, tableName);
      return;
    }
    int nextRecordId = await getNextId(tableName);
    await _db.rawInsert(
      "INSERT INTO $tableName (id, data) VALUES (?, ?)",
      [nextRecordId, jsonEncode(data)], // Encode data as JSON
    );
  }

  Future<List<Map<String, dynamic>>> getRecords(String tabName) async {
    return await _db.query('$tabName') ?? [];
  }

  Future<void> deleteRecord(String tabName, int id) async {
    await _db.delete(
      '$tabName',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllRecords(String tabName) async {
    await _db.delete('$tabName');
  }

  static Future<int> getNextId(String tableName) async {
    final myDb = DataCrud._db;
    final result = await myDb.rawQuery("SELECT count(id) as mxcount FROM $tableName");
    if (result.isNotEmpty) {
      final int? maxId = result[0]['mxcount'] as int?;
      return (maxId ?? 0) + 1; // Return 1 if maxId is null (empty table)
    } else {
      return 1; // Start with ID 1 if the table is empty
    }
  }

  // Overridable method for custom insertRecord logic in calling modules
  Future<void> insertRecordOverride(Database dbt, String tableName) async {
    throw UnimplementedError('insertRecordOverride is not implemented in DataCrud');
  }

  execute(String s, List list) {}
}

class Person {
  final int id;
  final Map<String, dynamic> info;
  Person({required this.info}) : id = 0 { // Use static counter for ID
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
    return {'data': info}; // Return only the 'data' part
  }
}

void main() async {
  List<Person> pList = [];
  pList.add(Person.fromJson({"info": {"Name": "Paul Dunkirk", "City": "Bangalore", "Age": 45}}));
  pList.add(Person.fromJson({"info": {"Name": "Rebecca Pauline", "City": "Nevada", "Age": 32}}));

  try {
    final dataCrud = DataCrud();
    await dataCrud.initDatabase();
    for (var p in pList) {
      await dataCrud.insertRecord('infotab', p.info);
    }
    print("Data saved to SQLite database");
    print("Now read-back data from SQLite database");
    List<Map<String, dynamic>> pL = await dataCrud.getRecords('infotab');
    if (pL.isNotEmpty) {
      for (var p in pL) {
        final id = p['id'];
        final data = jsonDecode(p['data']);
        print("Data for person: $id...");
        print("\tName: ${data['Name']}");
        print("\tCity: ${data['City']}");
        print("\tAge: ${data['Age']}");
      }
    }
  } catch (err) {
    print('Database errors: $err');
  }
}
