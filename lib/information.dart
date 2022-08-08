import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:settings_ui/settings_ui.dart';
import 'cryptosearchdelegate.dart';
import "detailspage.dart";
import 'cryptoinfoclass.dart';
import 'package:get/get.dart';

class Information extends StatelessWidget {
  const Information({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('General Information'),
        centerTitle: true,
        toolbarHeight: 35,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    height: 120,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Image.network(
                                'https://i.postimg.cc/sDw49xXG/Retro-Spect-Trans.png',
                                height: 20,
                                width: 20,
                              ),
                              Text(
                                "RETRO-SCORE©",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ]),
                          Text(
                            "A metric indicating a cryptocurrency's quality based on social metrics, such as Twitter Activity and Github Activity. The score ranges from the higher the better. Anything above 100 is excellent, and below -100 is horrible.",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ])),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    height: 90,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            "MarketView Score",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "A metric indicating investors' view of a cryptocurrency. It is determined by compiling tweets for each cryptocurrency. ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ])),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    height: 70,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            "Predicted Change (24h)",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "A metric indicating the view of the cryptocurrency in the next 24h according to our model. ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ])),
              ),
              const SizedBox(
                height: 90,
              ),
              Center(
                child: Image.network(
                  'https://i.postimg.cc/vT8WhZ52/Retrospect-Text-Outline.png'
                ),
              )
            ]),
      ),
    );
  }
}
