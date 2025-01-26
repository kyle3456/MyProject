import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myproject/services/database.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:myproject/size_config.dart';
import 'package:geocoding/geocoding.dart';

class SchoolSearch extends StatefulWidget {
  const SchoolSearch({super.key});

  @override
  State<SchoolSearch> createState() => _SchoolSearchState();
}

class _SchoolSearchState extends State<SchoolSearch> {
  final TextEditingController _nameController = TextEditingController();
  List<dynamic> schools = [];
  List<SchoolCard> schoolCards = [];
  Singleton singleton = Singleton();

  List<SchoolCard> filteredSchools = [];

  void searchSchools(String query) {
    filteredSchools = schoolCards.where((school) {
      return school.schoolName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    DatabaseService().getListOfSchools().then((value) {
      setState(() {
        schools = value;

        // Create a list of PersonCard widgets
        schoolCards = schools.map((school) {
          print("SCHOOL: $school");
          // get school id from doc id

          return SchoolCard(
              schoolName: school['name'],
              schoolGeoLocation: school['location'],
              adminID: school['admin'],
              schoolID: school.id);
        }).toList();

        filteredSchools = List.from(schoolCards);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: shorten the scrollable student list without breaking
    return SizedBox(
      // height: SizeConfig.blockSizeVertical! * 60,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Search'),
                    onChanged: (value) {
                      searchSchools(value);
                      setState(() {});
                    },
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: filteredSchools,
                  ),
                ],
              ))),
    );
  }
}

class SchoolCard extends StatefulWidget {
  const SchoolCard(
      {super.key,
      required this.schoolName,
      required this.schoolGeoLocation,
      required this.adminID,
      required this.schoolID});
  final String schoolName;
  final GeoPoint schoolGeoLocation;
  final String adminID;
  final String schoolID;

  @override
  State<SchoolCard> createState() => _SchoolCardState();
}

class _SchoolCardState extends State<SchoolCard> {
  Placemark? schoolLocation;
  String fullAddress = "";

  @override
  void initState() {
    super.initState();
    // get school location
    getSchoolLocation().then((value) {
      print("SCHOOL LOCATION: $value");
      setState(() {
        schoolLocation = value;
        fullAddress =
            "${schoolLocation!.street}\n${schoolLocation!.locality} ${schoolLocation!.administrativeArea} ${schoolLocation!.postalCode}";
      });
    });
  }

  Future<Placemark> getSchoolLocation() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.schoolGeoLocation.latitude, widget.schoolGeoLocation.longitude);
    return placemarks[0];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.blockSizeVertical! * 10,
      child: InkWell(
        onTap: () {
          print("Sending request to admin: ${widget.adminID}");
          DatabaseService().sendSchoolRequestToAdmin(widget.adminID);
        },
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.schoolName),
              Text(
                schoolLocation != null ? fullAddress : "Loading...",
                textAlign: TextAlign.center,
              ),
              // Text(widget.adminID),
              // Text(widget.schoolID),
            ],
          ),
        ),
      ),
    );
  }
}
