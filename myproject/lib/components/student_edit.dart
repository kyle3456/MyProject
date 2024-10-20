import 'package:flutter/material.dart';
import 'package:myproject/services/database.dart';
import 'package:myproject/components/person_card.dart';

class StudentEdit extends StatefulWidget {
  const StudentEdit({super.key});

  @override
  State<StudentEdit> createState() => _StudentEditState();
}

class _StudentEditState extends State<StudentEdit> {
  final TextEditingController _nameController = TextEditingController();
  List<dynamic> students = [];
  List<PersonCard> studentCards = [];

  @override
  void initState() {
    super.initState();
    DatabaseService().getListOfStudentsFromAdmin().then((value) {
      setState(() {
        students = value;

        // Create a list of PersonCard widgets
        studentCards = students.map((student) {
          print("STUDENT: $student");
          return PersonCard(
            name: student['name'],
            description: student['email'],
            imagePath: "assets/Pfp.jpg",
          );
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Search'),
            ),
            ListView(
              shrinkWrap: true,
              children: studentCards,
            ),
            
          ],)));
  }
}