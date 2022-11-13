import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Functions/accounts.dart';
import '../main.dart';
import 'UI helpers/style.dart';
import 'mainpages.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmNewPasswordController = TextEditingController();
  bool passwordValid = false;
  bool newPasswordValid = false;
  bool newConfirmPasswordValid = false;
  List<bool> showPasswords = [true, true, true];

  @override
  void initState() {
    _currentPasswordController.addListener(() {
      final String text = _currentPasswordController.text;
      passwordValid = text.length >= 1;
      setState(() {});
    });
    _newPasswordController.addListener(() {
      final String text = _newPasswordController.text;
      newPasswordValid = text.length >= 1;
      setState(() {});
    });
    _confirmNewPasswordController.addListener(() {
      final String text = _confirmNewPasswordController.text;
      newConfirmPasswordValid = text.length >= 1;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Container(
                height: 420,
                width: screenWidth * 0.93,
                color: Colors.transparent,
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: <Widget> [
                    Text("Change Password", style: hugeTitleStyle),
                    const SizedBox(height: 20),
                    passwordField(_currentPasswordController, 'Current Password', 0),
                    passwordField(_newPasswordController, 'New Password', 1),
                    passwordField(_confirmNewPasswordController, 'Confirm Password', 2),
                    const SizedBox(height: 120),
                    ElevatedButton(
                      onPressed: () async {
                        if (passwordValid && newPasswordValid && newConfirmPasswordValid) {
                          String? back = await updatePassword(_currentPasswordController.text, _newPasswordController.text, _confirmNewPasswordController.text);

                          if (back == null) {
                            back = "Password Changed!";
                            _currentPasswordController.text = "";
                            _newPasswordController.text = "";
                            _confirmNewPasswordController.text = "";
                          }
                          if (back!=null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Row(
                                  children: <Widget> [
                                    Icon(back.contains("Password Changed!") ? Icons.check_circle_outline : Icons.warning_amber_rounded, color: Colors.white),
                                    SizedBox(
                                      width: screenWidth*0.03,
                                    ),
                                    Text(back, style: TextStyle(color: Colors.white)),
                                  ]
                              ),
                              backgroundColor: back.contains("Password Changed!")? Colors.green : Colors.redAccent,
                            ));
                          }

                        }
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateColor.resolveWith((states) => Colors.black12),
                        backgroundColor: MaterialStatePropertyAll<Color>((passwordValid && newPasswordValid && newConfirmPasswordValid) ? Colors.white : Colors.grey),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )
                        ),
                      ),
                      child: SizedBox(
                        width: screenWidth*0.7,
                        height: 50,
                        child: const Text(
                          "Reset Password",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20, height: 1.8,), textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox passwordField(TextEditingController controller, String text, int showIdx) {
    return SizedBox(
      width: screenWidth*0.8,
      child: TextFormField(
        controller: controller,
        obscureText: showPasswords[showIdx],
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: text,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary,),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary,),
          ),
          suffixIcon: TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
            ),
            onPressed: () {
              setState(() {
                showPasswords[showIdx] = !showPasswords[showIdx];
              });
            },
            child: Text(
              showPasswords[showIdx] ? "show" : "hide",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, height: 3),
            ),
          ),
        ),
      ),
    );
  }
}