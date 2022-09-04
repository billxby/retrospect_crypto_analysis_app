import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:settings_ui/settings_ui.dart';
import 'cryptosearchdelegate.dart';
import "detailspage.dart";
import '../Functions/cryptoinfoclass.dart';
import 'package:get/get.dart';

class Information extends StatelessWidget {
  const Information({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final introdata = GetStorage();
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
                              SizedBox(
                                height: 40,
                                width: 30,
                                child: Image.network(
                                  'https://i.postimg.cc/sDw49xXG/Retro-Spect-Trans.png',
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Text(
                                "ETRO",
                                style: TextStyle(
                                  height: 2,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              const Text(
                                "-SCORE©: ",
                                style: TextStyle(
                                  height: 2,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          RichText(
                            text: const TextSpan(
                              text: "A metric indicating a cryptocurrency's quality based on social metrics, such as Twitter Activity and Github Activity. The higher the better. When close to ",
                              children: <TextSpan>[
                                TextSpan(text: '100 it\'s excellent', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                                TextSpan(text: ', and close '),
                                TextSpan(text: '-100 it\'s horrible.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                              ],
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ])),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                    height: 90,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: const <Widget>[
                              Text(
                                "Market ",
                                style: TextStyle(
                                    height: 2,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "View ",
                                style: TextStyle(
                                  height: 2,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              Text(
                                "score: ",
                                style: TextStyle(
                                    height: 2,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Text(
                            "A metric indicating investors' view of a cryptocurrency. It is determined by compiling tweets sentiment analysis for each cryptocurrency. ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ])),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    height: 130,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget> [
                              Image.network(
                                'https://i.postimg.cc/SNcFQTHG/bull.png',
                                height: 30,
                                width: 30,
                              ),
                              const Text(
                                " Predicted Change (24h) ",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'https://i.postimg.cc/0yxgzGs1/bear.png',
                                height: 30,
                                width: 30,
                              ),
                            ]
                          ),
                          RichText(
                            text: const TextSpan(
                              text: "A metric indicating the market view of the cryptocurrency in the next 24h according to our ",
                              children: <TextSpan>[
                                TextSpan(text: '91%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue)),
                                TextSpan(text: ' accurate model (according to back tests).'),
                              ],
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            textAlign: TextAlign.justify,
                          )

                        ])),
              ),
              const SizedBox(
                height: 90,
              ),
              Center(
                child: Image.network(
                  'https://i.postimg.cc/vT8WhZ52/Retrospect-Text-Outline.png'
                ),
              ),
              const SizedBox(
                height: 500,
              ),
              const Center(
                child: Text(
                  "Still scrolling? lol 😀",
                ),
              ),
              Center(
                child: Text(
                  "Forgot password? It's ${introdata.read("password")}",
                ),
              )
            ]),
      ),
    );
  }
}
