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
      MaterialPageRoute(builder: (_)=>MainPages())
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
              body: "Look back first, then look forward.",
              footer: Text("Let's get started!"),
              decoration: const PageDecoration(
                pageColor: Colors.black12,
              )
            ),
            PageViewModel(
                image: Image.network(
                    'https://i.postimg.cc/90GL6ZZ1/traffic-thumb.png'
                ),
                title: "How does Retrospect work?",
                body: "Retrospect analyzes over 500 different cryptocurrencies to give predictions and ratings based mainly on social metrics.",
                footer: Text("Learn more in Settings -> Information -> Metrics Meaning"),
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
                    'https://i.postimg.cc/mk5x80fC/Navigation.png'
                ),
                title: "Navigation",
                body: "Go to list to view cryptos and their analysis, settings for... Settings!",
                decoration: const PageDecoration(
                  pageColor: Colors.black12,
                )
            ),
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