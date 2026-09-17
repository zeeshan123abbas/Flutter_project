import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  //================ Controllers =================

  TextEditingController name = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  //================ Firestore =================

  final CollectionReference students =
      FirebaseFirestore.instance.collection("students");

  //================ Add User =================

  Future<void> adduser(BuildContext context) async {

    await students.add({
      'name': name.text.trim(),
      'age': int.parse(age.text.trim()),
      'email': email.text.trim(),
      'password': password.text.trim(),

      // Default role
      'role': 'user',
    });

    Navigator.pushNamed(context, '/mylogin');
  }

  //================ UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextFormField(
              controller: name,
              decoration: InputDecoration(
                labelText: "Name",
              ),
            ),

            TextFormField(
              controller: age,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Age",
              ),
            ),

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

                await adduser(context);

              },

              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}