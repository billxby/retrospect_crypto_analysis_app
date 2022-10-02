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
    if (localStorage.read("displayed") == true){
      return;
    }

    localStorage.write("displayed", true);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MainPages())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IntroductionScreen(
          showDoneButton: true,
          showSkipButton: true,
          showNextButton: true,
          next:Text("Next"),
          skip:Text("Skip"),
          done:Text("Done"),
          onDone: (){
            _EndWelcomePage(context);
          },
          onSkip: (){
            _EndWelcomePage(context);
          },
          pages: [
            PageViewModel(
              image: Image.network(
                  'https://i.postimg.cc/R0bW8fLD/App-Preview-Main-Crop.png',
              ),
              title: "Welcome to Retrospect!",
              body: "Your one stop for crypto analysis. \n \n Retrospect analyzes over 500 different cryptocurrencies to give predictions and ratings based on social metrics.",
              footer: Text("Let's get started!"),
              decoration: const PageDecoration(
                pageColor: Colors.black12,
              )
            ),
            PageViewModel(
                image: Image.network(
                    'https://i.postimg.cc/QxPnXnx8/App-Preview-Main-2-Crop.png'
                ),
                title: "Metrics",
                body: "Retrospect has 3 different metrics: \n RETRO-SCORE© (Quality), Market View score(Sentiment), and predicted 24h change",
                footer: const Text("Learn more by clicking on title \"Analysis\""),
                decoration: const PageDecoration(
                  pageColor: Colors.black12,
                )
            ),
            PageViewModel(
                image: Image.network(
                    'https://i.postimg.cc/MZr8Q5K4/App-Preview-Main-Bottom-Crop.png'
                ),
                title: "Navigation",
                body: "Use the Bottom Navigation Bar to make your way through the app!",
                decoration: const PageDecoration(
                  pageColor: Colors.black12,
                )
            ),
            PageViewModel(
                image: Image.network(
                  'https://i.postimg.cc/HWPrbqTn/Retrospect-Crowned.png',
                  height: 200,
                ),
                title: "Premium",
                body: "Premium gives you more than 5 analysis/day and ALERTS for better trading! \n \n You don't need premium to create an account.",
                footer: const Text("Learn more in the Premium section"),
                decoration: const PageDecoration(
                  pageColor: Colors.black12,
                )
            ),
            // PageViewModel(
            //     image: Image.network(
            //         'https://i.postimg.cc/D0PrC6Fz/Credits.png',
            //       height: 200,
            //     ),
            //     title: "Credits",
            //     body: "Credits allow you to access more than 5 analysis every day, or to get Premium for free! \n \n You can create an account without needing Premium!",
            //     footer: const Text("Learn more in the Earn section"),
            //     decoration: const PageDecoration(
            //       pageColor: Colors.black12,
            //     )
            // ),
          ],
        ),
      )
    );
  }
}