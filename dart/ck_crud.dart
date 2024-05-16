//import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

//import 'crud_person.dart';

class Person {
  final int id;
  final String name;
  final String city;
  final int age;

  Person(this.id, this.name, this.city, this.age);

  // Optional: Convert Person to a Map for easier database interaction
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'age': age,
    };
  }

  // Optional: Construct a Person object from a Map (for reading from database)
  static Person fromMap(Map<String, dynamic> map) {
    return Person(
      map['name'] as String,
      map['city'] as String,
      map['age'] as int,
    );
  }
}

class DataCrud  {
  late Database _db;

  Future<void> initDatabase() async {
    // Initialize sqflite FFI database factory
    if (Platform.isLinux) {
        sqfliteFfiInit();
    }
    var databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, './ddir/people.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS Persons (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, city TEXT NOT NULL, age INTEGER NOT NULL)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertPerson(Person person) async {
    await _db.insert(
      'Persons',
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace existing record with same ID
    );
  }

  Future<List<Person>> getPeople() async {
    final List<Map<String, dynamic>> maps = await _db.query('Persons');
    return List.generate(maps.length, (i) => Person.fromMap(maps[i]));
  }
  
  //void sqfliteFfiInit() {}
}

void main() async {
  final dCr = DataCrud();
  //await dCr.initDatabase(); // Initialize database before usage
	
  try {
    final p1 = Person('Anita', 'Madrid', 36);
    final p2 = Person('Chad', 'Nairobi', 43);
    final p3 = Person('Jack', 'New-York', 45);

    await dCr.insertPerson(p1);
    await dCr.insertPerson(p2);
    await dCr.insertPerson(p3);

    final peopleList = await dCr.getPeople();
    for (final person in peopleList) {
      print('Name: ${person.name}, City: ${person.city}, Age: ${person.age}');
    }
  } catch (err) {
    print('Errors: $err');
  } finally {
    // Optional: Close the database connection if needed
    await _db.close();
  }
}
