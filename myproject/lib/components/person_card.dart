import 'package:flutter/material.dart';
import 'package:myproject/size_config.dart';

class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.name, required this.description, required this.imagePath});

  final String name;
  final String description;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 80,
              height: SizeConfig.blockSizeVertical! * 15,
              child: Card(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ // TODO: upon tap, make the text elements editable
                            Text(name, style:const TextStyle(fontSize: 20, color: Colors.white)),
                            Text(description,maxLines: 3,),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey,
                          child: Image.asset(imagePath),
                        ),
                      )
                    ],
                  ),
                )
              ),
            );
  }
}
