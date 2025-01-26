import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:latlong2/latlong.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  final Singleton _singleton = Singleton();

  // sign in with email and password
  Future<User?> login(String email, String password) async {
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
      String email, String password, String accountType, String name,
      {String phoneNumber = ''}) async {
    try {
      UserCredential? result;
      if (accountType == 'Admin' || accountType == 'Police') {
        print("admin or police");
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) async {
          if (value.user == null) {
            return null;
          }

          // set the display name of the user
          await value.user!.updateDisplayName(name).then((_) async {
            print("display name set");
            if (accountType == "Admin") {
              // create a new document for the user with the uid
              print("Creating admin account with uid: ${value.user!.uid}");
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(value.user!.uid)
                  .set({
                'status': 'normal',
                'staff': [],
                'type': 'admin',
                'email': email,
                'password': password,
                'name': name,
              });
            } else if (accountType == "Police") {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .set({
                'location': const GeoPoint(0, 0),
                'type': 'police',
                'chosen_schools': {},
              });
            }
          });
        });
      }

      if (accountType == "Teacher" || accountType == "Student") {
        print("Attempting to create teacher account");
        // // get the uid of the user, who should be an admin
        // final user = await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(FirebaseAuth.instance.currentUser!.uid)
        //     .get();

        // print("teacher data: ${user.data()}");
        final String adminUID = user!.uid;

        // check that the user is an admin
        if (_singleton.userData['type'] == 'admin') {
          // create a new document for the user with the uid
          result = await _auth.createUserWithEmailAndPassword(
              email: email, password: password);

          if (result.user == null) {
            return null;
          }

          print("Creating $accountType account with uid: ${result.user!.uid}");

          // set the display name of the user
          await result.user!.updateDisplayName(name);

          print("display name set");

          await FirebaseFirestore.instance
              .collection('users')
              .doc(result.user!.uid)
              .set({
            'status': 'normal',
            'location': const GeoPoint(0, 0),
            'type': accountType.toLowerCase(),
            'admin': adminUID,
            'name': name,
          });

          print("$accountType account created");
        } else {
          return null;
        }
      }

      return result?.user;
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

  // delete the user
  Future<void> deleteUser(String accountType) async {
    try {
      // if police account, delete normally in firestore
      // if admin account, delete self and all data belonging to the uids of the staff
      if (accountType == 'police') {
        var ref = FirebaseFirestore.instance.collection('users');

        return await ref.doc(user!.uid).delete().then((value) {
          return user!.delete();
        });
      } else if (accountType == 'admin') {
        // get the staff uids
        final staff = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        // delete the admin
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .delete();

        // delete the staff
        for (var uid in staff.data()!['staff']) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .delete();
        }

        return user!.delete();
      } else if (accountType == 'teacher') {
        // TODO: adjust once we have a better idea of teacher system
        return await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .delete()
            .then((value) {
          return user!.delete();
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }
}
