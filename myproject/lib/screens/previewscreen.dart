import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:myproject/components/person_card.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    Singleton singleton = Singleton();
    return Scaffold(
      body: Column(
        children: [
          Image.file(File(imagePath)),
          Expanded(
              child: ListView.builder(
            // TODO: potentially change initial scroll amount
            itemCount: singleton.persons.length,
            itemBuilder: (context, index) {
              return PersonCard(
                name: singleton.persons[index].name,
                description: singleton.persons[index].description,
                imagePath: singleton.persons[index].imagePath,
                onTap: () {
                  print("Tapped on person card");
                  singleton.updatePersonImage(imagePath, singleton.persons[index].name);
                },
              );
            },
          ))
        ],
      ),
    );
  }
}
