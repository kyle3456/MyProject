import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myproject/services/database.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/components/person_card.dart';
import 'package:myproject/components/NavBar.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:myproject/services/locations.dart' as locations;
import 'package:provider/provider.dart';

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
  final Singleton singleton = Singleton();
  final Map<String, Marker> _markers = {};
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

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  Future<void> getNotifications() async {
    // check account type
    if (singleton.userData["type"] == 'admin') {
      // get all notifications
      // return all notifications
    } else if (singleton.userData["type"] == 'teacher') {
      // get notifications for the user
      // return notifications for the user
    } else if (singleton.userData["type"] == 'student') {
      // get notifications for the user
      // return notifications for the user
    } else if (singleton.userData["type"] == 'police') {
      // get notifications for the user
      // return notifications for the user
      
    }
  }

  @override
  void initState() {
    super.initState();
    DatabaseService().getListOfStudentsFromTeacher().then((value) {
      setState(() {
        singleton.persons = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Singleton singleton = Singleton();
    String accountType = singleton.userData["type"];

    print(singleton.userData);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.email),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                NotificationCard(message: "You have a message", enableActions: true,),
                // ListTile(
                //   title: const Text('Settings'),
                //   onTap: () {
                //   },
                // ),
                // ListTile(
                //   title: const Text('Logout'),
                //   onTap: () {
                //   },
                // ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    (accountType == 'admin')
                        ? "Teachers"
                        : (accountType == 'teacher')
                            ? "Your Students"
                            : "People",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
                              description: singleton.persons[index].description,
                              imagePath: singleton.persons[index].imagePath,
                              uid: singleton.persons[index].uid,
                            );
                          },
                        )),
                  ),
                  (singleton.userData["type"] != 'admin')
                      ? Consumer<Singleton>(
                          builder: (context, singleton, child) {
                            return SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 80,
                                height: SizeConfig.blockSizeHorizontal! * 80,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (singleton.userData['status'] ==
                                                'normal')
                                            ? Color.fromARGB(255, 175, 76, 76)
                                            : Color.fromARGB(255, 76, 175, 79),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(250),
                                    ),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.heavyImpact();
                                    setState(() {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const ReportPopup();
                                        },
                                      );
                                    });
                                  },
                                  child: Text(
                                    // TODO: the student card occasionally disappear for some reason
                                    (singleton.userData['status'] == 'normal')
                                        ? 'REPORT DANGER'
                                        : 'ALL CLEAR',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                  ),
                                )
                                // child: GoogleMap(
                                //   mapType: MapType.satellite,
                                //   initialCameraPosition: _kGooglePlex,
                                //   // onMapCreated: (GoogleMapController controller) {
                                //   //   _controller.complete(controller);
                                //   // },
                                //   onMapCreated: _onMapCreated,
                                //   markers: _markers.values.toSet(),
                                // ),
                                );
                          },
                        )
                      : Column(
                          children: [
                            const Text(
                              'Students',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              // color: Colors.red,
                              width: SizeConfig.blockSizeHorizontal! * 85,
                              height: SizeConfig.blockSizeVertical! * 40,
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListView.builder(
                                    itemCount: singleton.students.length,
                                    itemBuilder: (context, index) {
                                      return PersonCard(
                                        name: singleton.students[index].name,
                                        description: singleton
                                            .students[index].description,
                                        imagePath:
                                            singleton.students[index].imagePath,
                                        uid: singleton.students[index].uid,
                                      );
                                    },
                                  )),
                            ),
                          ],
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

class ReportPopup extends StatelessWidget {
  const ReportPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Handle report submission

            DatabaseService().markSOS();

            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class NotificationCard extends StatefulWidget {
  const NotificationCard(
      {super.key, required this.message, this.enableActions = false, this.onDeny, this.onConfirm});
  final String message;
  final bool enableActions;
  final Function? onDeny;
  final Function? onConfirm;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.blockSizeVertical! * 14,
      child: Card(
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(widget.message),
              (widget.enableActions) ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (widget.onDeny != null) {
                          widget.onDeny!();
                        }
                      },
                      child: const Text(
                        "Deny",
                        style: TextStyle(color: Colors.red),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        if (widget.onConfirm != null) {
                          widget.onConfirm!();
                        }
                      },
                      child: const Text(
                        "Confirm",
                        style: TextStyle(color: Colors.black),
                      )),
                ],
              ) : Container()
            ],
          ),
        ),
      ),
    );
  }
}
