import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'main.dart';

class DetailsPage extends StatefulWidget {
  final int passedIndex;

  const DetailsPage({Key? key, required this.passedIndex}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    Color twentyFourColor = Colors.green;
    Color scoreColor = Colors.green;
    Color predictionColor = Colors.green;
    Color tweetsColor = Colors.green;
    Color commitsColor = Colors.green;
    Color marketViewColor = Colors.green;
    double startScore = 0, endScore = 0, scoreStart = -100, scoreEnd = 100;
    double startMarketview = 0, endMarketview = 9, marketviewStart = -100, marketviewEnd = 100;
    double percentageTw = double.parse(TopCryptos[widget.passedIndex].tweets)/100.abs() > 1 ? 1 : double.parse(TopCryptos[widget.passedIndex].tweets)/100.abs();
    double percentageCm = double.parse(TopCryptos[widget.passedIndex].commits)/100.abs() > 1 ? 1 : double.parse(TopCryptos[widget.passedIndex].commits)/100.abs();
    //make sure they're not neg
    percentageTw = percentageTw.abs();
    percentageCm = percentageCm.abs();
    String predUrl = "https://i.postimg.cc/SNcFQTHG/bull.png";

    String beforeTw = "+", beforeCm = "+";
    String afterTw = "", afterCm = "";

    if (TopCryptos[widget.passedIndex].score != "updating database") {
      if (double.parse(TopCryptos[widget.passedIndex].score) >= 0) {
        endScore = double.parse(TopCryptos[widget.passedIndex].score) <= 100 ? double
            .parse(TopCryptos[widget.passedIndex].score) : 100;
      }
      else {
        startScore =
        double.parse(TopCryptos[widget.passedIndex].score) >= -100 ? double
            .parse(TopCryptos[widget.passedIndex].score) : -100;
      }

      if (double.parse(TopCryptos[widget.passedIndex].score) < 40 &&
          double.parse(TopCryptos[widget.passedIndex].score) > -40) {
        scoreStart = -50;
        scoreEnd = 50;
      }

      if (double.parse(TopCryptos[widget.passedIndex].score) < 20 &&
          double.parse(TopCryptos[widget.passedIndex].score) > -20) {
        scoreStart = -25;
        scoreEnd = 25;
      }

      if (double.parse(TopCryptos[widget.passedIndex].score) < 8 &&
          double.parse(TopCryptos[widget.passedIndex].score) > -8) {
        scoreStart = -15;
        scoreEnd = 15;
      }

      if (double.parse(TopCryptos[widget.passedIndex].score) < 4 &&
          double.parse(TopCryptos[widget.passedIndex].score) > -4) {
        scoreStart = -10;
        scoreEnd = 10;
      }
    }

    if (TopCryptos[widget.passedIndex].marketView != "updating database") {
      if (double.parse(TopCryptos[widget.passedIndex].marketView) >= 0) {
        endMarketview = double.parse(TopCryptos[widget.passedIndex].marketView) <= 100 ? double
            .parse(TopCryptos[widget.passedIndex].marketView) : 100;
      }
      else {
        startMarketview =
        double.parse(TopCryptos[widget.passedIndex].marketView) >= -100 ? double
            .parse(TopCryptos[widget.passedIndex].marketView) : -100;
      }

      if (double.parse(TopCryptos[widget.passedIndex].marketView) < 40 &&
          double.parse(TopCryptos[widget.passedIndex].marketView) > -40) {
        marketviewStart = -50;
        marketviewEnd = 50;
      }

      if (double.parse(TopCryptos[widget.passedIndex].marketView) < 20 &&
          double.parse(TopCryptos[widget.passedIndex].marketView) > -20) {
        marketviewStart = -25;
        marketviewEnd = 25;
      }

      if (double.parse(TopCryptos[widget.passedIndex].marketView) < 8 &&
          double.parse(TopCryptos[widget.passedIndex].marketView) > -8) {
        marketviewStart = -15;
        marketviewEnd = 15;
      }

      if (double.parse(TopCryptos[widget.passedIndex].marketView) < 4 &&
          double.parse(TopCryptos[widget.passedIndex].marketView) > -4) {
        marketviewStart = -10;
        marketviewEnd = 10;
      }
    }

    if (TopCryptos[widget.passedIndex].price_change_precentage_24h != null) {
      if (TopCryptos[widget.passedIndex]
          .price_change_precentage_24h
          .contains("-")) twentyFourColor = Colors.red;
    }
    if (TopCryptos[widget.passedIndex].prediction != null) {
      if (TopCryptos[widget.passedIndex].prediction.contains("Bearish")) {
        predictionColor = Colors.red;
        predUrl = "https://i.postimg.cc/0yxgzGs1/bear.png";
      }
      if (TopCryptos[widget.passedIndex].prediction.contains("Neutral")) {
        predUrl = "";
      }
    }
    if (TopCryptos[widget.passedIndex].score != null) {
      if (TopCryptos[widget.passedIndex].score.contains("-"))
        scoreColor = Colors.red;
    }
    if (TopCryptos[widget.passedIndex].tweets != null) {
      if (TopCryptos[widget.passedIndex].tweets.contains("-")) {
        beforeTw = "";
        tweetsColor = Colors.red;
      }
      if (int.parse(TopCryptos[widget.passedIndex].tweets) > 100) {
        afterTw = "!";
        tweetsColor = Colors.lightBlue;
      }
    }
    if (TopCryptos[widget.passedIndex].commits != null) {
      if (TopCryptos[widget.passedIndex].commits.contains("-")) {
        beforeCm = "";
        commitsColor = Colors.red;
      }
      if (int.parse(TopCryptos[widget.passedIndex].commits) > 100) {
        afterCm = "!";
        commitsColor = Colors.lightBlue;
      }
    }
    if (TopCryptos[widget.passedIndex].marketView != null) {
      if (TopCryptos[widget.passedIndex].marketView.contains("-"))
        marketViewColor = Colors.red;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(TopCryptos[widget.passedIndex].id),
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
                    height: 230,
                    width: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          color: darkTheme ? Colors.white : Colors.black),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Column(children: <Widget>[
                      Row(
                        children: <Widget>[
                          Image.network(
                            TopCryptos[widget.passedIndex].image,
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(
                            width: 20,
                            height: 10,
                          ),
                          Expanded(
                            child: Text(
                              TopCryptos[widget.passedIndex].id,
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            TopCryptos[widget.passedIndex].current_price +
                                "  | ",
                            style: const TextStyle(height: 2, fontSize: 15),
                          ),
                          const SizedBox(
                            width: 4,
                            height: 1,
                          ),
                          const Text(
                            "24h: ",
                            style: TextStyle(
                                height: 2,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            TopCryptos[widget.passedIndex]
                                .price_change_precentage_24h,
                            style: TextStyle(
                              height: 2.2,
                              fontSize: 14,
                              color: twentyFourColor,
                            ),
                          ),
                          Text(
                            "%",
                            style: TextStyle(
                              height: 2.2,
                              fontSize: 12,
                              color: twentyFourColor,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                            height: 1,
                          ),
                          const Text(
                            "| Mrkt Cap: ",
                            style: TextStyle(
                                height: 2,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            TopCryptos[widget.passedIndex].market_cap,
                            style: const TextStyle(
                              height: 2.2,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                            height: 1,
                          ),
                          const Text(
                            "| Vol: ",
                            style: TextStyle(
                                height: 2,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            TopCryptos[widget.passedIndex].total_volume,
                            style: const TextStyle(
                              height: 2.2,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(children: <Widget>[
                        const Text(
                          "24h Hi: ",
                          style: TextStyle(
                              height: 2,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          TopCryptos[widget.passedIndex].high_24h,
                          style: const TextStyle(height: 2, fontSize: 15),
                        ),
                        const SizedBox(
                          width: 4,
                          height: 1,
                        ),
                        const Text(
                          "| 24h Low: ",
                          style: TextStyle(
                              height: 2,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          TopCryptos[widget.passedIndex].low_24h,
                          style: const TextStyle(height: 2, fontSize: 15),
                        ),
                        const SizedBox(
                          width: 4,
                          height: 1,
                        ),
                        const Text(
                          "| ATH: ",
                          style: TextStyle(
                              height: 2,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          TopCryptos[widget.passedIndex].ath,
                          style: const TextStyle(height: 2, fontSize: 15),
                        ),
                      ]),
                      Row(children: const <Widget>[
                        Text(
                          "Additional Information:",
                          style: TextStyle(
                              height: 2,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ]),
                      Row(children: <Widget>[
                        const Text(
                          " Mrkt Cap Rank: ",
                          style: TextStyle(
                            height: 1,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          TopCryptos[widget.passedIndex].market_cap_rank,
                          style: const TextStyle(
                              height: 1,
                              fontSize: 15,
                              fontStyle: FontStyle.italic),
                        ),
                      ]),
                      Row(children: <Widget>[
                        const Text(
                          " Total Supply: ",
                          style: TextStyle(
                            height: 1,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          TopCryptos[widget.passedIndex].total_supply,
                          style: const TextStyle(
                              height: 1.2,
                              fontSize: 15,
                              fontStyle: FontStyle.italic),
                        ),
                      ]),
                      Row(children: <Widget>[
                        const Text(
                          " Symbol: ",
                          style: TextStyle(
                            height: 1,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          TopCryptos[widget.passedIndex].symbol,
                          style: const TextStyle(
                              height: 1.2,
                              fontSize: 15,
                              fontStyle: FontStyle.italic),
                        ),
                      ]),
                      const SizedBox(
                        height: 29,
                      ),
                      Text(
                        "last updated: " +
                            (TopCryptos[widget.passedIndex].last_updated),
                        style: TextStyle(fontSize: 9),
                      ),
                    ])),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                  child: Container(
                height: 600,
                width: 350,
                child: Column(children: <Widget>[
                  const Center(
                      child: Text(
                    "Analysis",
                    style: TextStyle(
                        height: 2, fontSize: 22, fontWeight: FontWeight.bold),
                  )),
                  Row(
                    children: <Widget>[
                      Container(
                        child: Image.network(
                          'https://i.postimg.cc/sDw49xXG/Retro-Spect-Trans.png',
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                        ),
                        height: 30,
                        width: 20,
                      ),
                      const Text(
                        "ETRO",
                        style: TextStyle(
                            height: 2,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                        ),
                      ),
                      const Text(
                        "-SCORE©: ",
                        style: TextStyle(
                          height: 2,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        TopCryptos[widget.passedIndex].score == "updating database" ? TopCryptos[widget.passedIndex].score : double.parse(TopCryptos[widget.passedIndex].score).toStringAsFixed(3),
                        style: TextStyle(
                          height: 2.2,
                          fontSize: 14,
                          color: scoreColor,

                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  SfLinearGauge(
                    minimum: scoreStart,
                    maximum: scoreEnd,
                    ranges: <LinearGaugeRange> [
                      LinearGaugeRange(
                        startValue: 0, endValue: scoreEnd, color: Color(0xffabf7c1), position: LinearElementPosition.inside,
                      ),
                      LinearGaugeRange(
                        startValue: scoreStart, endValue:0, color: Color(0xfff7abab), position: LinearElementPosition.inside,
                      ),
                      LinearGaugeRange(
                        startValue: startScore, endValue: endScore, color: Colors.blue, position: LinearElementPosition.cross,
                      ),
                    ],
                    markerPointers: [
                      LinearShapePointer(
                        value: startScore == 0 ? endScore : startScore,
                        animationType: LinearAnimationType.ease,
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Text(
                        "Market ",
                        style: TextStyle(
                            height: 2,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "View ",
                        style: TextStyle(
                            height: 2,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                        ),
                      ),
                      const Text(
                        "score: ",
                        style: TextStyle(
                            height: 2,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        TopCryptos[widget.passedIndex].marketView == "updating database" ? TopCryptos[widget.passedIndex].marketView : double.parse(TopCryptos[widget.passedIndex].marketView).toStringAsFixed(3),
                        style: TextStyle(
                          height: 2.2,
                          fontSize: 14,
                          color: marketViewColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  SfLinearGauge(
                    minimum: marketviewStart,
                    maximum: marketviewEnd,
                    ranges: <LinearGaugeRange> [
                      LinearGaugeRange(
                        startValue: 0, endValue: marketviewEnd, color: Color(0xffabf7c1), position: LinearElementPosition.inside,
                      ),
                      LinearGaugeRange(
                        startValue: marketviewStart, endValue:0, color: Color(0xfff7abab), position: LinearElementPosition.inside,
                      ),
                      LinearGaugeRange(
                        startValue: startMarketview, endValue: endMarketview, color: Colors.lightBlue, position: LinearElementPosition.cross,
                      ),
                    ],
                    markerPointers: [
                      LinearShapePointer(
                        value: startMarketview == 0 ? endMarketview : startMarketview,
                        animationType: LinearAnimationType.ease,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(children: <Widget>[
                    const Text(
                      "Predicted change (24h): ",
                      style: TextStyle(
                          height: 2, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${TopCryptos[widget.passedIndex].prediction} ",
                      style: TextStyle(
                        height: 2.2,
                        fontSize: 14,
                        color: predictionColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.network(
                      predUrl,
                      height: 30,
                      width: 30,
                    ),
                  ]),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(children: <Widget>[
                    const SizedBox(
                      width: 50,
                    ),
                    CircularPercentIndicator(
                      radius: 45.0,
                      lineWidth: 8.0,
                      percent: percentageTw,
                      center: Text(
                        "${beforeTw}${TopCryptos[widget.passedIndex].tweets}%$afterTw",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: tweetsColor,
                        ),
                      ),
                      progressColor: tweetsColor,
                      footer: const Text(
                        "Tweets count (7d)",
                        style: TextStyle(
                            height: 2, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      animation: true,
                      animationDuration: 1000,
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    CircularPercentIndicator(
                      radius: 45.0,
                      lineWidth: 8.0,
                      percent: percentageCm,
                      center: Text(
                        "$beforeCm${TopCryptos[widget.passedIndex].commits}%$afterCm",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: commitsColor,
                        ),
                      ),
                      progressColor: commitsColor,
                      footer: const Text(
                        "Commit count (7d):",
                        style: TextStyle(
                            height: 2, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      animation: true,
                      animationDuration: 1000,
                    ),
                  ]),
                ]),
              )),
            ]),
      ),
    );
  }
}
