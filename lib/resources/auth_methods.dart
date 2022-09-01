import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/models/user.dart' as model;
import 'package:instagram/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snapshot);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    Uint8List? file,
  }) async {
    String res = 'Some error occurred';
    try {
      String photoUrl;
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        // register user
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (file == null) {
          photoUrl = 'https://i.stack.imgur.com/l60Hf.png';
        } else {
          photoUrl = await StorageMethods().uploadImageToStorage(
              childName: 'profilePics', file: file, isPost: false);
        }

        model.User user = model.User(
          username: username,
          uid: credential.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
        );

        await _firestore.collection('users').doc(credential.user!.uid).set(
              user.toJson(),
            );
        res = 'success';
      }
    } catch (e) {
      res = e.toString();
      String temp;
      for (int i = 0; i < res.length; i++) {
        if (res[i] == ']') {
          temp = res.substring(i + 2, res.length);
          res = temp;
        }
      }
    }
    return res;
  }

  Future<String> logInUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        res = 'Please enter all the fields';
      }
      res = 'success';
    } catch (e) {
      res = e.toString();
      String temp;
      for (int i = 0; i < res.length; i++) {
        if (res[i] == ']') {
          temp = res.substring(i + 2, res.length);
          res = temp;
        }
      }
    }
    return res;
  }

  Future<void> signOut() async {
    _auth.signOut();
  }
}
