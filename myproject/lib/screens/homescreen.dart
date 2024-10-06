import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/components/person_card.dart';
import 'package:myproject/components/NavBar.dart';
import 'package:myproject/shared/singleton.dart';
// import 'package:google_maps/google_maps.dart' as gmaps;

// class Person {
//   final String name;
//   final String description;
//   final String imagePath;

//   Person(
//       {required this.name, required this.description, required this.imagePath});
// }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List<Person> persons = [
  //   Person(
  //       name: 'John Doe',
  //       description: "John Doe is a software engineer",
  //       imagePath: 'assets/Profile Picture.png'),
  //   Person(
  //       name: 'Jane Doe',
  //       description: "John Doe is a software engineer",
  //       imagePath: 'assets/Profile Picture.png'),
  //   Person(
  //       name: 'Kyle',
  //       description: "John Doe is a software engineer",
  //       imagePath: 'assets/Profile Picture.png'),
  //   Person(
  //       name: 'Jane Doe',
  //       description: "John Doe is a software engineer",
  //       imagePath: 'assets/Profile Picture.png'),
  // ];

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    Singleton singleton = Singleton();
    print(singleton.userData);
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
                          itemCount: singleton.persons.length,
                          itemBuilder: (context, index) {
                            return PersonCard(
                                name: singleton.persons[index].name,
                                description:
                                    singleton.persons[index].description,
                                imagePath: singleton.persons[index].imagePath);
                          },
                        )),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 80,
                    height: SizeConfig.blockSizeVertical! * 55,
                    // child: GoogleMap(
                    //   mapType: MapType.satellite,
                    //   initialCameraPosition: _kGooglePlex,
                    //   onMapCreated: (GoogleMapController controller) {
                    //     _controller.complete(controller);
                    //   },
                    // ),
                  ),
                  // Container(
                  //     width: SizeConfig.blockSizeHorizontal! * 80,
                  //     height: SizeConfig.blockSizeVertical! * 55,
                  //     color: const Color.fromARGB(255, 76, 175, 79),
                  //     child: Stack(
                  //       children: [
                  //         Positioned(
                  //             top: 10,
                  //             left: 0,
                  //             right: 0,
                  //             child: Container(
                  //               width: SizeConfig.blockSizeHorizontal! * 10,
                  //               height: SizeConfig.blockSizeHorizontal! * 10,
                  //               decoration: const BoxDecoration(
                  //                   color: Colors.white,
                  //                   shape: BoxShape.circle),
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(2.0),
                  //                 child:
                  //                     Image.asset('assets/Profile Picture.png'),
                  //               ),
                  //             ))
                  //       ],
                  //     ))
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavBar());
  }
}
