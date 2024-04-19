import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colors_app/components/button.dart';
import 'package:colors_app/components/textfield.dart';
import 'package:colors_app/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  TextEditingController _usernameController = TextEditingController();

  TextEditingController _confirmPasswordController = TextEditingController();
  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      Navigator.pop(context);
      displayMessage('Passwords do match', context);
    } else {
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim());

        createUserDoc(userCredential);
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        displayMessage(e.code, context);
      }
    }
  }

  Future<void> createUserDoc(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': _usernameController.text.trim(),
        'uid': userCredential.user!.uid,
        'colors': [],
        'favorites': [],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            SizedBox(height: 25),
            Text(
              'C O L O R S',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 25),
            MyTextField(
                obscureText: false,
                hintText: 'Username',
                controller: _usernameController),
            SizedBox(height: 10),
            MyTextField(
                obscureText: false,
                hintText: 'Email',
                controller: _emailController),
            SizedBox(height: 10),
            MyTextField(
                obscureText: true,
                hintText: 'Password',
                controller: _passwordController),
            SizedBox(height: 10),
            MyTextField(
                obscureText: true,
                hintText: 'Confirm Password',
                controller: _confirmPasswordController),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                ),
              ],
            ),
            SizedBox(height: 10),
            MyButton(
              onTap: registerUser,
              title: 'Register',
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? "),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    'Log in here!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
