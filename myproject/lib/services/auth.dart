import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  // sign in with email and password
  Future<User?> login(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      if (kDebugMode) print(e.toString());
      return null;
    }
  }

  // register with email and password
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String accountType, String name) async {
    try {
      UserCredential? result;
      if (accountType == 'admin' || accountType == 'police') {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        if (result.user == null) {
          return null;
        }

        // set the display name of the user
        await result.user!.updateDisplayName(name);
      }

      if (accountType == "admin") {
        // create a new document for the user with the uid
        await FirebaseFirestore.instance
            .collection('users')
            .doc(result!.user!.uid)
            .set({
          'status': 'normal',
          'staff': [],
          'type': 'admin',
        });
      } else if (accountType == "police") {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(result!.user!.uid)
            .set({
          'location': const GeoPoint(0, 0),
          'type': 'police',
        });
      } else if (accountType == "teacher") {
        // get the uid of the user, who should be an admin
        final user = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        // check that the user is an admin
        if (user.data()!['type'] == 'admin') {
          // create a new document for the user with the uid
          result = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

          if (result.user == null) {
            return null;
          }

          // set the display name of the user
          await result.user!.updateDisplayName(name);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(result.user!.uid)
              .set({
            'status': 'normal',
            'location': const GeoPoint(0, 0),
            'type': 'teacher',
            'admin': FirebaseAuth.instance.currentUser!.uid,
          });
        } else {
          return null;
        }
      }

      return result!.user;
    } catch (e) {
      if (kDebugMode) print(e.toString());
      return null;
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }
}
