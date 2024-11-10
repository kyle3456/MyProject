import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myproject/components/NavBar.dart';
import 'package:myproject/services/database.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/services/locations.dart' as locations;
import 'package:myproject/shared/singleton.dart';

/*
33.61882, -117.82342  =3
33.619179, -117.822877 =5
33.618118 -117.821911 =2
33.618496 -117.823835 =1
33.619461 -117.822501 = 2
33.618062 -117.823057 =2
 */

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<String, Marker> _markers = {};
  final Singleton _singleton = Singleton();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.61806, -117.823),
    zoom: 18,
  );

  Future<void> getStudentLocations() async {
    if (_singleton.userData['type'] == 'teacher') {
      List<dynamic> students = _singleton.userData['students'];

      print("Teacher has ${students.length} students: $students");
      

      for (int i = 0; i < students.length; i++) {
        var student =
            await DatabaseService().getStudentLocation(students[i].toString());

        print("Student: $student");

        // convert firestore geopoint to latlng
        LatLng studentLocation =
            LatLng(student['location'].latitude, student['location'].longitude);

        final marker = Marker(
          markerId: MarkerId(
              (student.containsKey('name')) ? student['name'] : 'Student'),
          position: studentLocation,
          infoWindow: InfoWindow(
            title: (student.containsKey('name')) ? student['name'] : 'Student',
            snippet: student['status'],
          ),
        );
        _markers[student['uid']] =
            marker;
      }

      adjustMarkers(0.001);
    }
  }

  // adjust markers to account for clumps of markers within a given radius of each other
  void adjustMarkers(double radius) {
    // iterate through all the keys in marker

    // deep copy of markers
    Map<String, Marker> newMarkers = Map<String, Marker>.from(_markers);

    int clumpCount = 0;

    for (var key in _markers.keys) {
      // iterate through all the keys in marker
      int neighborCount = 0;
      for (var otherKey in _markers.keys) {
        if (key != otherKey) {
          // get the distance between the two markers
          double distance = calculateDistance(
              _markers[key]!.position.latitude,
              _markers[key]!.position.longitude,
              _markers[otherKey]!.position.latitude,
              _markers[otherKey]!.position.longitude);

          // if the distance is less than the radius
          if (distance <= radius) {
            neighborCount++;
            // calculate the new position
            double newLat = (_markers[key]!.position.latitude +
                    _markers[otherKey]!.position.latitude) /
                2;
            double newLong = (_markers[key]!.position.longitude +
                    _markers[otherKey]!.position.longitude) /
                2;

            clumpCount++;

            // create a new marker
            final marker = Marker(
              markerId: MarkerId('Group of $clumpCount'), // TODO: clump count is currently wrong
              position: LatLng(newLat, newLong),
              infoWindow: InfoWindow(
                title: 'Group of $clumpCount',
                snippet: (_markers[key]!.infoWindow.snippet != 'normal' || _markers[otherKey]!.infoWindow.snippet != 'normal') ? 'SOS': 'normal',
              ),
            );

            // remove the old markers
            newMarkers.remove(key);
            newMarkers.remove(otherKey);

            print('Removed $key and $otherKey to get $newLat, $newLong');

            // add the new marker
            newMarkers['clump$clumpCount'] = marker;
          }
        }
      }
      print('Neighbor count for $key: $neighborCount');
    }

    setState(() {
      _markers.clear();
      _markers = newMarkers;
    });
  }

  double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    // convert degrees to radians
    double startLat = startLatitude * (pi / 180);
    double startLong = startLongitude * (pi / 180);
    double endLat = endLatitude * (pi / 180);
    double endLong = endLongitude * (pi / 180);

    // calculate the change in latitude and longitude
    double deltaLat = endLat - startLat;
    double deltaLong = endLong - startLong;

    // calculate the distance
    double a = pow(sin(deltaLat / 2), 2) + cos(startLat) * cos(endLat) * pow(sin(deltaLong / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = 6371 * c;

    return distance;
  }

  late GoogleMapController mapController;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    // final googleOffices = await locations.getGoogleOffices();
    _markers.clear();
    await getStudentLocations();
    setState(() {
      // for (final office in googleOffices.offices) {
      //   final marker = Marker(
      //     markerId: MarkerId(office.name),
      //     position: LatLng(office.lat, office.lng),
      //     infoWindow: InfoWindow(
      //       title: office.name,
      //       snippet: office.address,
      //     ),
      //   );
      //   _markers[office.name] = marker;
      // }
      print(_markers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 100,
              height: SizeConfig.blockSizeVertical! * 100,
              child: GoogleMap(
                mapType: MapType.satellite,
                initialCameraPosition: _kGooglePlex,
                // onMapCreated: (GoogleMapController controller) {
                //   _controller.complete(controller);
                // },
                onMapCreated: _onMapCreated,
                markers: _markers.values.toSet(),
              ))),
      bottomNavigationBar: const NavBar(
        currentIndex: 1,
      ),
    );
  }
}
