import 'package:flutter/material.dart';

class Person {
  final String name;
  final String description;
  final String imagePath;

  Person(
      {required this.name, required this.description, required this.imagePath});
}

class Singleton extends ChangeNotifier {
  static final Singleton _singleton = Singleton._internal();

  factory Singleton() {
    return _singleton;
  }

  Singleton._internal();

  List<Person> persons = [
    Person(
        name: 'John Doe',
        description: "John Doe is a software engineer",
        imagePath: 'assets/Profile Picture.png'),
    Person(
        name: 'Jane Doe',
        description: "John Doe is a software engineer",
        imagePath: 'assets/Profile Picture.png'),
    Person(
        name: 'Kyle',
        description: "John Doe is a software engineer",
        imagePath: 'assets/Profile Picture.png'),
    Person(
        name: 'Jane Doe',
        description: "John Doe is a software engineer",
        imagePath: 'assets/Profile Picture.png'),
  ];

  String savedImagePath = '';

  void updatePersonImage(String imagePath, String name) {
    final index = persons.indexWhere((element) => element.name == name);
    persons[index] = Person(
        name: persons[index].name,
        description: persons[index].description,
        imagePath: imagePath);
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}