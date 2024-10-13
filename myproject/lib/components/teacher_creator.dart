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

  String createMode = 'Teacher';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            // const Text("Create a new teacher"),
            DropdownButton(items: [
              DropdownMenuItem(child: Text('Create a new teacher'), value: 'Teacher'),
              DropdownMenuItem(child: Text('Create a new student'), value: 'Student'),
            ], onChanged: (String? value) {
              setState(() {
                createMode = value!;
              });
            }, value: createMode),
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
                  createMode,
                  nameController.text,
                  phoneNumber: phoneController.text,
                )
                    .then((value) {
                  print('currently logged in as ${Auth().user!.uid}');

                  final String id = Auth().user!.uid;
                  final String email = emailController.text;
                  final String password = passwordController.text;
                  final String name = nameController.text;

                  Auth().login(adminEmail, adminPassword).then((value) {
                    print('currently logged in as ${Auth().user!.uid}');

                    // record the teach in the staff list of admin
                    if (createMode == 'Teacher') {
                      DatabaseService().addStaff(id, email, password, name);
                    } else {
                      // record the student in the student list of admin
                      DatabaseService().addStudent(id, email, password, name);
                    }
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$createMode created'),
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
