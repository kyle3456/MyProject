import 'package:flutter/material.dart';
import 'package:myproject/components/NavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/services/auth.dart';
import 'package:myproject/shared/singleton.dart';
import 'package:myproject/components/teacher_creator.dart';
import 'package:myproject/components/student_edit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _value = true;
  String _password = '';
  Singleton singleton = Singleton();
  late final SharedPreferences prefs;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void setupPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _password = prefs.getString('password') ?? '';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setupPrefs();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Notifications'),
                        Switch(
                          value: _value,
                          onChanged: (value) {
                            setState(() {
                              _value = value;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        )
                      ],
                    ),
                    if (singleton.userData['type'] == 'admin')
                      TeacherCreator(),
                    SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 90,
                        height: SizeConfig.blockSizeVertical! * 20,
                        child: (_password == '') ? Card(
                            color: const Color.fromARGB(255, 122, 122, 122),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextField(
                                    controller: _passwordController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Password',
                                    ),
                                  ),
                                  TextField(
                                    controller: _confirmPasswordController,
                                    decoration: const InputDecoration(
                                      hintText: 'Confirm Password',
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        if (_passwordController.text ==
                                                _confirmPasswordController.text &&
                                            _passwordController.text.isNotEmpty) {
                                          await prefs.setString(
                                            'password',
                                            _passwordController.text,
                                          ).then((value) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Password created successfully')));
                                            setState(() {
                                              _password = _passwordController.text;
                                            });
                                          });
                                          
                                        }
                                      },
                                      child: const Text("Create Password"))
                                ],
                              ),
                            )) : StudentEdit()),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 50,
                      child: ElevatedButton(
                          onPressed: () async {
                            await Auth().signOut().then((value) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/', (route) => false);
                            });
                          },
                          child: const Text("Log Out")
                      ),
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red
                        ),
                        onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) { 
                            return AlertDialog(
                              title: const Text('Delete Account'),
                              content: const Text('Are you sure you want to delete your account?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await Auth().deleteUser("police").then((value) { // TODO: replace with true account type
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/', (route) => false);
                                    });
                                  },
                                  child: const Text('Delete'),
                                )
                              ],
                            );
                          }
                        );
                      }, child: const Text("Delete Account")),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const NavBar(
          currentIndex: 2,
        ));
  }
}

// delete pref data with password
// change password
// notification settings