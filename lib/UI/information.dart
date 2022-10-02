import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:settings_ui/settings_ui.dart';
import '../main.dart';
import 'UI helpers/style.dart';
import 'cryptosearchdelegate.dart';
import "detailspage.dart";
import '../Functions/cryptoinfoclass.dart';
import 'package:get/get.dart';

SingleChildScrollView analysisInfo(Color defaultColor) {
  return SingleChildScrollView(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
                height: 155,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Analysis Metrics",
                        style: TextStyle(
                          height: 2, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                          children: <Widget> [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Image.network(
                                'https://i.postimg.cc/6QCj5gVx/R-for-Retrospect-in-App.png',
                                fit: BoxFit.cover,
                                height: 26,
                              ),
                            ),
                            RichText(
                                text: TextSpan(
                                    text: "etro",
                                    style: blueRetroTitleStyle,
                                    children: <TextSpan>[
                                      TextSpan(text:"-Score©", style: TextStyle(
                                        height: 2,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: defaultColor,
                                      )),
                                    ]
                                )
                            ),
                          ]
                      ),
                      RichText(
                        text: TextSpan(
                          text: "A metric indicating a cryptocurrency's quality based on social metrics, such as Twitter Activity and Github Activity. The higher the better. When close to ",
                          children: <TextSpan>[
                            TextSpan(text: '100 it\'s excellent', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[100])),
                            const TextSpan(text: ', and close '),
                            TextSpan(text: '-100 it\'s horrible.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[100])),
                          ],
                          style: TextStyle(
                            fontSize: 14,
                            color: defaultColor,
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
                height: 80,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: const <Widget>[
                          Text(
                            "Market ",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "View ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          Text(
                            "score: ",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        "A metric indicating investors' view of a cryptocurrency. It is determined by compiling tweets sentiment analysis for each cryptocurrency. ",
                        style: TextStyle(
                          fontSize: 14,
                          color: defaultColor,
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
                height: 130,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                          children: <Widget> [
                            const Text(
                              "Prediction (24h) ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ]
                      ),
                      RichText(
                        text: TextSpan(
                          text: "A metric indicating the market view of the cryptocurrency in the next 24h according to our ",
                          children: <TextSpan>[
                            TextSpan(text: '91%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue)),
                            TextSpan(text: ' accurate model (according to back tests).'),
                          ],
                          style: TextStyle(
                            fontSize: 14,
                            color: defaultColor,
                          ),
                        ),
                        textAlign: TextAlign.justify,
                      )

                    ])),
          ),
        ]),
  );
}

SingleChildScrollView marketStatsInfo(Color defaultColor) {
  return SingleChildScrollView(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
                height: 150,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Market Stats",
                        style: TextStyle(
                          height: 2, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Market Cap",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Market Cap = Current Price x Circulating Supply \n\nTotal market value of a cryptocurrency’s circulating supply. ",
                          style: TextStyle(
                            fontSize: 14,
                            color: defaultColor,
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
                height: 70,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Volume (24h)",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "A measure of a cryptocurrency trading volume across all tracked platforms in the last 24 hours. ",
                          style: TextStyle(
                            fontSize: 14,
                            color: defaultColor,
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
                height: 80,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Total supply",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "The amount of coins that have already been created, minus any coins that have been burned (removed from circulation). ",
                          style: TextStyle(
                            fontSize: 14,
                            color: defaultColor,
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
                height: 80,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "All-time high",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Highest value of the cryptocurrency during its lifetime. ",
                          style: TextStyle(
                            fontSize: 14,
                            color: defaultColor,
                          ),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ])),
          ),
        ]),
  );
}
