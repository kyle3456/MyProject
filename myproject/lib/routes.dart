import 'package:myproject/screens/homescreen.dart';
import 'package:myproject/screens/mapscreen.dart';
import 'package:myproject/screens/camerascreen.dart';
import 'package:myproject/screens/settings.dart';
import 'package:myproject/screens/login.dart';
import 'package:myproject/screens/signup.dart';
import 'package:myproject/initial.dart';

var routes = {
  '/': (context) => Initial(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/home': (context) => HomeScreen(),
  '/map': (context) => MapScreen(),
  '/camera': (context) => CameraScreen(),
  '/settings': (context) => SettingsScreen(),
};
 
