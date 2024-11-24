import 'package:flutter/material.dart';
import 'package:myproject/services/auth.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:myproject/services/database.dart';
import 'package:myproject/services/auth.dart';

class SchoolCreator extends StatefulWidget {
  const SchoolCreator({super.key});

  @override
  State<SchoolCreator> createState() => _SchoolCreatorState();
}

class _SchoolCreatorState extends State<SchoolCreator> {
  TextEditingController nameController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  Singleton singleton = Singleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '*Name'),
            ),
            TextField(
              controller: latitudeController,
              decoration: const InputDecoration(labelText: '*Latitude'),
            ),
            TextField(
              controller: longitudeController,
              decoration: const InputDecoration(labelText: '*Longitude'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    latitudeController.text.isEmpty ||
                    longitudeController.text.isEmpty) {
                  return;
                }

                DatabaseService().createSchool(
                  nameController.text,
                  Auth().user!.uid,
                  double.parse(latitudeController.text),
                  double.parse(longitudeController.text),

                );

                // clear the text fields
                nameController.clear();
                latitudeController.clear();
                longitudeController.clear();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
