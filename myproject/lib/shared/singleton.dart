import 'package:flutter/material.dart';

class Person {
  final String name;
  final String description;
  final String imagePath;
  final String uid;

  Person(
      {required this.name, required this.description, required this.imagePath, required this.uid});
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
        imagePath: 'assets/Pfp.jpg',
        uid: '1'),
    Person(
        name: 'Jane Doe',
        description: "John Doe is a software engineer",
        imagePath: 'assets/Pfp.jpg',
        uid: '2'),
    Person(
        name: 'Kyle',
        description: "John Doe is a software engineer",
        imagePath: 'assets/Pfp.jpg',
        uid: '3'),
    Person(
        name: 'Jane Doe',
        description: "John Doe is a software engineer",
        imagePath: 'assets/Pfp.jpg'
        ,uid: '4'),
  ];

  List<Person> students = [];
  
  List<Person> police = [];

  String savedImagePath = '';

  Map<String, dynamic> userData = {};

  void updatePersonImage(String imagePath, String name) {
    final index = persons.indexWhere((element) => element.name == name);
    persons[index] = Person(
        name: persons[index].name,
        description: persons[index].description,
        imagePath: imagePath,
        uid: persons[index].uid);
    notifyListeners();
  }

  void notify() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
