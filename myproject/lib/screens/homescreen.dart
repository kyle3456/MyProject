import 'package:flutter/material.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/components/person_card.dart';
import 'package:myproject/components/NavBar.dart';

class Person {
  final String name;
  final String description;
  final String imagePath;

  Person(
      {required this.name, required this.description, required this.imagePath});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    // color: Colors.red,
                    width: SizeConfig.blockSizeHorizontal! * 85,
                    height: SizeConfig.blockSizeVertical! * 40,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: persons.length,
                          itemBuilder: (context, index) {
                            return PersonCard(
                                name: persons[index].name,
                                description: persons[index].description,
                                imagePath: persons[index].imagePath);
                          },
                        )),
                  ),
                  Container(
                      width: SizeConfig.blockSizeHorizontal! * 80,
                      height: SizeConfig.blockSizeVertical! * 55,
                      color: const Color.fromARGB(255, 76, 175, 79),
                      child: Stack(
                        children: [
                          Positioned(
                              top: 10,
                              left: 0,
                              right: 0,
                              child: Container(
                                width: SizeConfig.blockSizeHorizontal! * 10,
                                height: SizeConfig.blockSizeHorizontal! * 10,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child:
                                      Image.asset('assets/Profile Picture.png'),
                                ),
                              ))
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavBar());
  }
}
