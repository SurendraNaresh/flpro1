import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Person {
  final int id;
  final String name;
  final String city;
  final int age;

  Person(this.name, this.city, this.age) : id = 0; // Assuming auto-increment

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city': city,
      'age': age,
    };
  }

  static Person fromMap(Map<String, dynamic> map) {
    return Person(
      map['name'] as String,
      map['city'] as String,
      map['age'] as int,
    );
  }
}

class DataCrud {
  Database? _db;

  Future<void> initDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'ddir/persons.db');
    _db = await openDatabase(
      dbPath,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS Persons (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, city TEXT, age INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> insert(Person person) async {
    await _db?.insert('Persons', person.toMap());
  }

  Future<List<Person>> queryAllPersons() async {
    final result = await _db?.query('Persons');
    return result?.map((map) => Person.fromMap(map)).toList() ?? [];
  }

  Future<void> close() async => await _db?.close();
}
