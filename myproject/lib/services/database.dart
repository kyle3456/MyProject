import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myproject/services/auth.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final Singleton singleton = Singleton();

  Future<void> createSchool(
      String schoolName, String adminUID, double lat, double long) {
    final ref = FirebaseFirestore.instance.collection('schools').doc();
    ref.set({
      'name': schoolName,
      'admin': adminUID,
      'location': GeoPoint(lat, long),
    });

    // add the school to the admin's school field
    final adminRef =
        FirebaseFirestore.instance.collection('users').doc(adminUID);
    return adminRef.update({'school': ref.id});
  }

  Future<List<dynamic>> getListOfSchools() async {
    final ref = FirebaseFirestore.instance.collection('schools');
    QuerySnapshot snapshot = await ref.get();
    List<dynamic> schools = snapshot.docs;

    return schools;
  }

  Future<void> addStaff(
      String teacherUID, String email, String password, String name) {
    // check if the current user is an admin first
    if (singleton.userData['type'] == 'admin') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // append uid to the array at field staff
      return ref.update({
        'staff': FieldValue.arrayUnion([
          {
            'uid': teacherUID,
            'email': email,
            'password': password,
            'name': name
          }
        ])
      });
    }
    return Future.value();
  }

  Future<void> addStudent(
      String studentUID, String email, String password, String name) {
    // check if the current user is an admin first
    if (singleton.userData['type'] == 'admin' ||
        singleton.userData['type'] == 'teacher') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // append uid to the array at field student
      return ref.update({
        'student': FieldValue.arrayUnion([
          {
            'uid': studentUID,
            'email': email,
            'password': password,
            'name': name
          }
        ])
      });
    }
    return Future.value();
  }

  Future<String> getSchoolNameFromAdmin() async {
    if (singleton.userData['type'] == 'teacher') {
      // get the school id from the admin's school field
      String adminUID = singleton.userData['admin'];
      final adminRef =
          FirebaseFirestore.instance.collection('users').doc(adminUID);
      DocumentSnapshot adminSnapshot = await adminRef.get();
      Map<String, dynamic> adminData =
          adminSnapshot.data() as Map<String, dynamic>;

      String schoolUID = adminData['school'];

      final ref =
          FirebaseFirestore.instance.collection('schools').doc(schoolUID);
      DocumentSnapshot snapshot = await ref.get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      return data['name'];
    }
    return '';
  }

  Future<String> getSchoolIDFromAdmin() async {
    if (singleton.userData['type'] == 'teacher') {
      // get the school id from the admin's school field
      String adminUID = singleton.userData['admin'];
      final adminRef =
          FirebaseFirestore.instance.collection('users').doc(adminUID);
      DocumentSnapshot adminSnapshot = await adminRef.get();
      Map<String, dynamic> adminData =
          adminSnapshot.data() as Map<String, dynamic>;

      String schoolUID = adminData['school'];

      return schoolUID;
    }
    return '';
  }

  Future<List<dynamic>> getListOfStudentsFromAdmin() async {
    if (singleton.userData['type'] == 'teacher') {
      String adminUID = singleton.userData['admin'];
      final ref = FirebaseFirestore.instance.collection('users').doc(adminUID);
      DocumentSnapshot snapshot = await ref.get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> students = data['student'];

      print("LIST OF STUDENTS: $students");
      return students;
    }
    return [];
  }

  Future<List<Person>> getListOfStudentsFromTeacher() async {
    if (singleton.userData['type'] == 'teacher') {
      List<String> studentUIDs = singleton.userData['students'].cast<String>();
      List<Person> students = [];

      for (String studentUID in studentUIDs) {
        final ref =
            FirebaseFirestore.instance.collection('users').doc(studentUID);
        DocumentSnapshot snapshot = await ref.get();
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        students.add(Person(
          uid: studentUID,
          name: data['name'],
          description: data['status'],
          imagePath: 'assets/Pfp.jpg',
        ));
      }

      return students;
    }
    return [];
  }

  Future<void> addStudentToTeacherRoster(String studentUID) {
    if (singleton.userData['type'] == 'teacher') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // append uid to the array at field student
      return ref.update({
        'students': FieldValue.arrayUnion([studentUID])
      });
    }
    return Future.value();
  }

  Future<void> removeStudentFromTeacherRoster(String studentUID) {
    if (singleton.userData['type'] == 'teacher') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // append uid to the array at field student
      return ref.update({
        'students': FieldValue.arrayRemove([studentUID])
      });
    }
    return Future.value();
  }

  Future<Map<String, dynamic>> getStudentLocation(String studentUID) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(studentUID);
    var studentData = ref.get();

    Map<String, dynamic> studentLocation =
        await studentData.then((value) => value.data() as Map<String, dynamic>);

    // add the student's uid to the map
    studentLocation['uid'] = studentUID;

    return studentLocation;
  }

  Future<void> markSOS() async {
    // get the school uid
    String schoolUID = await getSchoolIDFromAdmin();

    // update rtdb schools/schoolUID/teacherUID/danger to true
    final ref = FirebaseDatabase.instance
        .ref()
        .child('schools')
        .child(schoolUID)
        .child(Auth().user!.uid);

    final currentDanger = await ref.once();
    Map<String, dynamic> data =
        Map<String, dynamic>.from(currentDanger.snapshot.value as Map);
    if (data["danger"] == true) {
      ref.set({"danger": false});
    } else {
      ref.set({"danger": true});
    }
    // set the status of self to SOS
    final ref2 =
        FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

    if (singleton.userData['status'] == 'SOS') {
      return ref2.update({'status': 'normal'});
    }
    return ref2.update({'status': 'SOS'});
  }

  // Future<void> getStudentLocations() {
  //   // determine our account type
  //   String type = singleton.userData['type'];

  //   if (type == 'admin') {

  //   } else if (type == 'teacher') {

  //   } else if (type == 'police') {

  //   }
  // }

  Future<void> sendSchoolRequestToAdmin(String adminUID) {
    // check that our account type is police
    if (singleton.userData['type'] != 'police') {
      return Future.value();
    }

    final selfRef =
        FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);
    selfRef.update({
      "pending_requests": {
        adminUID: "pending",
      }
    });

    final ref = FirebaseFirestore.instance.collection('users').doc(adminUID);

    return ref.update({
      'police_requests': FieldValue.arrayUnion([Auth().user!.uid])
    });
  }

  // TODO: the user document gets deleted, but fails to be removed from admin and firebase auth
  Future<void> deleteTeacher(String teacherUID) async {
    // check if the user is an admin first
    if (singleton.userData['type'] == 'admin') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // remove the teacher from the staff field
      ref.update({
        'staff': FieldValue.arrayRemove([teacherUID])
      });

      // remove the teacher's own document
      final teacherRef =
          FirebaseFirestore.instance.collection('users').doc(teacherUID);
      teacherRef.delete().then((value) {
        // delete the teacher's account
        return Auth().deleteAccount(teacherUID, 'teacher');
      });
    }
  }

  Future<void> unlinkTeacher(String teacherUID) async {
    // check if the user is an admin first
    if (singleton.userData['type'] == 'admin') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // remove the teacher from the staff field
      ref.update({
        'staff': FieldValue.arrayRemove([teacherUID])
      });
    }
  }

  Future<void> deleteStudent(String studentUID) async {
    // check if the user is an admin first
    if (singleton.userData['type'] == 'admin') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // remove the student from the student field, the student field is an array of maps
      // so we need to remove the map that contains the student's uid
      ref.update({
        'student': FieldValue.arrayRemove([
          {'uid': studentUID}
        ])
      });

      // remove the student's own document
      final studentRef =
          FirebaseFirestore.instance.collection('users').doc(studentUID);
      studentRef.delete().then((value) {
        // delete the student's account
        return Auth().deleteAccount(studentUID, 'student');
      });
    }
  }

  Future<void> unlinkStudent(String studentUID) async {
    // check if the user is an admin first
    if (singleton.userData['type'] == 'admin') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // remove the student from the student field
      ref.update({
        'student': FieldValue.arrayRemove([studentUID])
      });
    }
  }

  Future<void> deletePoliceRequest(String policeUID) async {
    // check if the user is an admin first
    if (singleton.userData['type'] == 'admin') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // remove the police from the police_requests field
      ref.update({
        'police_requests': FieldValue.arrayRemove([policeUID])
      });

      // remove the police's request from their pending_requests field with the key matching the admin's uid
      final policeRef =
          FirebaseFirestore.instance.collection('users').doc(policeUID);
      policeRef.update({'pending_requests': FieldValue.delete()});
    }
  }

  Future<void> acceptPoliceRequest(String policeUID) async {
    // check if the user is an admin first
    if (singleton.userData['type'] == 'admin') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // remove the police from the police_requests field
      ref.update({
        'police_requests': FieldValue.arrayRemove([policeUID])
      });

      // add the police to the police field
      ref.update({
        'police': FieldValue.arrayUnion([policeUID])
      });

      // change the police's pending request status to true in the field matching our uid
      final policeRef =
          FirebaseFirestore.instance.collection('users').doc(policeUID);
      policeRef.update({
        'pending_requests': {Auth().user!.uid: true}
      });
    }
  }

  // Save school floor plan drawn by the admin
  Future<void> saveFloorPlan(Set<Polygon> rooms, Set<Polygon> halls,
      Set<Polygon> doors, Set<Polygon> windows) async {
    print("SAVING FLOOR PLAN");
    // check if the user is an admin first
    if (singleton.userData['type'] == 'admin') {
      final ref =
          FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // add the geopooints of each polygon in theri respective array. All 4 arrays are under the field "school_map"

      List<List<GeoPoint>> roomPoints = [];
      List<List<GeoPoint>> hallPoints = [];
      List<List<GeoPoint>> doorPoints = [];
      List<List<GeoPoint>> windowPoints = [];
      for (Polygon room in rooms) {
        List<GeoPoint> roomShape = [];
        for (LatLng point in room.points) {
          roomShape.add(GeoPoint(point.latitude, point.longitude));
        }
        roomPoints.add(roomShape);
      }
      print("ROOMS: $roomPoints");
      for (Polygon hall in halls) {
        List<GeoPoint> hallShape = [];
        for (LatLng point in hall.points) {
          hallShape.add(GeoPoint(point.latitude, point.longitude));
        }
        hallPoints.add(hallShape);
      }
      print("HALLS: $hallPoints");
      for (Polygon door in doors) {
        List<GeoPoint> doorShape = [];
        for (LatLng point in door.points) {
          doorShape.add(GeoPoint(point.latitude, point.longitude));
        }
        doorPoints.add(doorShape);
      }
      print("DOORS: $doorPoints");
      for (Polygon window in windows) {
        List<GeoPoint> windowShape = [];
        for (LatLng point in window.points) {
          windowShape.add(GeoPoint(point.latitude, point.longitude));
        }
        windowPoints.add(windowShape);
      }
      print("WINDOWS: $windowPoints");

      Map<String, dynamic> data = {
        'school_map': {
          'rooms': roomPoints,
          'halls': hallPoints,
          'doors': doorPoints,
          'windows': windowPoints
        }
      };

      print("DATA: $data");

      ref.update({
        'school_map': data
      });
    }
  }
}
