//import 'dart:indexed_db';

import 'dart:ffi';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'newlogs.dart';
import 'dart:io';
import 'dart:convert';

class DataCrud {
  static late Database _db;
  static int nxtId = 0; // Initialize counter to avoid conflicts

  final String appDocumentsDir = Directory.current.path; //await getApplicationDocumentsDirectory();
  var databaseFactory;
  late Logger? vlog = Logger("datacrud",'./dbLog.csv');

 DataCrud() {
    // Initialize sqflite ffi database factory
    if (Platform.isLinux || Platform.isWindows){
      vlog?.addData("dbInfo", "Started Logging @:${appDocumentsDir}" + '/dbLog.csv');
      vlog?.writeLog();
      sqfliteFfiInit();
    }  
    databaseFactory = databaseFactoryFfi;
  }
  // Public method to initialize the database
  Future<dynamic> initDatabase() async {
    try {
//        vlog = Logger('datacrud', p.join(appDocumentsDir,'./dbLog.csv'));
        _db = await _initDatabase();
        _db.execute('CREATE TABLE IF NOT EXISTS infotab(id INTEGER AUTO_INCREMENT PRIMARY KEY, data TEXT)');
        vlog?.addData("initDb", "Successfully created table: infotab in ${_db.toString()}");
        vlog?.writeLog();
    } 
    catch (error, stackTrace) {
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
  //final dbPath = p.join(await getApplicationDocumentsDirectory(), './ddir/myDb.db');
  final dbPath = p.join(appDocumentsDir, './ddir/myDb.db');
    return databaseFactory.openDatabase(dbPath);
; // Return the opened database
}
 Future<void> insertRecord(String tabName, String data) async {
    int next_record_Id = await getNextId(tabName) ;
    next_record_Id = next_record_Id == 0 ? 1 : next_record_Id + 1 ;
    print("inserting into $tabName : got nextId:= $next_record_Id for ..");
    print("${data}");
  //   await _db.rawInsert(
  //  "INSERT INTO infotab (id,data) values (?,?)",
  //   ["${next_record_Id}", "${data}"],
  // );
}
  Future<List<Map<String, dynamic>>> getRecords() async {
    return await _db.query('infotab') ?? [] ;
  }

   Future<void> deleteRecord(int id) async {
    await _db.delete(
      'infotab',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> deleteAllRecords() async {
      await _db.delete('infotab');
  }
  static Future<int> getNextId(String tableName) async {
    final myDb = DataCrud._db;
    try {
      final result = await myDb.rawQuery("SELECT count(id) as mxcount FROM $tableName");
      print("Result type: ${result.runtimeType}, result=${result.toString()}");
      if (result.isNotEmpty) {
        print("Got some values from database : ${result[0]}");
        print(jsonEncode("${result[0]}"));
        final int? maxId = result[0]['mxcount'] as int?;
        return (maxId ?? 1) ; // Return 1 if maxId is null (empty table)
      } else {
        return 1; // Start with ID 1 if the table is empty
      }
    } catch (e) {
      print("Error while retrieving max ID: $e");
      rethrow; // Rethrow the error for proper handling
    }
  } 
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
    //return {'Person-$id': info}; // Always use "Person-$id" for unique key
  }
}
void main() async{
  List<Person> pList = [];
    pList.add(Person.fromJson({"info":{"Name":"Paul Dunkirk", "City":"Bangalore","Age": 45}}));
//  pList.add(Person.fromJson({"info":{"Name":"Brad Simcox", "City":"Ontaria", "Age": 23}}));
//  pList.add(Person.fromJson({"info":{"Name":"Manoj Damodar" "Pauline", "City":"Gwalior", "Age":34}}));
  pList.add(Person.fromJson({"info":{"Name":"Rebecca Pauline", "City":"Nevada", "Age": 32}}));
  try {
    final dataCrud = DataCrud();
    Database dd= await dataCrud.initDatabase();
    // Insert or replace the record in the database
    //pList.forEach((p) => dataCrud.insertRecord('infotab',p.info.toString()));
    print("Data saved to SQLite database");
    print("Now read-back data from SQLite database");

    List<Map<String, dynamic>> pL = await dataCrud.getRecords();
    if (pL != Null) {
      pL.forEach((p) {
        //print (p.toString());
          final id = p?['id'];
          final data = jsonDecode(p['data']);
         print("Data for person: $id...");
         print("\tName: ${data['Name']}");
         print("\tCity: ${data['City']}");
         print("\tAge: ${data['Age']}");
      });
    }
  }catch(err){
    print('Database errors: ${err}');
  }


}