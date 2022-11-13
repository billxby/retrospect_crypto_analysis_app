import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Functions/accounts.dart';
import '../main.dart';
import 'UI helpers/style.dart';
import 'mainpages.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _logInPasswordController = TextEditingController();
  List<bool> showPasswords = [true];
  bool passwordValid = false;
  bool iUnderstand = false;

  void initState() {
    super.initState();

    _logInPasswordController.addListener(() {
      final String text = _logInPasswordController.text;
      passwordValid = text.length >= 1;
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
                    Icon(
                      Icons.warning_rounded,
                      size: screenWidth*0.2,
                      color: Colors.blue,
                    ),
                    Text("Delete my Account", style: hugeTitleStyle),
                    const SizedBox(height: 20),
                    passwordField(_logInPasswordController, 'Enter Password', 0),
                    const SizedBox(height: 120),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget> [
                          SizedBox(width: screenWidth*0.1),
                          SizedBox(
                            width: screenWidth*0.04,
                            child: Checkbox(
                              checkColor: Colors.white,
                              fillColor: const MaterialStatePropertyAll<Color>(Colors.blue),
                              value: iUnderstand,
                              splashRadius: 5,
                              shape: CircleBorder(),
                              onChanged: (bool? value) {
                                setState(() {
                                  iUnderstand = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: screenWidth*0.02),
                          const SizedBox(
                            height: 30,
                            child: Text(
                              "I understand that is action is irreversible\n and may delete my subscriptions",
                            ),
                          )
                        ]
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (passwordValid && iUnderstand) {
                          String? back = await deleteAccount(_logInPasswordController.text);

                          if (back == null) {
                            back = "Account Deleted.";
                            _logInPasswordController.text = "";
                            FirebaseAuth.instance.signOut();
                          }
                          if (back!=null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Row(
                                  children: <Widget> [
                                    Icon(back.contains("Account Deleted.") ? Icons.check_circle_outline : Icons.warning_amber_rounded, color: Colors.white),
                                    SizedBox(
                                      width: screenWidth*0.03,
                                    ),
                                    Text(back, style: TextStyle(color: Colors.white)),
                                  ]
                              ),
                              backgroundColor: back.contains("Account Deleted.") ? Colors.green : Colors.redAccent,
                            ));
                          }

                        }
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateColor.resolveWith((states) => Colors.black12),
                        backgroundColor: MaterialStatePropertyAll<Color>((passwordValid) ? Colors.red : Colors.grey),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )
                        ),
                      ),
                      child: SizedBox(
                        width: screenWidth*0.7,
                        height: 50,
                        child: Text(
                          "Delete Account",
                          style: TextStyle(color: (passwordValid) ? Colors.white : Colors.black, fontWeight: FontWeight.normal, fontSize: 20, height: 1.8,), textAlign: TextAlign.center,
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