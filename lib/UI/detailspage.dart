import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../Functions/detailspageassist.dart';
import '../main.dart';
import 'UI helpers/textelements.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'adhelper.dart';

class DetailsPage extends StatefulWidget {
  final int passedIndex;

  const DetailsPage({Key? key, required this.passedIndex}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late TrackballBehavior _trackballBehavior;
  late TrackballBehavior _trackballBehavior2;
  late List<List<PriceData>> _cryptoData = [];
  late BannerAd _bannerAd;
  late BannerAd _endBannerAd;
  bool _isBannerAd1Ready = false;
  bool _isBannerAd2Ready = false;

  @override
  initState() {
    // waitForData();
    _trackballBehavior = TrackballBehavior(
        enable: true, activationMode: ActivationMode.singleTap);
    _trackballBehavior2 = TrackballBehavior(
        enable: true, activationMode: ActivationMode.singleTap);
    super.initState();
    _loadBannerAd1();
    _loadBannerAd2();
  }



  Future<bool> waitForData() async {
    _cryptoData = await getChartData();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final introdata = GetStorage();
    Color twentyFourColor = getTextColor(TopCryptos[widget.passedIndex].price_change_precentage_24h);
    Color scoreColor = getTextColor(TopCryptos[widget.passedIndex].score);
    Color predictionColor = Colors.green;
    Color tweetsColor = getSpecialTextColor(TopCryptos[widget.passedIndex].tweets);
    Color commitsColor = getSpecialTextColor(TopCryptos[widget.passedIndex].commits);
    Color marketViewColor = getTextColor(TopCryptos[widget.passedIndex].marketView);

    double percentageTw =
    double.parse(TopCryptos[widget.passedIndex].tweets) / 100.abs() > 1
        ? 1
        : double.parse(TopCryptos[widget.passedIndex].tweets) / 100.abs();
    double percentageCm =
    double.parse(TopCryptos[widget.passedIndex].commits) / 100.abs() > 1
        ? 1
        : double.parse(TopCryptos[widget.passedIndex].commits) / 100.abs();
    //make sure they're not negative
    percentageTw = percentageTw.abs();
    percentageCm = percentageCm.abs();

    List<double> scoreGge = [], marketviewGge = [];
    String predUrl = "https://i.postimg.cc/SNcFQTHG/bull.png";
    String marketUrl = "https://i.postimg.cc/GtgnMQD2/smiley.png";

    List<String> baTw = [];
    List<String> baCm = [];

    scoreGge = updateMetrics(TopCryptos[widget.passedIndex].score);
    marketviewGge = updateMetrics(TopCryptos[widget.passedIndex].marketView);
    baTw = updateStartEnd(TopCryptos[widget.passedIndex].tweets);
    baCm = updateStartEnd(TopCryptos[widget.passedIndex].commits);

    if (TopCryptos[widget.passedIndex].prediction != null) {
      if (TopCryptos[widget.passedIndex].prediction.contains("Bearish")) {
        predictionColor = Colors.red;
        predUrl = "https://i.postimg.cc/0yxgzGs1/bear.png";
      }
      if (TopCryptos[widget.passedIndex].prediction.contains("Neutral")) {
        predUrl = "";
      }
    }

    if (TopCryptos[widget.passedIndex].marketView.contains("-")) {
      marketUrl = "https://i.postimg.cc/T13XqSpF/sad.png";
      marketViewColor = Colors.red;
    }

    // print("-------------------------");
    // print(introdata.read("used"));
    // print(introdata.read("used").length);
    // print("-------------------------");

    return FutureBuilder(
        future: waitForData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(TopCryptos[widget.passedIndex].id),
                centerTitle: true,
                toolbarHeight: 35,
              ),

            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(TopCryptos[widget.passedIndex].id),
              centerTitle: true,
              toolbarHeight: 35,
            ),
            body: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
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
                              "${TopCryptos[widget.passedIndex].current_price}  | ",
                              style: const TextStyle(height: 2, fontSize: 15),
                            ),
                            detailsPageTitle(" 24h: "),
                            detailsPageInfo(TopCryptos[widget.passedIndex]
                                .price_change_precentage_24h, twentyFourColor),
                            Text(
                              "%",
                              style: TextStyle(
                                height: 2.2,
                                fontSize: 12,
                                color: twentyFourColor,
                              ),
                            ),
                            detailsPageTitle(" | Mrkt Cap: "),
                            detailsPageInfo(TopCryptos[widget.passedIndex].market_cap, darkTheme ? Colors.white : Colors.black),
                            detailsPageTitle(" | Vol: "),
                            detailsPageInfo(TopCryptos[widget.passedIndex].total_volume, darkTheme ? Colors.white : Colors.black),
                          ],
                        ),
                        Row(children: <Widget>[
                          detailsPageTitle("24h Hi: "),
                          detailsPageInfo(TopCryptos[widget.passedIndex].high_24h, darkTheme ? Colors.white : Colors.black),
                          detailsPageTitle(" | 24h Low: "),
                          detailsPageInfo(TopCryptos[widget.passedIndex].low_24h, darkTheme ? Colors.white : Colors.black),
                          detailsPageTitle(" | ATH: "),
                          detailsPageInfo(TopCryptos[widget.passedIndex].ath, darkTheme ? Colors.white : Colors.black),
                        ]),
                        Row(children: const <Widget>[
                          Text(
                            "Additional Information:",
                            style: TextStyle(
                                height: 2, fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ]),
                        Row(children: <Widget>[
                          additionalInfo(" Mrkt Cap Rank: ", false),
                          additionalInfo(TopCryptos[widget.passedIndex].market_cap_rank, true),
                        ]),
                        Row(children: <Widget>[
                          additionalInfo(" Total Supply: ", false),
                          additionalInfo(TopCryptos[widget.passedIndex].total_supply, true),
                        ]),
                        Row(children: <Widget>[
                          additionalInfo(" Symbol: ", false),
                          additionalInfo(TopCryptos[widget.passedIndex].symbol, true),
                        ]),
                        const SizedBox(
                          height: 29,
                        ),
                        Text(
                          "last updated: ${TopCryptos[widget.passedIndex].last_updated}",
                          style: const TextStyle(fontSize: 9),
                        ),
                      ])),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: Container(
                      height: 1100,
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
                              height: 30,
                              width: 20,
                              child: Image.network(
                                'https://i.postimg.cc/sDw49xXG/Retro-Spect-Trans.png',
                                height: 30,
                                width: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "ETRO",
                                style: blueRetroTitleStyle,
                                children: <TextSpan>[
                                  TextSpan(text:"-SCORE©: ", style: retroTitleStyle),
                                ]
                              )
                            ),
                            detailsPageInfo(TopCryptos[widget.passedIndex].score == "updating database"
                                ? TopCryptos[widget.passedIndex].score
                                : double.parse(TopCryptos[widget.passedIndex].score)
                                .toStringAsFixed(3), scoreColor
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        analysisGauge(scoreGge[0], scoreGge[1], scoreGge[2], scoreGge[3]),
                        Row(
                          children: <Widget>[
                            RichText(
                                text: TextSpan(
                                    text: "Market ",
                                    style: titleStyle,
                                    children: <TextSpan>[
                                      TextSpan(text:"View ", style: blueTitleStyle),
                                      TextSpan(text:"score: ", style: titleStyle),
                                    ]
                                )
                            ),
                            detailsPageInfo(TopCryptos[widget.passedIndex].marketView ==
                                "updating database"
                                ? "${TopCryptos[widget.passedIndex].marketView} "
                                : "${double.parse(
                                TopCryptos[widget.passedIndex].marketView)
                                .toStringAsFixed(3)} ", marketViewColor),
                            Container(
                              alignment: Alignment.bottomCenter,
                              height: 20,
                              width: 15,
                              child: Image.network(
                                marketUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        analysisGauge(marketviewGge[0], marketviewGge[1], marketviewGge[2], marketviewGge[3]),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(children: <Widget>[
                          Text(
                            "Predicted change (24h): ",
                            style: titleStyle,
                          ),
                          detailsPageInfo("${TopCryptos[widget.passedIndex].prediction} ", predictionColor),
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
                          socialsChange(percentageTw, "${baTw[0]}${TopCryptos[widget.passedIndex].tweets}%${baTw[1]}", tweetsColor, "Tweets count (7d)"),
                          const SizedBox(
                            width: 50,
                          ),
                          socialsChange(percentageCm, "${baCm[0]}${TopCryptos[widget.passedIndex].commits}%${baCm[1]}", commitsColor, "Commit count (7d):"),
                        ]),
                        const SizedBox(
                          height: 15,
                        ),
                        if (_isBannerAd1Ready)
                          Center(
                            child: Container(
                              width: _bannerAd.size.width.toDouble(),
                              height: _bannerAd.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd),
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: cryptoInfoChart("Price Chart", _trackballBehavior, _cryptoData[0], true, Colors.blue),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: cryptoInfoChart("Total Volume", _trackballBehavior2, _cryptoData[1], false, Colors.green),
                        ),
                      ]),
                    )),
                if (_isBannerAd2Ready)
                  Center(
                    child: Container(
                      width: _endBannerAd.size.width.toDouble(),
                      height: _endBannerAd.size.height.toDouble(),
                      child: AdWidget(ad: _endBannerAd),
                    ),
                  ),
              ]),
            ),
          );
        });
  }

  Future<List<List<PriceData>>> getChartData() async {
    List<List<PriceData>> cryptoData = [];
    List<PriceData> priceData = [];
    List<PriceData> volumeData = [];

    final String url = "https://api.coingecko.com/api/v3/coins/${TopCryptos[widget.passedIndex].id}/market_chart?vs_currency=usd&days=28&interval=daily";

    for (int i=0;i<maxFetchTries;i++) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode != 200) {
          throw Exception('Could not fetch data!');
        }

        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> prices = data['prices'];
        List<dynamic> volume = data['total_volumes'];

        for (List<dynamic> time in prices) {
          priceData.add(PriceData(DateTime.fromMillisecondsSinceEpoch(time[0]),time[1]));
        }

        for (List<dynamic> time in volume) {
          volumeData.add(PriceData(DateTime.fromMillisecondsSinceEpoch(time[0]),time[1]));
        }

        cryptoData.add(priceData);
        cryptoData.add(volumeData);
        break;
      }
      catch (e) {
        print('Trying again in 5 seconds');
        await Future.delayed(const Duration(seconds: 5), () {});
        continue;
      }
    }

    return cryptoData;
  }

  void _loadBannerAd1() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId1,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAd1Ready = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAd1Ready = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  void _loadBannerAd2() {
    _endBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId2,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAd2Ready = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAd2Ready = false;
          ad.dispose();
        },
      ),
    );

    _endBannerAd.load();
  }

}


class PriceData {
  PriceData(this.time, this.price);

  final DateTime time;
  final double price;
}
