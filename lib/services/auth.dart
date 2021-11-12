import 'package:chatapp/helper/authenticate.dart';
import 'package:chatapp/helper/helperfunctions.dart';
import 'package:chatapp/models/user.dart';
import 'package:chatapp/views/chat.dart';
import 'package:chatapp/views/chatrooms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      if (!user.isEmailVerified) {
        return null;
      }
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      await user.sendEmailVerification();
      return _userFromFirebaseUser(user);
    } on PlatformException catch (e) {
      print(e.message);
      Fluttertoast.showToast(
          msg: e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return null;
    }
  }

  Future resetPass(String email) async {
      return await _auth.sendPasswordResetEmail(email: email);
  }

  saveUserToSharePreference(QuerySnapshot userInfoSnapshot) {
    HelperFunctions.saveUserLoggedInSharedPreference(true);
    HelperFunctions.saveUserNameSharedPreference(
        userInfoSnapshot.documents[0].data["userName"]);
    HelperFunctions.saveUserEmailSharedPreference(
        userInfoSnapshot.documents[0].data["userEmail"]);
  }

  signInWithGoogle(BuildContext context) async {
    final GoogleSignIn _googleSignIn = new GoogleSignIn();
    try {
      final GoogleSignInAccount googleSignInAccount =
      await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken
      );

      AuthResult result = await _auth.signInWithCredential(credential);
      FirebaseUser userDetails = result.user;
      DatabaseMethods databaseMethods = new DatabaseMethods();
      Map<String, String> userDataMap = {
        "userName": userDetails.email.substring(0, userDetails.email.indexOf("@")),
        "userEmail": userDetails.email,
        "uid": userDetails.uid
      };

      QuerySnapshot userWithEmail = await databaseMethods.getUserInfo(userDetails.email);
      if(userWithEmail.documents.isEmpty) {
        await databaseMethods.addUserInfo(userDataMap);
        saveUserToSharePreference(userWithEmail);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom()));
        return;
      }

      if(userWithEmail.documents[0].data['uid'] == "") {
        Fluttertoast.showToast(
            msg: "Your email has already register in our app, please try login with this email!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate()));
        return;
      }
      saveUserToSharePreference(userWithEmail);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom()));

    }
    catch(e) {
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      var prefManager = await SharedPreferences.getInstance();
      await prefManager.clear();
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
