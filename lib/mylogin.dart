import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final CollectionReference students =
      FirebaseFirestore.instance.collection("students");

  Future<void> login() async {

    try {

      // Find user by email and password
      QuerySnapshot result = await students
          .where('email', isEqualTo: email.text.trim())
          .where('password', isEqualTo: password.text.trim())
          .get();

      if (result.docs.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid Email or Password"),
          ),
        );

        return;
      }

      // Get user data
      var user = result.docs.first.data() as Map<String, dynamic>;

      String role = user['role'];

      //================ Role Check =================

      if (role == 'admin') {

        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
        );

      } else if (role == 'user') {

        Navigator.pushReplacementNamed(
          context,
          '/home',
        );

      }

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Login"),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [

            TextFormField(
              controller: email,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),

            TextFormField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                await login();

              },
              child: Text("Login"),
            ),

          ],
        ),
      ),
    );
  }
}