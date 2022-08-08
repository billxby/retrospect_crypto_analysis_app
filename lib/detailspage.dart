import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
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
    if (TopCryptos[widget.passedIndex].price_change_precentage_24h != null) {
      if (TopCryptos[widget.passedIndex]
          .price_change_precentage_24h
          .contains("-")) twentyFourColor = Colors.red;
    }
    if (TopCryptos[widget.passedIndex].prediction != null) {
      if (TopCryptos[widget.passedIndex]
          .prediction
          .contains("Bearish")) predictionColor = Colors.red;
    }
    if (TopCryptos[widget.passedIndex].score != null) {
      if (TopCryptos[widget.passedIndex]
          .score
          .contains("-")) scoreColor = Colors.red;
    }
    if (TopCryptos[widget.passedIndex].tweets != null) {
      if (TopCryptos[widget.passedIndex]
          .tweets
          .contains("-")) tweetsColor = Colors.red;
    }
    if (TopCryptos[widget.passedIndex].commits != null) {
      if (TopCryptos[widget.passedIndex]
          .commits
          .contains("-")) commitsColor = Colors.red;
    }
    if (TopCryptos[widget.passedIndex].marketView != null) {
      if (TopCryptos[widget.passedIndex]
          .marketView
          .contains("-")) marketViewColor = Colors.red;
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
                          "Mrkt Cap Rank: ",
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
                          "Total Supply: ",
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
                          "Symbol: ",
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
                height: 230,
                width: 350,
                child: Column(children: <Widget>[
                  const Center(child: Text(
                    "Analysis",
                    style: TextStyle(
                        height: 2,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),)),
                  Row(
                    children: <Widget>[
                      const Text(
                        "RETRO-SCORE©: ",
                        style: TextStyle(
                            height: 2,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        TopCryptos[widget.passedIndex].score,
                        style: TextStyle(
                          height: 2.2,
                          fontSize: 14,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Text(
                        "  MarketView score: ",
                        style: TextStyle(
                            height: 2,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        TopCryptos[widget.passedIndex].marketView,
                        style: TextStyle(
                          height: 2.2,
                          fontSize: 14,
                          color: marketViewColor,
                        ),
                      ),
                    ],
                  ),
                  Row(children: <Widget>[
                    const Text(
                      "  Tweets count (Change 7d): ",
                      style: TextStyle(
                          height: 2,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${TopCryptos[widget.passedIndex].tweets} %",
                      style: TextStyle(
                        height: 2.2,
                        fontSize: 14,
                        color: tweetsColor,
                      ),
                    ),
                  ]),
                  Row(children: <Widget>[
                    const Text(
                      "  Commit count (Change 7d): ",
                      style: TextStyle(
                          height: 2,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${TopCryptos[widget.passedIndex].commits} %",
                      style: TextStyle(
                        height: 2.2,
                        fontSize: 14,
                        color: commitsColor,
                      ),
                    ),
                  ]),
                  Row(children: <Widget>[
                    const Text(
                      "  Predicted change (24h): ",
                      style: TextStyle(
                          height: 2,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      TopCryptos[widget.passedIndex].prediction,
                      style: TextStyle(
                        height: 2.2,
                        fontSize: 14,
                        color: predictionColor,
                      ),
                    ),
                  ]),
                ]),
              )),
            ]),
      ),
    );
  }
}
