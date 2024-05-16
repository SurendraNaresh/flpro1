import 'package:flutter/material.dart';
import 'data_crud.dart'; // Assuming data_crud.dart remains the same

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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p1 = Person('Anita', 'Madrid', 36);
    final p2 = Person('Chad', 'Nairobi', 43);
    final p3 = Person('Jack', 'New-York', 45);

    final persons = [p1, p2, p3]; // List of pre-defined persons

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('People List'),
        ),
        body: ListView.builder(
          itemCount: persons.length,
          itemBuilder: (context, index) {
            final person = persons[index];
            return ListTile(
              title: Text('${person.name} - ${person.age}'),
              subtitle: Text(person.city),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle FAB action (optional: add new person)
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
