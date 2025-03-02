import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  //  0: Safe Zone, 1: Danger Zone, 2: Delete, 3: Warning Marker
  int selectedToolIdx = -1;

  // List for polygon in progress
  List<LatLng> _polygonInProgress = [];

  // Set of finished polygons
  Set<Polygon> _polygons = {};

  List<LatLng> points = [
    LatLng(33.61806, 117.823),
    LatLng(34.619179, 118.822877),
    LatLng(33.918118, 120.821911),
    LatLng(33.618496, 117.823),
  ];

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
        _markers[student['uid']] = marker;
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
              // TODO: customize the marker color
              markerId: MarkerId(
                  'Group of $clumpCount'), // TODO: clump count is currently wrong
              position: LatLng(newLat, newLong),
              infoWindow: InfoWindow(
                title: 'Group of $clumpCount',
                snippet: (_markers[key]!.infoWindow.snippet != 'normal' ||
                        _markers[otherKey]!.infoWindow.snippet != 'normal')
                    ? 'SOS'
                    : 'normal',
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

  // If admin, check if school_map field is in singleton user data and load the polygons from it
  void loadPolygons() {
    if (_singleton.userData['type'] == 'admin') {
      if (_singleton.userData.containsKey('school_map')) {
        // load the polygons from the school_map field
        var schoolMap = _singleton.userData['school_map'];
        print("School map: $schoolMap");
        for (var shapes in schoolMap["doors"]) {
          for (var shape in shapes) {
            // convert geopoint to latlng
            List<LatLng> latlngs = [];
            for (var geopoint in shape) {
              LatLng latlng = LatLng(geopoint.latitude, geopoint.longitude);
              latlngs.add(latlng);
            }
            // create a polygon
            Polygon polygon = Polygon(
              polygonId: PolygonId(DateTime.now()
                  .millisecondsSinceEpoch
                  .toString()), // TODO: change this to a unique id
              points: latlngs,
              fillColor: Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              strokeColor: Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              geodesic: true,
              strokeWidth: 4,
            );
            _polygons.add(polygon);
          }
        }
        for (var shapes in schoolMap["windows"]) {
          for (var shape in shapes) {
            // convert geopoint to latlng
            List<LatLng> latlngs = [];
            for (var geopoint in shape) {
              LatLng latlng = LatLng(geopoint.latitude, geopoint.longitude);
              latlngs.add(latlng);
            }
            // create a polygon
            Polygon polygon = Polygon(
              polygonId: PolygonId(DateTime.now()
                  .millisecondsSinceEpoch
                  .toString()), // TODO: change this to a unique id
              points: latlngs,
              fillColor: Color.fromARGB(255, 56, 223, 209).withOpacity(0.3),
              strokeColor: Color.fromARGB(255, 56, 223, 209).withOpacity(0.3),
              geodesic: true,
              strokeWidth: 4,
            );
            _polygons.add(polygon);
          }
        }
        for (var shapes in schoolMap["rooms"]) {
          for (var shape in shapes) {
            // convert geopoint to latlng
            List<LatLng> latlngs = [];
            for (var geopoint in shape) {
              LatLng latlng = LatLng(geopoint.latitude, geopoint.longitude);
              latlngs.add(latlng);
            }
            // create a polygon
            Polygon polygon = Polygon(
              polygonId: PolygonId(DateTime.now()
                  .millisecondsSinceEpoch
                  .toString()), // TODO: change this to a unique id
              points: latlngs,
              fillColor: Color.fromARGB(255, 255, 255, 255).withOpacity(0.75),
              strokeColor: Color.fromARGB(255, 250, 250, 250),
              geodesic: true,
              strokeWidth: 4,
            );
            _polygons.add(polygon);
          }
        }
        for (var shapes in schoolMap["halls"]) {
          for (var shape in shapes) {
            // convert geopoint to latlng
            List<LatLng> latlngs = [];
            for (var geopoint in shape) {
              LatLng latlng = LatLng(geopoint.latitude, geopoint.longitude);
              latlngs.add(latlng);
            }
            // create a polygon
            Polygon polygon = Polygon(
              polygonId: PolygonId(DateTime.now()
                  .millisecondsSinceEpoch
                  .toString()), // TODO: change this to a unique id
              points: latlngs,
              fillColor: Color.fromARGB(255, 236, 233, 4).withOpacity(0.3),
              strokeColor: Color.fromARGB(255, 236, 233, 4),
              geodesic: true,
              strokeWidth: 4,
            );
            _polygons.add(polygon);
          }
        }
      }
    }
  }

  // drop marker on map
  void dropMarker(LatLng latlng, String title, String snippet) {
    String markerId = 'marker_${DateTime.now().millisecondsSinceEpoch}';
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: latlng,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      onTap: () {
        print('Tapped on $markerId');
        if (selectedToolIdx == 2) {
          setState(() {
            _markers.remove(markerId);
          });
        } else if (selectedToolIdx == 0 || selectedToolIdx == 1) {
          // if the polygons in progress are at least 3, close the polygon
          if (_polygonInProgress.length >= 3) {
            // close the polygon
            print('Tapped marker! Closing polygon at $latlng');
            setState(() {
              _polygonInProgress.add(latlng);
              // create a new polygon
              Polygon polygon = Polygon(
                polygonId: PolygonId(DateTime.now()
                    .millisecondsSinceEpoch
                    .toString()), // TODO: change this to a unique id
                points: List.from(_polygonInProgress),
                fillColor: (selectedToolIdx == 0)
                    ? Colors.green.withOpacity(0.5)
                    : Colors.red
                  ..withOpacity(0.5),
                strokeColor: (selectedToolIdx == 0) ? Colors.green : Colors.red,
                geodesic: true,
                strokeWidth: 4,
              );
              _polygons.add(polygon);
              _polygonInProgress.clear();
            });
          }
        }
      },
    );

    setState(() {
      _markers[markerId] = marker;
    });
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    // convert degrees to radians
    double startLat = startLatitude * (pi / 180);
    double startLong = startLongitude * (pi / 180);
    double endLat = endLatitude * (pi / 180);
    double endLong = endLongitude * (pi / 180);

    // calculate the change in latitude and longitude
    double deltaLat = endLat - startLat;
    double deltaLong = endLong - startLong;

    // calculate the distance
    double a = pow(sin(deltaLat / 2), 2) +
        cos(startLat) * cos(endLat) * pow(sin(deltaLong / 2), 2);
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

  void policeDraw(LatLng latLng) {
    print('Tapped on $latLng');

    if (selectedToolIdx == 0 || selectedToolIdx == 1) {
      // Place a marker at every tap (vertex marker)
      String vertexId = 'vertex_${DateTime.now().millisecondsSinceEpoch}';
      Marker vertexMarker = Marker(
          markerId: MarkerId(vertexId),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Vertex'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () {
            // close the polygon if appropriate
            if (_polygonInProgress.length >= 3) {
              // Close the polygon
              Color fillColor = (selectedToolIdx == 0) // Room
                  ? Color.fromARGB(255, 255, 255, 255).withOpacity(0.75)
                  : (selectedToolIdx == 1) // Hallway
                      ? Color.fromARGB(255, 236, 233, 4).withOpacity(0.3)
                      : (selectedToolIdx == 2) // Door
                          ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3)
                          : const Color.fromARGB(255, 56, 223, 209)
                              .withOpacity(0.3); // Window
              Color strokeColor = (selectedToolIdx == 0)
                  ? Color.fromARGB(255, 250, 250, 250)
                  : (selectedToolIdx == 1)
                      ? const Color.fromARGB(255, 236, 233, 4)
                      : (selectedToolIdx == 2)
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 56, 223, 209);

              Polygon polygon = Polygon(
                  polygonId: PolygonId(
                      DateTime.now().millisecondsSinceEpoch.toString()),
                  points: List.from(_polygonInProgress),
                  fillColor: fillColor,
                  strokeColor: strokeColor,
                  geodesic: true,
                  strokeWidth: 4,
                  consumeTapEvents: true,
                  onTap: () {
                    if (selectedToolIdx == 4) {
                      setState(() {
                        _polygons.removeWhere((element) =>
                            element.polygonId ==
                            PolygonId(DateTime.now()
                                .millisecondsSinceEpoch
                                .toString()));
                      });
                    }
                  });

              _polygons.add(polygon);
              setState(() {
                _polygonInProgress.clear();
                print(
                    "Cleared polygon in progress, current polygons: $_polygons");
              });
              // ====
            }
          });
      setState(() {
        _markers[vertexId] = vertexMarker;
        _polygonInProgress.add(latLng);
      });

      // If already started a polygon, check if the user tapped near the first vertex.
      double distance = 0;
      if (_polygonInProgress.isNotEmpty) {
        distance = calculateDistance(_polygonInProgress[0].latitude,
            _polygonInProgress[0].longitude, latLng.latitude, latLng.longitude);
      }
      print(
          "Distance from first point: $distance, current point count: ${_polygonInProgress.length}");
      // If at least 3 points have been added, and the tap is near the first point, close the polygon
      if (_polygonInProgress.length >= 3 && distance < 0.001) {
        // Close the polygon
        Color fillColor = (selectedToolIdx == 0)
            ? Colors.green.withOpacity(0.3)
            : Colors.red.withOpacity(0.3);
        Color strokeColor = (selectedToolIdx == 0) ? Colors.green : Colors.red;

        Polygon polygon = Polygon(
            polygonId:
                PolygonId(DateTime.now().millisecondsSinceEpoch.toString()),
            points: List.from(_polygonInProgress),
            fillColor: fillColor,
            strokeColor: strokeColor,
            geodesic: true,
            strokeWidth: 4,
            consumeTapEvents: true,
            onTap: () {
              if (selectedToolIdx == 2) {
                setState(() {
                  _polygons.removeWhere((element) =>
                      element.polygonId ==
                      PolygonId(
                          DateTime.now().millisecondsSinceEpoch.toString()));
                });
              }
            });

        _polygons.add(polygon);
        setState(() {
          _polygonInProgress.clear();
          print("Cleared polygon in progress, current polygons: $_polygons");
        });
      }

      // Add the point to the polygon in progress
      setState(() {
        _polygonInProgress.add(latLng);
      });
    } else if (selectedToolIdx == 3) {
      dropMarker(latLng, 'Warning', 'Warning');
    }
  }

  void adminDraw(LatLng latLng) {
    print('Tapped on $latLng');

    if (selectedToolIdx != 4) {
      // Place a marker at every tap (vertex marker)
      String vertexId = 'vertex_${DateTime.now().millisecondsSinceEpoch}';
      Marker vertexMarker = Marker(
          markerId: MarkerId(vertexId),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Vertex'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () {
            // close the polygon if appropriate
            if (_polygonInProgress.length >= 3) {
              // Close the polygon
              Color fillColor = (selectedToolIdx == 0) // Room
                  ? Color.fromARGB(255, 255, 255, 255).withOpacity(0.75)
                  : (selectedToolIdx == 1) // Hallway
                      ? Color.fromARGB(255, 236, 233, 4).withOpacity(0.3)
                      : (selectedToolIdx == 2) // Door
                          ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3)
                          : const Color.fromARGB(255, 56, 223, 209)
                              .withOpacity(0.3); // Window
              Color strokeColor = (selectedToolIdx == 0)
                  ? Color.fromARGB(255, 250, 250, 250)
                  : (selectedToolIdx == 1)
                      ? const Color.fromARGB(255, 236, 233, 4)
                      : (selectedToolIdx == 2)
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 56, 223, 209);

              var time = DateTime.now();
              Polygon polygon = Polygon(
                  polygonId: PolygonId(time.millisecondsSinceEpoch.toString()),
                  points: List.from(_polygonInProgress),
                  fillColor: fillColor,
                  strokeColor: strokeColor,
                  geodesic: true,
                  strokeWidth: 4,
                  consumeTapEvents: true,
                  onTap: () {
                    print("Tapped on polygon");
                    if (selectedToolIdx == 4) {
                      setState(() {
                        _polygons.removeWhere((element) =>
                            element.polygonId ==
                            PolygonId(time.millisecondsSinceEpoch.toString()));
                      });
                    }
                  });

              _polygons.add(polygon);
              setState(() {
                // remove each vertex marker in _polygonInProgress
                for (var vertex in _polygonInProgress) {
                  print("Removing vertex marker at $vertex");
                  _markers
                      .removeWhere((key, value) => value.position == vertex);
                }

                _polygonInProgress.clear();
                print(
                    "Cleared polygon in progress, current polygons: $_polygons");
              });
              // ====
            }
          });
      setState(() {
        _markers[vertexId] = vertexMarker;
        _polygonInProgress.add(latLng);
      });

      // If already started a polygon, check if the user tapped near the first vertex.
      double distance = 0;
      if (_polygonInProgress.isNotEmpty) {
        distance = calculateDistance(_polygonInProgress[0].latitude,
            _polygonInProgress[0].longitude, latLng.latitude, latLng.longitude);
      }
      print(
          "Distance from first point: $distance, current point count: ${_polygonInProgress.length}");
      // If at least 3 points have been added, and the tap is near the first point, close the polygon
      if (_polygonInProgress.length >= 3 && distance < 0.001) {
        // Close the polygon
        Color fillColor = (selectedToolIdx == 0) // Room
            ? const Color.fromARGB(255, 56, 42, 33).withOpacity(0.3)
            : (selectedToolIdx == 1) // Hallway
                ? const Color.fromARGB(255, 110, 90, 79).withOpacity(0.3)
                : (selectedToolIdx == 2) // Door
                    ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3)
                    : const Color.fromARGB(255, 56, 223, 209)
                        .withOpacity(0.3); // Window
        Color strokeColor = (selectedToolIdx == 0)
            ? const Color.fromARGB(255, 56, 42, 33)
            : (selectedToolIdx == 1)
                ? const Color.fromARGB(255, 110, 90, 79)
                : (selectedToolIdx == 2)
                    ? const Color.fromARGB(255, 0, 0, 0)
                    : const Color.fromARGB(255, 56, 223, 209);

        Polygon polygon = Polygon(
            polygonId:
                PolygonId(DateTime.now().millisecondsSinceEpoch.toString()),
            points: List.from(_polygonInProgress),
            fillColor: fillColor,
            strokeColor: strokeColor,
            geodesic: true,
            strokeWidth: 4,
            consumeTapEvents: true,
            onTap: () {
              print(" B Tapped on polygon");
              if (selectedToolIdx == 4) {
                setState(() {
                  _polygons.removeWhere((element) =>
                      element.polygonId ==
                      PolygonId(
                          DateTime.now().millisecondsSinceEpoch.toString()));
                });
              }
            });

        _polygons.add(polygon);
        setState(() {
          _polygonInProgress.clear();
          print("Cleared polygon in progress, current polygons: $_polygons");
        });
      }

      // Add the point to the polygon in progress
      setState(() {
        _polygonInProgress.add(latLng);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _polygons.add(Polygon(
    //   // given polygonId
    //   polygonId: PolygonId('1'),
    //   // initialize the list of points to display polygon
    //   points: points,
    //   // given color to polygon
    //   fillColor: Colors.green.withOpacity(0.3),
    //   // given border color to polygon
    //   strokeColor: Colors.green,
    //   geodesic: true,
    //   // given width of border
    //   strokeWidth: 4,
    // ));
  }

  @override
  Widget build(BuildContext context) {
    // load the polygons from the database
    loadPolygons();
    print("POLYGONS: $_polygons");
    return Scaffold(
      body: Center(
          child: SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 100,
              height: SizeConfig.blockSizeVertical! * 100,
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.satellite,
                    initialCameraPosition: _kGooglePlex,
                    // onMapCreated: (GoogleMapController controller) {
                    //   _controller.complete(controller);
                    // },
                    onMapCreated: _onMapCreated,
                    markers: _markers.values.toSet(),
                    polygons: _polygons,
                    onTap: (_singleton.userData["type"] == "police")
                        ? policeDraw
                        : (_singleton.userData["type"] == "admin")
                            ? adminDraw
                            : null,
                    buildingsEnabled: true,
                  ),
                  // Editor Buttons on the right side
                  (_singleton.userData["type"] == "police")
                      ? Positioned(
                          right: 15,
                          top: 30,
                          child: SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 15,
                              height: SizeConfig.blockSizeVertical! * 33,
                              child: Card(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: (selectedToolIdx == 0)
                                              ? Colors.grey
                                              : Colors.transparent,
                                        ),
                                        child: IconButton(
                                          // Safe Zone: create safe (green) polygon vertex
                                          // starting from 3 points tapped, render the polygon
                                          // to end the polygon, tap the first point again
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              selectedToolIdx = 0;
                                            });

                                            adjustMarkers(0.001);
                                          },
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: (selectedToolIdx == 1)
                                              ? Colors.grey
                                              : Colors.transparent,
                                        ),
                                        child: IconButton(
                                          // Danger Zone: create danger (red) polygon vertex
                                          // same as safe zone, but red
                                          icon: Icon(Icons.dangerous),
                                          onPressed: () {
                                            setState(() {
                                              selectedToolIdx = 1;
                                            });

                                            adjustMarkers(0.001);
                                          },
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: (selectedToolIdx == 2)
                                              ? Colors.grey
                                              : Colors.transparent,
                                        ),
                                        child: IconButton(
                                          // Delete Zone: tap a marker/polygon to delete
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              selectedToolIdx = 2;
                                            });

                                            adjustMarkers(0.001);
                                          },
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: (selectedToolIdx == 3)
                                              ? Colors.grey
                                              : Colors.transparent,
                                        ),
                                        child: IconButton(
                                          // Warning Marker: drop a yellow warning marker
                                          icon: Icon(Icons.warning),
                                          onPressed: () {
                                            setState(() {
                                              selectedToolIdx = 3;
                                            });

                                            adjustMarkers(0.001);
                                          },
                                        ),
                                      ),
                                    ],
                                  ))))
                      : (_singleton.userData["type"] == "admin")
                          ? Positioned(
                              right: 15,
                              top: 30,
                              child: SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 15,
                                  height: SizeConfig.blockSizeVertical! * 33,
                                  child: Card(
                                      color: Colors.white,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: (selectedToolIdx == 0)
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                            ),
                                            child: IconButton(
                                              // Safe Zone: create safe (green) polygon vertex
                                              // starting from 3 points tapped, render the polygon
                                              // to end the polygon, tap the first point again
                                              icon:
                                                  Icon(Icons.add_home_rounded),
                                              onPressed: () {
                                                setState(() {
                                                  selectedToolIdx = 0;
                                                });

                                                adjustMarkers(0.001);
                                              },
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: (selectedToolIdx == 1)
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                            ),
                                            child: IconButton(
                                              // Safe Zone: create safe (green) polygon vertex
                                              // starting from 3 points tapped, render the polygon
                                              // to end the polygon, tap the first point again
                                              icon:
                                                  Icon(Icons.add_road_rounded),
                                              onPressed: () {
                                                setState(() {
                                                  selectedToolIdx = 1;
                                                });

                                                adjustMarkers(0.001);
                                              },
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: (selectedToolIdx == 2)
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                            ),
                                            child: IconButton(
                                              // Danger Zone: create danger (red) polygon vertex
                                              // same as safe zone, but red
                                              icon: Icon(
                                                  Icons.meeting_room_rounded),
                                              onPressed: () {
                                                setState(() {
                                                  selectedToolIdx = 2;
                                                });

                                                adjustMarkers(0.001);
                                              },
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: (selectedToolIdx == 3)
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                            ),
                                            child: IconButton(
                                              // Delete Zone: tap a marker/polygon to delete
                                              icon: Icon(Icons.window_rounded),
                                              onPressed: () {
                                                setState(() {
                                                  selectedToolIdx = 3;
                                                });

                                                adjustMarkers(0.001);
                                              },
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: (selectedToolIdx == 4)
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                            ),
                                            child: IconButton(
                                              // Warning Marker: drop a yellow warning marker
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  selectedToolIdx = 4;
                                                });

                                                adjustMarkers(0.001);
                                              },
                                            ),
                                          ),
                                        ],
                                      ))))
                          : Container(),
                  // Save Button
                  (_singleton.userData["type"] == "admin")
                      ? Positioned(
                          right: 15,
                          top: 340,
                          child: SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 15,
                              height: SizeConfig.blockSizeVertical! * 10,
                              child: Card(
                                  color: Colors.white,
                                  child: IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () {
                                      print("Saving polygons from $_polygons");

                                      // rooms
                                      Set<Polygon> rooms = {};
                                      // hallways
                                      Set<Polygon> hallways = {};
                                      // doors
                                      Set<Polygon> doors = {};
                                      // windows
                                      Set<Polygon> windows = {};

                                      // iterate through all the polygons
                                      for (var polygon in _polygons) {
                                        // check the color of the polygon
                                        if (polygon.fillColor ==
                                            const Color.fromARGB(
                                                    255, 255, 255, 255)
                                                .withOpacity(0.75)) {
                                          // room
                                          rooms.add(polygon);
                                        } else if (polygon.fillColor ==
                                            const Color.fromARGB(
                                                    255, 236, 233, 4)
                                                .withOpacity(0.3)) {
                                          // hallway
                                          hallways.add(polygon);
                                        } else if (polygon.fillColor ==
                                            const Color.fromARGB(255, 0, 0, 0)
                                                .withOpacity(0.3)) {
                                          // door
                                          doors.add(polygon);
                                        } else if (polygon.fillColor ==
                                            const Color.fromARGB(
                                                    255, 56, 223, 209)
                                                .withOpacity(0.3)) {
                                          // window
                                          windows.add(polygon);
                                        }
                                      }

                                      print("Attempting to save to firestore");

                                      DatabaseService().saveFloorPlan(
                                          rooms, hallways, doors, windows);
                                    },
                                  ))))
                      : Container(),
                  // Analyze Button
                  (_singleton.userData["type"] == "admin")
                      ? Positioned(
                          left: SizeConfig.blockSizeHorizontal! * 30,
                          bottom: 10,
                          child: SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 40,
                              height: SizeConfig.blockSizeVertical! * 5,
                              child: Card(
                                  color: Colors.white,
                                  child: ElevatedButton(
                                      child: const Text("Analyze"),
                                      onPressed: () {
                                        print(
                                            "Analyzing polygons from $_polygons");

                                        // show the popup
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const AnalysisPopup();
                                          },
                                        );
                                      }))))
                      : Container(),
                ],
              ))),
      bottomNavigationBar: const NavBar(
        currentIndex: 1,
      ),
    );
  }
}

// Analysis Popup
class AnalysisPopup extends StatefulWidget {
  const AnalysisPopup({super.key});

  @override
  State<AnalysisPopup> createState() => _AnalysisPopupState();
}

class _AnalysisPopupState extends State<AnalysisPopup> {
  List<String> tips = [
    "Avoid hiding in dead ends.",
    "Stay away from windows.",
    "Make sure all students are with a teacher.",
    "Stay away from the doors.",
  ];

  @override
  Widget build(BuildContext context) {
    int randidx = Random().nextInt(tips.length);
    return AlertDialog(
      title: const Text('Analysis'),
      content: Text(
          'The current layout is not safe. Please follow the tips below:\n\n${tips[randidx]}'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
