import 'package:flutter/material.dart';

class StudentEdit extends StatefulWidget {
  const StudentEdit({super.key});

  @override
  State<StudentEdit> createState() => _StudentEditState();
}

class _StudentEditState extends State<StudentEdit> {
  TextEditingController _nameController = TextEditingController();


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
            
          ],)));
  }
}