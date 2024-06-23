import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  User? user;

  final ImagePicker picker = ImagePicker();
  XFile? image;
  String? imageURL;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          GestureDetector(
            onTap: () => pickProfileImage(),
            child: Container(
              height: 120,
              width: 120,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: image != null
                  ? Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.person, size: 90),
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter Full Name",
              labelText: "Full Name",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: "Enter Email",
              labelText: "Email",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              hintText: "Enter Password",
              labelText: "Password",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              userSignUp();
            },
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size(230, 45)),
            ),
            child: const Text("Sign Up"),
          ),
        ],
      ),
    );
  }

  pickProfileImage() async {
    image = await picker.pickImage(source: ImageSource.camera);
    storeProfileImage();
    setState(() {});
  }

  storeProfileImage() async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final mountainsRef = storageRef.child("profile/${image!.name}");
      await mountainsRef.putFile(File(image!.path));
      imageURL = await mountainsRef.getDownloadURL();
    } catch (e) {
      debugPrint("Error ------------>>> $e ");
    }
  }

  userSignUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      user = FirebaseAuth.instance.currentUser;
      debugPrint("User data --------->> $user");

      if (!user!.emailVerified) {
        user!.sendEmailVerification();
        addUser();
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  addUser() async {
    await users
        .doc(user!.uid)
        .set({
          'user_id': user!.uid,
          'image': imageURL,
          'full_name': nameController.text,
          'email': emailController.text,
        })
        .then((value) => debugPrint("User Added"))
        .catchError((error) => debugPrint("Failed to add user: $error"));
  }
}
