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
import 'mainpages.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  final localStorage = GetStorage();

  void _EndWelcomePage(context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Color pageBackgroundColor = localStorage.read("darkTheme") ? Colors.black12 : Colors.white;

    return Scaffold(
      body: Center(
        child: IntroductionScreen(
          showDoneButton: true,
          showSkipButton: true,
          showNextButton: true,
          next:Text("Next", style: TextStyle(color: Colors.blue)),
          skip:Text("Skip", style: TextStyle(color: Colors.blue)),
          done:Text("Done", style: TextStyle(color: Colors.blue)),
          onDone: (){
            _EndWelcomePage(context);
          },
          onSkip: (){
            _EndWelcomePage(context);
          },
          pages: [
            PageViewModel(
              image: Image.network(
                  localStorage.read("darkTheme") ? 'https://i.postimg.cc/V6PKzB1b/App-Preview-Main-Crop.png' : "https://i.postimg.cc/GtFq1p2c/App-Preview-Main-Crop-Light.png",
              ),
              title: "Welcome to Retrospect!",
              body: "Your one stop for crypto analysis. \n \n Retrospect analyzes over 500 different cryptocurrencies to give predictions and ratings based on social metrics.",
              footer: Text("Let's get started!"),
              decoration: PageDecoration(
                pageColor: pageBackgroundColor
              )
            ),
            PageViewModel(
                image: Image.network(
                    localStorage.read("darkTheme") ? 'https://i.postimg.cc/QxPnXnx8/App-Preview-Main-2-Crop.png' : "https://i.postimg.cc/x8Dt7m9x/App-Preview-Main-2-Crop-Light.png"
                ),
                title: "Metrics",
                body: "Retrospect has 3 different metrics: \n RETRO-SCORE© (Quality), Market View score(Sentiment), and predicted 24h change",
                footer: const Text("Learn more by clicking on title \"Analysis\""),
                decoration: PageDecoration(
                  pageColor: pageBackgroundColor
                )
            ),
            PageViewModel(
                image: Image.network(
                    localStorage.read("darkTheme") ? 'https://i.postimg.cc/zvqfpzKG/Settings-Page.png' : "https://i.postimg.cc/66nHZMhD/Settings-Page-Light.png"
                ),
                title: "Settings",
                body: "Go to the Settings Page to Log In and configure your app!",
                decoration: PageDecoration(
                  pageColor: pageBackgroundColor
                )
            ),
            PageViewModel(
                image: Image.asset(
                  'images/Premium Crown.gif',
                  height: 200,
                ),
                title: "Premium",
                body: "Premium gives you more than 7 analysis/day, alerts, and price history for better trading! \n \n You don't need premium to create an account.",
                footer: const Text("Learn more by clicking Upgrade", style: TextStyle(color: Colors.white)),
                decoration: const PageDecoration(
                  pageColor: Colors.black,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  bodyTextStyle: TextStyle(color: Colors.white, fontSize: 16),
                )
            ),
          ],
        ),
      )
    );
  }
}