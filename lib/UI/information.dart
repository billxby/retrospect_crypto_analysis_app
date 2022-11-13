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

SingleChildScrollView predictionsInfo(Color defaultColor) {
  return SingleChildScrollView(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
                height: 200,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Predictions History & Signals",
                        style: TextStyle(
                          height: 2, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                          children: <Widget> [
                            RichText(
                                text: TextSpan(
                                    text: "Predictions",
                                    style: TextStyle(
                                      height: 2,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text:" History", style: TextStyle(
                                        color: defaultColor,
                                      )),
                                    ]
                                )
                            ),
                          ]
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Past estimations of price movements made by our ML algorithm. When the line is  ",
                          children: <TextSpan>[
                            TextSpan(text: 'Green', style: TextStyle(fontWeight: FontWeight.bold, color: cGreen)),
                            const TextSpan(text: ', our algorithm rated future price movements as '),
                            TextSpan(text: 'Bullish', style: TextStyle(fontWeight: FontWeight.bold, color: cGreen)),
                            const TextSpan(text: '. When the line is '),
                            TextSpan(text: 'Red', style: TextStyle(fontWeight: FontWeight.bold, color: cRed)),
                            const TextSpan(text: ', our algorithm rated future price movements as '),
                            TextSpan(text: 'Bearish', style: TextStyle(fontWeight: FontWeight.bold, color: cRed)),
                            const TextSpan(text: '. Future price predictions do not always indicate that a trade should be made!'),
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
                height: 150,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: const <Widget>[
                          Text(
                            "Predictions ",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Signals ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          Text(
                            "History ",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          text: "This indicates trades our ML algorithm have recommended. To get alerted on these trades and see them, you have to be a  ",
                          children: <TextSpan>[
                            TextSpan(text: 'Premium Member', style: TextStyle(color: Colors.blueAccent)),
                            const TextSpan(text: '. This will guide your trading experience and give you recommendations on the next move. Pair this with Technical Analysis and you\'re set for life!'),
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
          Center(
            child: Container(
                height: 525,
                width: screenWidth * 0.93,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: "Here is how you can use the signals feature. \n",
                          style: TextStyle(
                            fontSize: 14,
                            color: defaultColor,
                          ),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      Image.asset(
                        "images/tutorials/Signals Example.png"
                      ),
                      RichText(
                        text: TextSpan(
                          text: "\nEach  ",
                          style: TextStyle(
                            fontSize: 14,
                            color: defaultColor,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: 'PlotBand', style: TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' indicates a past signal to buy or sell. This chart shows past signals in the month and wether you should buy or sell the asset. \n\nYou can also enable our exclusive '),
                            TextSpan(text: 'alerts', style: TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' for new alerts on cryptocurrencies.'),
                          ],
                        ),
                        textAlign: TextAlign.justify,
                      ),

                    ]
                )
            ),
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
