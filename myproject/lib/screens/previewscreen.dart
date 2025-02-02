import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:myproject/components/person_card.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/services/messenger.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  @override
  Widget build(BuildContext context) {
    Singleton singleton = Singleton();
    return Scaffold(
      body: Column(
        children: [
          Image.file(File(widget.imagePath)),
          Expanded(
              child: ListView.builder(
            // TODO: potentially change initial scroll amount
            itemCount: singleton.persons.length,
            itemBuilder: (context, index) {
              return PersonCard(
                name: singleton.persons[index].name,
                description: singleton.persons[index].description,
                imagePath: singleton.persons[index].imagePath,
                uid: singleton.persons[index].uid,
                type: "teacher",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ProfilePopup(
                          image: File(widget.imagePath),
                          imagePath: singleton.persons[index].imagePath,
                          index: index,
                            onTap: () {
                            Navigator.of(context).pop();
                            setState(() {});
                            },
                          );
                    },
                  );
                },
              );
            },
          ))
        ],
      ),
    );
  }
}

class ProfilePopup extends StatelessWidget {
  const ProfilePopup({super.key, required this.image, required this.imagePath, required this.index, this.onTap});
  final File image;
  final String imagePath;
  final int index;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    Singleton singleton = Singleton();

    return AlertDialog(
      title: Text("Change profile or status?"),
      content: SizedBox(
        height: SizeConfig.blockSizeVertical! * 12,
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  print("Tapped on person card");
                  singleton.updatePersonImage(
                      imagePath, singleton.persons[index].name);
                  onTap!();
                },
                child: Text("Change profile")),
            ElevatedButton(onPressed: () async {
              await sendImage(image).then((value) {
                print(value);
              });
            }, child: Text("Change status"))
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close"),
        )
      ],
    );
  }
}
