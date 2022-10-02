import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Functions/accounts.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _logInUsernameController = TextEditingController();
  final TextEditingController _logInPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool emailValid = false;
  bool passwordValid = false;
  bool confirmPasswordValid = false;
  List<bool> showPasswords = [true, true];
  bool isRegisterPage = false;
  bool isForgotPasswordPage = false;

  final localStorage = GetStorage();

  @override
  void initState() {
    super.initState();

    _logInUsernameController.addListener(() {
      final String text = _logInUsernameController.text;
      emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
      setState(() {});
    });
    _logInPasswordController.addListener(() {
      final String text = _logInPasswordController.text;
      passwordValid = text.length >= 1;
      setState(() {});
    });
    _confirmPasswordController.addListener(() {
      final String text = _confirmPasswordController.text;
      confirmPasswordValid = text.length >= 1;
      setState(() {});
    });

    _logInUsernameController.text = localStorage.read("username");
    _logInPasswordController.text = localStorage.read("password");
  }

  @override
  Widget build(BuildContext context) {
    if (loggedIn == false) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Log In'),
          centerTitle: true,
          toolbarHeight: 40,
        ),
        body: SingleChildScrollView(
            child: isRegisterPage ?  registerPage() : (isForgotPasswordPage ? forgotPasswordPage() : loginPage())
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: Center(
        child: Column(
          children: const <Widget> [
            Icon(
              Icons.check_circle,
              color: Colors.blue,
            ),
            Text("You are now Logged In!", style: TextStyle(fontSize: 15)),
          ]
        )
      ),
    );

  }

  Center registerPage() {
    return Center(
      child: Column(
        children: <Widget> [
          SizedBox(height: 70),
          Text("Welcome!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
          Image.asset(
            "images/Full Logo.png",
            width: screenWidth*0.6,
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: screenWidth*0.8,
            child: TextFormField(
              controller: _logInUsernameController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
          ),
          passwordField('Password', _logInPasswordController, 0),
          passwordField('Confirm Password', _confirmPasswordController, 1),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget> [
                SizedBox(width: screenWidth*0.1),
                SizedBox(
                  width: screenWidth*0.04,
                  child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: const MaterialStatePropertyAll<Color>(Colors.blue),
                    value: rememberMe,
                    splashRadius: 5,
                    shape: CircleBorder(),
                    onChanged: (bool? value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: screenWidth*0.02),
                const Text(
                  "Remember me",
                ),
              ]
          ),
          const SizedBox(
            height: 120,
          ),
          RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[400]),
                children: <TextSpan> [
                  const TextSpan(text: 'By Signing up, you agree to our '),
                  TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: Colors.white),
                      recognizer: TapGestureRecognizer()..onTap = () async {
                        await launchUrl(Uri.parse("https://www.retrospectapps.com/privacy-policy.html"));
                      }
                  ),
                ],
              )
          ),
          const SizedBox(height:3),
          ElevatedButton(
            onPressed: () async {
              if ((emailValid == true) && (passwordValid==true) && (confirmPasswordValid==true)) {
                String? back = await signupUser(_logInUsernameController.text, _logInPasswordController.text, _confirmPasswordController.text);
                if (back == null) {
                  _logInUsernameController.text = "";
                  _logInPasswordController.text = "";
                  _confirmPasswordController.text = "";
                  setState(() {});
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(
                        children: <Widget> [
                          Icon(Icons.warning_amber_rounded, color: Colors.white),
                          SizedBox(
                            width: screenWidth*0.03,
                          ),
                          Text(back, style: TextStyle(color: Colors.white)),
                        ]
                    ),
                    backgroundColor: back.contains("An email verification has been sent!") ? Colors.green : Colors.redAccent,
                  ));
                }
              }
            },
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith((states) => Colors.black12),
              backgroundColor: MaterialStatePropertyAll<Color>((emailValid == true) && (passwordValid==true) && (confirmPasswordValid==true) ? Colors.white : Colors.grey),
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
                "Sign Up",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20, height: 1.8,), textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isRegisterPage = !isRegisterPage;
              });
            },
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith((states) => Colors.white24),
              backgroundColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  )
              ),
            ),
            child: SizedBox(
              width: screenWidth*0.7,
              height: 40,
              child: const Text(
                "Back",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 18, height: 1.8,), textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  Center loginPage() {
    return Center(
      child: Column(
        children: <Widget> [
          SizedBox(height: 70),
          Image.asset(
            "images/Full Logo.png",
            width: screenWidth*0.6,
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: screenWidth*0.8,
            child: TextFormField(
              controller: _logInUsernameController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
          ),
          passwordField('Password', _logInPasswordController, 0),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget> [
                SizedBox(width: screenWidth*0.1),
                SizedBox(
                  width: screenWidth*0.04,
                  child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: const MaterialStatePropertyAll<Color>(Colors.blue),
                    value: rememberMe,
                    splashRadius: 5,
                    shape: CircleBorder(),
                    onChanged: (bool? value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: screenWidth*0.02),
                const Text(
                  "Remember me",
                ),
                SizedBox(width: screenWidth*0.2),
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                  ),
                  onPressed: () {
                    setState(() {
                      isForgotPasswordPage = !isForgotPasswordPage;
                    });
                  },
                  child: const Text("Forgot password?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                ),

              ]
          ),
          const SizedBox(
            height: 180,
          ),
          RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[400]),
                children: <TextSpan> [
                  const TextSpan(text: 'By Logging In, you agree to our '),
                  TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: Colors.white),
                      recognizer: TapGestureRecognizer()..onTap = () async {
                        await launchUrl(Uri.parse("https://www.retrospectapps.com/privacy-policy.html"));
                      }
                  ),
                ],
              )
          ),
          const SizedBox(height:3),
          ElevatedButton(
            onPressed: () async {
              if ((emailValid == true) && (passwordValid==true)) {
                String? back = await authUser(_logInUsernameController.text, _logInPasswordController.text);
                if (back == null) {
                  _logInUsernameController.text = "";
                  _logInPasswordController.text = "";
                  Navigator.pop(context);
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(
                        children: <Widget> [
                          Icon(Icons.warning_amber_rounded, color: Colors.white),
                          SizedBox(
                            width: screenWidth*0.03,
                          ),
                          Text(back, style: TextStyle(color: Colors.white)),
                        ]
                    ),
                    backgroundColor: Colors.redAccent,
                  ));
                }

              }
            },
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith((states) => Colors.black12),
              backgroundColor: MaterialStatePropertyAll<Color>((emailValid == true) && (passwordValid==true) ? Colors.white : Colors.grey),
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
                "Log In",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20, height: 1.8,), textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isRegisterPage = !isRegisterPage;
              });
            },
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith((states) => Colors.white24),
              backgroundColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  )
              ),
            ),
            child: SizedBox(
              width: screenWidth*0.7,
              height: 40,
              child: const Text(
                "Register",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 18, height: 1.8,), textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  Center forgotPasswordPage() {
    return Center(
      child: Column(
        children: <Widget> [
          const SizedBox(height: 70),
          const Text("Reset your password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: screenWidth*0.8,
            child: TextFormField(
              controller: _logInUsernameController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
          ),
          const SizedBox(
            height: 180,
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailValid == true) {
                String? back = await sendResetPassword(_logInUsernameController.text);
                if (back == null) {

                  back = "An email has been sent to ${_logInUsernameController.text}";
                  _logInUsernameController.text = "";
                }
                if (back!=null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(
                        children: <Widget> [
                          Icon(Icons.warning_amber_rounded, color: Colors.white),
                          SizedBox(
                            width: screenWidth*0.03,
                          ),
                          Text(back, style: TextStyle(color: Colors.white)),
                        ]
                    ),
                    backgroundColor: back.contains("An email has been sent to ")? Colors.green : Colors.redAccent,
                  ));
                }

              }
            },
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith((states) => Colors.black12),
              backgroundColor: MaterialStatePropertyAll<Color>((emailValid == true) ? Colors.white : Colors.grey),
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
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isForgotPasswordPage = !isForgotPasswordPage;
              });
            },
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith((states) => Colors.white24),
              backgroundColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  )
              ),
            ),
            child: SizedBox(
              width: screenWidth*0.7,
              height: 40,
              child: const Text(
                "Back",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 18, height: 1.8,), textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  SizedBox passwordField(String text, TextEditingController controller, int showIdx) {
    return SizedBox(
      width: screenWidth*0.8,
      child: TextFormField(
        controller: controller,
        obscureText: showPasswords[showIdx],
        decoration: InputDecoration(
          labelText: text,
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