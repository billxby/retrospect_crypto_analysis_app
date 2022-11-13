import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';

import '../main.dart';
import 'cryptosearchdelegate.dart';
import 'login_page.dart';
import 'mainpages.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {

  final localStorage = GetStorage();
  late TabController _tabController;

  void _EndWelcomePage(context) {

    Navigator.pop(context);
    if (localStorage.read("displayed") == true){
      return;
    }

    localStorage.write("displayed", true);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MainPages())
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Center(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Column(
                children: [
                  Spacer(flex: 6),
                  Image.asset(
                    "images/welcome/Welcome Screen.png",
                    width: screenWidth*0.8,
                  ),
                  Spacer(flex: 2),
                  Text("Welcome to Retrospect.", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Spacer(flex: 2),
                  Text("predicting and analyzing your\nfavorite coins in real time", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  Spacer(flex: 14),
                  TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        _tabController.index = 1;
                      },
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Next", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 15,
                        ),
                      ],)
                  ),
                  Spacer(flex: 4),
                ],
              ),
              Column(
                children: [
                  Spacer(flex: 15),
                  Image.asset(
                    localStorage.read("darkTheme") ? "images/welcome/Welcome 2 Dark.png" : "images/welcome/Welcome 2 Light.png",
                    width: screenWidth*0.8,
                  ),
                  Spacer(flex: 2),
                  Text("Let’s get started.", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Spacer(flex: 2),
                  Text("create an account to keep a watchlist, \nget alerts, access in-depth analysis, and more!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  Spacer(flex: 16),
                  signUpButton("Sign Up", Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.primary),
                  Spacer(),
                  signUpButton("Log In", Theme.of(context).colorScheme.secondaryVariant, localStorage.read("darkTheme") ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary),
                  Spacer(flex: 4),
                  TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {_tabController.index = 2;},
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Skip", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 15,
                        ),
                      ],)
                  ),
                  Spacer(flex: 4),
                ],
              ),
              Column(
                children: [
                  Spacer(flex: 15),
                  Image.asset(
                    localStorage.read("darkTheme") ? "images/welcome/Welcome 3 Dark.png" : "images/welcome/Welcome 3 Light.png",
                    width: screenWidth*0.8,
                  ),
                  Spacer(flex: 2),
                  Text("Add your favorite cryptos.", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Spacer(flex: 2),
                  Text("now, let’s add your favorite coins\nwe support over 500+ cryptos", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  Spacer(flex: 11),
                  OutlinedButton(
                      onPressed: () async {
                        showSearch(
                          context: context,
                          delegate: CryptosSearchDelegateStars(CryptosList),
                        ).then((_)=>{
                          _EndWelcomePage(context)
                        });

                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            )
                        ),
                        backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.secondary),
                      ),
                      child: SizedBox(
                        width: 140,
                        height: 25,
                        child: Text("Add my coins", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary, height: 1.3)),
                      )
                  ),
                  Spacer(flex: 10),
                  TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {_EndWelcomePage(context);},
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Skip", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 15,
                        ),
                      ],)
                  ),
                  Spacer(flex: 4),
                ],
              ),
            ],
          )
        )
    );
  }

  OutlinedButton signUpButton(String mode, Color backgroundColor, Color textColor) {
    return OutlinedButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          ).then((_)=>{
            if (loggedIn) {
              _tabController.index = 2
            }
          });
          return;
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              )
          ),
          backgroundColor: MaterialStatePropertyAll<Color>(backgroundColor),
        ),
        child: SizedBox(
          width: 140,
          height: 25,
          child: Text(mode, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: textColor, height: 1.3)),
        )
    );
  }
}