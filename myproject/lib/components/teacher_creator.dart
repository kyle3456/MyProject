import 'package:flutter/material.dart';
import 'package:myproject/services/auth.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:myproject/services/database.dart';

class TeacherCreator extends StatefulWidget {
  const TeacherCreator({super.key});

  @override
  State<TeacherCreator> createState() => _TeacherCreatorState();
}

class _TeacherCreatorState extends State<TeacherCreator> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  Singleton singleton = Singleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            const Text("Create a new teacher"),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '*Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '*Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '*Password'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            ElevatedButton(
              onPressed: () {
                final String adminEmail = singleton.userData['email'];
                final String adminPassword = singleton.userData['password'];
                Auth()
                    .registerWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                  'Teacher',
                  nameController.text,
                  phoneNumber: phoneController.text,
                )
                    .then((value) {
                  print('currently logged in as ${Auth().user!.uid}');

                  final String teacherId = Auth().user!.uid;
                  final String teacherEmail = emailController.text;
                  final String teacherPassword = passwordController.text;
                  final String teacherName = nameController.text;

                  Auth().login(adminEmail, adminPassword).then((value) {
                    print('currently logged in as ${Auth().user!.uid}');

                    // record the teach in the staff list of admin
                    DatabaseService().addStaff(teacherId, teacherEmail, teacherPassword, teacherName);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teacher created'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                    ),
                  );
                });
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
