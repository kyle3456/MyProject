import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myproject/services/auth.dart';
import 'package:myproject/shared/singleton.dart';

class DatabaseService {
  final Singleton singleton = Singleton();

  Future<void> addStaff(String teacherUID, String email, String password, String name) {
    // check if the current user is an admin first
    if (singleton.userData['type'] == 'admin') {
      final ref = FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // append uid to the array at field staff
      return ref.update({
        'staff': FieldValue.arrayUnion([{'uid': teacherUID, 'email': email, 'password': password, 'name': name}])
      });
    }
    return Future.value();
  }

  Future<void> addStudent(String studentUID, String email, String password, String name) {
    // check if the current user is an admin first
    if (singleton.userData['type'] == 'admin' || singleton.userData['type'] == 'teacher') {
      final ref = FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // append uid to the array at field student
      return ref.update({
        'student': FieldValue.arrayUnion([{'uid': studentUID, 'email': email, 'password': password, 'name': name}])
      });
    }
    return Future.value();
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

  Future<void> addStudentToTeacherRoster(String studentUID) {
    if (singleton.userData['type'] == 'teacher') {
      final ref = FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // append uid to the array at field student
      return ref.update({
        'students': FieldValue.arrayUnion([studentUID])
      });
    }
    return Future.value();
  }

  Future<void> removeStudentFromTeacherRoster(String studentUID) {
    if (singleton.userData['type'] == 'teacher') {
      final ref = FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

      // append uid to the array at field student
      return ref.update({
        'students': FieldValue.arrayRemove([studentUID])
      });
    }
    return Future.value();
  }

  Future<void> markSOS() {
    // set the status of self to SOS
    final ref = FirebaseFirestore.instance.collection('users').doc(Auth().user!.uid);

    if (singleton.userData['status'] == 'SOS') {
      return ref.update({'status': 'normal'});
    }
    return ref.update({'status': 'SOS'});
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