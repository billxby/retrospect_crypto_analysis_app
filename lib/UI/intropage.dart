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

  final introdata = GetStorage();

  void _EndWelcomePage(context) {

    Navigator.pop(context);
    if (introdata.read("displayed") == true){
      return;
    }

    introdata.write("displayed", true);
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
                  'https://i.postimg.cc/kGrjYf6B/project-thumb.png'
              ),
              title: "Welcome to Retrospect!",
              body: "Look back first, then look forward. \n \n Retrospect analyzes over 500 different cryptocurrencies to give predictions and ratings based mainly on social metrics.",
              footer: Text("Let's get started!"),
              decoration: const PageDecoration(
                pageColor: Colors.black12,
              )
            ),
            PageViewModel(
                image: Image.network(
                    'https://i.postimg.cc/fZbm9zjs/Retro-Spect-Text-Transparent-Background.png'
                ),
                title: "Metrics",
                body: "Retrospect has 3 different metrics: \n RETRO-SCORE© (Quality), Market View score(Sentiment), and predicted 24h change",
                footer: const Text("Learn more in Settings -> Information -> Metrics Meaning"),
                decoration: const PageDecoration(
                  pageColor: Colors.black12,
                )
            ),
            PageViewModel(
                image: Image.network(
                    'https://i.postimg.cc/d3GhmKBN/Navigation.png'
                ),
                title: "Navigation",
                body: "Go to list to view cryptos and their analysis, Earn to earn, Premium for premium, and Settings for settings",
                decoration: const PageDecoration(
                  pageColor: Colors.black12,
                )
            ),
            PageViewModel(
                image: Image.network(
                  'https://i.postimg.cc/N0vc0vzn/Premium-Crown-Crisp.png',
                  height: 200,
                ),
                title: "Premium",
                body: "Premium allows you to access more than 5 cryptocurrency analysis each day! \n \n You don't need premium to create an account.",
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
            PageViewModel(
                image: Image.network(
                    'https://i.postimg.cc/26yTSgvq/Retro-Spect-Trans.png',
                    width: 300,
                ),
                title: "One last thing!",
                body: "Retrospect data updates every 30 minutes, because we want to provide the best quality analysis. Use a real-time price provider for real-time data. ",
                footer: Text("Enjoy!"),
                decoration: const PageDecoration(
                  pageColor: Colors.black12,
                )
            ),
          ],
        ),
      )
    );
  }
}