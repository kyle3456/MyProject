import 'package:flutter/material.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/services/auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String _selectedAccountType = 'Admin';
  bool _isAgreed = false;

  bool isFormValid() {
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _emailController.text.contains('@') &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _isAgreed) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      child: SizedBox(
        height: SizeConfig.blockSizeVertical! * 80,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name', hintText: 'Enter your full name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', hintText: 'Enter your email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: 'Password', hintText: 'Enter your password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Enter your password again'),
                obscureText: true,
              ),
              Row(
                children: [
                  Checkbox(
                      value: _isAgreed,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed = value!;
                        });
                      }),
                  TextButton(
                      onPressed: () {}, child: const Text('Terms of Service')),
                  const Text(' & '),
                  TextButton(
                      onPressed: () {}, child: const Text('Privacy Policy'))
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButton<String>(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  borderRadius: BorderRadius.circular(10),
                  value: _selectedAccountType,
                  items: <String>['Admin', 'Police'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedAccountType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isFormValid() ? () {
                  Auth().registerWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                      _selectedAccountType,
                      _nameController.text).then((value) {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

                        // if failed, show error on snackbar
                        // if (value == null) {
                        //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        //     content: Text('Failed to sign up'),
                        //   ));
                        // }
                      });
                } : null,
                child: Text('Sign Up'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Login'))
                ],
              )
            ],
          ),
        ),
      ),
    )));
  }
}
