import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';

final localStorage = GetStorage();

Future<String?> authUser(String username, String password) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password
    );

  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      return 'Wrong password provided for that user.';
    }
    return "Please verify email";
  }

  rememberUser(username, password);

  //logged in set in main, with authStateChange() subscription
  
  return null;
}

Future<String?> signupUser(String username, String password, String confirm) async {
  if (password != confirm) return "Passwords do not match";

  if (password.length < 8) {
    return "Password must be at least 8 characters";
  }

  if (validatePasswordStrength(password) == false) {
    return "Must contain 1 digit and upper case letter";
  }

  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: username,
      password: password,
    );

    User? user = FirebaseAuth.instance.currentUser;

    final db = FirebaseFirestore.instance;

    final createAccount = <String, dynamic>{
      "credits": 0,
      "referredBy": "no one",
      "expire": 0,
    };

    db.collection("users").doc(user?.uid).set(createAccount);

    await user?.sendEmailVerification();
    return 'An email verification has been sent!';
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      return 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      return 'The account already exists for that email.';
    }
  } catch (e) {
    print(e);
    return "Something else went wrong";
  }

  rememberUser(username, password);

  //logged in set in main, with authStateChange() subscription

  return null;
}

void rememberUser(String username, String password) {
  if (rememberMe) {
    localStorage.write("username", username);
    localStorage.write("password", password);
  } else {
    localStorage.write("username", "");
    localStorage.write("password", "");
  }
}

Future<String?> sendResetPassword(String username) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: username);
  }
  on FirebaseAuthException catch (e) {
    return e.message;
  }

  return null;
}

Future<String?> updatePassword(String password, String newPassword, String confirmPassword) async {
  if (newPassword != confirmPassword) {
    return "New passwords must match";
  }

  if (newPassword.length < 8) {
    return "Password must be at least 8 characters";
  }

  if (validatePasswordStrength(newPassword) == false) {
    return "Must contain 1 digit and upper case letter";
  }

  User? user = await FirebaseAuth.instance.currentUser;
  try {
    final authResult = await user?.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: user.email ?? "none",
        password: password,
      ),
    );

    user?.updatePassword(newPassword);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      return 'Wrong password.';
    }
    return "Something else went wrong";
  }
}

Future<String?> deleteAccount(String password) async {

  User? user = await FirebaseAuth.instance.currentUser;
  try {
    final authResult = await user?.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: user.email ?? "none",
        password: password,
      ),
    );

    user?.delete();
  } on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      return 'Wrong password.';
    }
    return "Something else went wrong";
  }
}

bool validatePasswordStrength(String value){
  String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(value);
}