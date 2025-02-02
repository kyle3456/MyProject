import 'package:flutter/material.dart';
import 'package:myproject/services/database.dart';
import 'package:myproject/components/person_card.dart';
import 'package:myproject/shared/singleton.dart';

class StudentEdit extends StatefulWidget {
  const StudentEdit({super.key});

  @override
  State<StudentEdit> createState() => _StudentEditState();
}

class _StudentEditState extends State<StudentEdit> {
  final TextEditingController _nameController = TextEditingController();
  List<dynamic> students = [];
  List<PersonCard> studentCards = [];
  Singleton singleton = Singleton();

  List<PersonCard> filteredStudents = [];

  void filterStudents() {
    filteredStudents = studentCards
        .where((student) => student.name.toLowerCase().contains(_nameController.text.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    DatabaseService().getListOfStudentsFromAdmin().then((value) {
      setState(() {
        students = value;

        // Create a list of PersonCard widgets
        studentCards = students.map((student) {
          print("STUDENT: $student");
          return PersonCard(
              name: student['name'],
              description: student['email'],
              imagePath: "assets/Pfp.jpg",
              uid: student['uid'],
              type: "student",
              onTap: () {
                print("Tapped on ${student['name']}");
                if (singleton.userData.containsKey('students')) {
                  if (singleton.userData['students'].contains(student['uid'])) {
                    DatabaseService().removeStudentFromTeacherRoster(student['uid']);
                  } else {
                    DatabaseService().addStudentToTeacherRoster(student['uid']);
                  }
                } else {
                    DatabaseService().addStudentToTeacherRoster(student['uid']);
                  }
              });
        }).toList();

        filteredStudents = List.from(studentCards);
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
                      setState(() {
                        filterStudents();
                      });
                    },
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: filteredStudents,
                  ),
                ],
              ))),
    );
  }
}
