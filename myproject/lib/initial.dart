import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myproject/screens/login.dart';
import 'package:myproject/screens/homescreen.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Initial extends StatelessWidget {
  const Initial({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    Singleton singleton = Singleton();

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            singleton.userData = snapshot.data!.data() as Map<String, dynamic>;

            if (singleton.userData["type"] == "admin") {
              List<dynamic> staffList = singleton.userData["staff"];
              List<dynamic> studentList = singleton.userData["student"];

              for (int i = 0; i < staffList.length; i++) {
                singleton.persons.clear();
                singleton.persons.add(Person(
                  name: staffList[i]["name"],
                  description: staffList[i]["email"],
                  imagePath: (staffList[i].containsKey("image"))
                      ? staffList[i]["image"]
                      : 'assets/Pfp.jpg',
                ));
              }

              for (int i = 0; i < studentList.length; i++) {
                singleton.students.clear();
                singleton.students.add(Person(
                  name: studentList[i]["name"],
                  description: studentList[i]["email"],
                  imagePath: (studentList[i].containsKey("image"))
                      ? studentList[i]["image"]
                      : 'assets/Pfp.jpg',
                ));
              }
            } else if (singleton.persons.isNotEmpty) {
              singleton.persons.clear();
              singleton.students.clear();
            }

            if (kDebugMode) {
              print('Singleton: ${singleton.userData}');
            }

            singleton.notify();
          }

          return const HomeScreen();
        });
  }
}
