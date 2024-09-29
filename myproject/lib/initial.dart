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
            return const CircularProgressIndicator();
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            singleton.userData = snapshot.data!.data() as Map<String, dynamic>;
            if (kDebugMode) {
              print('Singleton: ${singleton.userData}');
            }
          }
          
          return const HomeScreen();
        });
  }
}
