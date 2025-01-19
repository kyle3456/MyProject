import 'package:cloud_firestore/cloud_firestore.dart';
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
    Map<String, dynamic> data = Map<String, dynamic>.from(currentDanger.snapshot.value as Map);
    if (data["danger"] == true) {
      ref.set({"danger":false});
    } else {
      ref.set({"danger":true});
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
}
