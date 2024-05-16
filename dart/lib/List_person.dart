import 'crud_person.dart';
void main() {
  final p1 = Person('Anita', 'Madrid', 36);
  final p2 = Person('Chad', 'Nairobi', 43);
  final p3 = Person('Jack', 'New-York', 45);

  final persons = [p1, p2, p3];

  for (final person in persons) {
    print('Name: ${person.name}, City: ${person.city}, Age: ${person.age}');
  }
}
