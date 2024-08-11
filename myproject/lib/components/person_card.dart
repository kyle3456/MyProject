import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:provider/provider.dart';

class PersonCard extends StatefulWidget {
  PersonCard(
      {super.key,
      required this.name,
      required this.description,
      required this.imagePath,
      this.onTap});

  final String name;
  final String description;
  String imagePath;
  final Function? onTap;

  @override
  State<PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {

  String status = "";

  @override
  Widget build(BuildContext context) {
    Singleton singleton = Singleton();
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal! * 80,
      height: SizeConfig.blockSizeVertical! * 15,
      child: Card(
          color: Colors.blue,
          child: InkWell(
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!();
              }
            },
            onDoubleTap: () {
              print("double tapped!");

              setState(() {
                status = "Sending to server";
                            });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<Singleton>(
                builder: (context, singleton, child) {
                  final index = singleton.persons
                      .indexWhere((element) => element.name == widget.name);

                  if (index != -1) {
                    widget.imagePath = singleton.persons[index].imagePath;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TODO: upon tap, make the text elements editable
                            Text(widget.name,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white)),
                            Text(
                              widget.description,
                              maxLines: 3,
                            ),
                            Text(status,
                                style: const TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey,
                          child: (singleton.savedImagePath == '')
                              ? Image.asset(widget.imagePath)
                              : Image.file(File(singleton.savedImagePath)),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          )),
    );
  }
}
