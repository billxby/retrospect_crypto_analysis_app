import 'dart:convert';
import 'package:crypto_app/Functions/premium.dart';
import 'package:crypto_app/UI/UI%20helpers/alerts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:get/get.dart';
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
import 'UI helpers/buttons.dart';
import 'UI helpers/textelements.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import 'adhelper.dart';
import 'information.dart';

List<String> types = <String> ["","(in K)","(in M)"];
List<String> sub = <String> ["in units", "in thousands", "in millions"];
List<double> numbers = <double> [1, 1000, 1000000];
List<Widget> periods = <Widget> [Text("Day"), Text("Week"), Text("Month"), Text("Year"), Text("YTD")];
List<Widget> periodsVol = <Widget> [Text("Week"), Text("Month"), Text("Year"), Text("YTD")];


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
  String type = "", subtitle = "in units";
  bool _isBannerAd1Ready = false;
  bool _isBannerAd2Ready = false;
  List<bool> isSelected = [false, false, true, false, false];
  List<bool> isSelectedVol = [false, true, false, false];
  int selectedIdx = 2;
  int selectedIdxVol = 1;

  @override
  initState() {
    // waitForData();
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineColor: Colors.transparent,
      shouldAlwaysShow: true,
      tooltipSettings: InteractiveTooltip(
        enable: true,
        color: darkTheme ? Colors.black : Colors.white,
        // color: Colors.transparent,
        textStyle: TextStyle(
          color: darkTheme ? Colors.white : Colors.black,
        ),
        format: '\$point.y  (point.x)',
      ),
    );
    _trackballBehavior2 = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineColor: Colors.transparent,
      shouldAlwaysShow: true,
      tooltipSettings: InteractiveTooltip(
        enable: true,
        color: darkTheme ? Colors.black : Colors.white,
        // color: Colors.transparent,
        textStyle: TextStyle(
          color: darkTheme ? Colors.white : Colors.black,
        ),
        format: '\$point.y  (point.x)',
      ),
    );
    super.initState();
    bool loadAds = false;
    if (userHasPremium() == false && loadAds == true) {
      _loadBannerAd1();
      _loadBannerAd2();
    }
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
    Color predictionColor = cGreen;
    Color tweetsColor = getSpecialTextColor(TopCryptos[widget.passedIndex].tweets);
    Color commitsColor = getSpecialTextColor(TopCryptos[widget.passedIndex].commits);
    Color marketViewColor = getTextColor(TopCryptos[widget.passedIndex].marketView);

    Map<String, String> inputData = {};
    inputData['crypto'] = TopCryptos[widget.passedIndex].id;

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
    String predUrl = "https://i.postimg.cc/tgYj7XSn/bull-v2-offset.png";
    String marketUrl = "https://i.postimg.cc/HkYX7KCC/smiley-v2.png";

    List<String> baTw = [];
    List<String> baCm = [];

    scoreGge = updateMetrics(TopCryptos[widget.passedIndex].score);
    marketviewGge = updateMetrics(TopCryptos[widget.passedIndex].marketView);
    baTw = updateStartEnd(TopCryptos[widget.passedIndex].tweets);
    baCm = updateStartEnd(TopCryptos[widget.passedIndex].commits);

    double dTwH = double.parse(TopCryptos[widget.passedIndex].high_24h);
    double dTwL = double.parse(TopCryptos[widget.passedIndex].low_24h);
    double dPrice = double.parse(TopCryptos[widget.passedIndex].current_price);

    if (dPrice > dTwH) {
      dTwH = dPrice;
    }
    else if (dPrice < dTwL) {
      dTwL = dPrice;
    }

    if (TopCryptos[widget.passedIndex].prediction != null) {
      if (TopCryptos[widget.passedIndex].prediction.contains("Bearish")) {
        predictionColor = cRed;
        predUrl = "https://i.postimg.cc/BvkGKdkY/bear-v2-offset.png";
      }
      if (TopCryptos[widget.passedIndex].prediction.contains("Neutral")) {
        predUrl = "";
      }
    }

    if (TopCryptos[widget.passedIndex].marketView.contains("-")) {
      marketUrl = "https://i.postimg.cc/T13XqSpF/sad.png";
      marketViewColor = cRed;
    }

    bool isStarred = false;
    List<int> stars = introdata.read("starred")?.cast<int>() ?? [];
    if (stars.contains(widget.passedIndex)) {
      isStarred = true;
    }

    bool canSee = userLimitAvailable(widget.passedIndex);
    Map<String, String> alert = Map<String, String>.from(introdata.read("alerts"));
    bool hasAlert = alert.containsKey(CryptosList[widget.passedIndex]);

    setState(() {});

    return FutureBuilder(
        future: waitForData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(TopCryptos[widget.passedIndex].id),
                centerTitle: true,
                elevation: 0,
                toolbarHeight: 35,
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(TopCryptos[widget.passedIndex].id),
              centerTitle: true,
              toolbarHeight: 35,
              elevation: 0,
              actions: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => alertPage(context, inputData),
                        ).then((_)=>setState((){}));
                      },
                      child: Icon(
                        hasAlert ? Icons.notifications_active : Icons.notification_add_outlined,
                        size: 26.0,
                      ),
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        List<int> stars = introdata.read("starred")?.cast<int>() ?? [];
                        if (stars.contains(widget.passedIndex)) {
                          stars.remove(widget.passedIndex);
                          Sort["Starred"]?.remove(widget.passedIndex);
                        }
                        else {
                          stars.add(widget.passedIndex);
                          Sort["Starred"]?.add(widget.passedIndex);
                        }
                        introdata.write("starred", stars);

                        setState(() {});
                      },
                      child: Icon(
                        isStarred ? Icons.star : Icons.star_border_outlined,
                        size: 26.0,
                      ),
                    )
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: Container(
                    width: screenWidth * 0.95,
                    height: 530,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Row(
                          children: <Widget> [
                            CircleAvatar(
                              backgroundImage: NetworkImage(TopCryptos[widget.passedIndex].image),
                              backgroundColor: Colors.transparent,
                              radius: 23,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    TopCryptos[widget.passedIndex].id.capitalizeFirst ?? TopCryptos[widget.passedIndex].id,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                    softWrap: false,
                                  ),
                                ),
                                Text(
                                  TopCryptos[widget.passedIndex].symbol.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.left,
                                  softWrap: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          " \$${TopCryptos[widget.passedIndex].current_price} USD",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 1.5,
                            height: 2,
                          ),
                          textAlign: TextAlign.left,
                          softWrap: false,
                        ),
                        Text(
                          "  ${TopCryptos[widget.passedIndex].price_change_precentage_24h}%",
                          style: TextStyle(
                            fontSize: 16,
                            color: twentyFourColor,
                          ),
                          textAlign: TextAlign.left,
                          softWrap: false,
                        ),
                        Center(
                          child: cryptoPriceChart(_trackballBehavior, _cryptoData[selectedIdx], false, screenWidth * 0.93),
                        ),
                        Center(
                          child: ToggleButtons(
                            direction: Axis.horizontal,
                            onPressed: (int index) {
                              setState(() {
                                // The button that is tapped is set to true, and the others to false.
                                for (int i = 0; i < isSelected.length; i++) {
                                  isSelected[i] = i == index;
                                  if (isSelected[i] == true) {
                                    selectedIdx = i;
                                  }
                                }
                              });
                            },
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            selectedBorderColor: Colors.transparent,
                            selectedColor: Colors.black,
                            fillColor: Colors.white,
                            // color: Colors.white,
                            borderWidth: 2,
                            constraints: BoxConstraints(
                              minHeight: 40.0,
                              minWidth: screenWidth * 0.15,
                            ),
                            isSelected: isSelected,
                            children: periods,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Center(
                  child: Container(
                    width: screenWidth * 0.95,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget> [
                          Text(
                            "Range (24h)",
                            style: TextStyle(
                              height: 1, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                          ),
                          SfLinearGauge(
                            minimum: dTwL,
                            maximum: dTwH,
                            maximumLabels: 1,
                            animateAxis: true,
                            axisTrackStyle: const LinearAxisTrackStyle(
                              color: Colors.transparent,
                            ),
                            ranges: <LinearGaugeRange>[
                              LinearGaugeRange(
                                  startValue: dTwL,
                                  endValue: dPrice,
                                  position: LinearElementPosition.outside,
                                  color: cRed),
                              LinearGaugeRange(
                                  startValue: dPrice,
                                  endValue: dTwH,
                                  position: LinearElementPosition.outside,
                                  color: cGreen),
                            ],
                            markerPointers: [
                              LinearShapePointer(
                                value: dPrice,
                                animationType: LinearAnimationType.ease,
                                color: darkTheme ? Colors.white : Colors.black,
                              ),
                            ],
                          ),
                        ],
                    ),
                  ),
                ),

                Center(
                  child: Container(
                    width: screenWidth * 0.95,
                    height: 255,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Row(
                          children: <Widget> [
                            const Text(
                              "Market Stats",
                              style: TextStyle(
                                height: 4, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                            ),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        )
                                    ),
                                    builder: (context) => Center(
                                      child: marketStatsInfo(darkTheme ? Colors.white : Colors.black),
                                    )
                                );
                              },
                              icon: const Icon(Icons.info_outlined),
                              iconSize: 15,
                              padding: EdgeInsets.all(5),
                              constraints: BoxConstraints(maxHeight: 16, maxWidth: 16),
                            ),
                          ],
                        ),
                        Table(
                          // border: TableBorder.all(),
                          columnWidths: <int, TableColumnWidth>{
                            0: FixedColumnWidth(screenWidth * 0.95),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            infoRow("Market cap", "\$${TopCryptos[widget.passedIndex].market_cap} USD", darkTheme ? Colors.white : Colors.black),
                            infoRow("Volume (24h)", "\$${TopCryptos[widget.passedIndex].total_volume} USD", darkTheme ? Colors.white : Colors.black),
                            infoRow("Total supply", "${TopCryptos[widget.passedIndex].total_supply} ${TopCryptos[widget.passedIndex].symbol.toUpperCase()}", darkTheme ? Colors.white : Colors.black),
                            infoRow("All-time high", "\$${TopCryptos[widget.passedIndex].ath} USD", darkTheme ? Colors.white : Colors.black),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 25),
                            child: TextButton(
                              onPressed: () async {
                                await launchUrl(Uri.parse("https://www.coingecko.com/"));
                              },
                              child: Text(
                                "powered by CoinGecko",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: darkTheme ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Center(
                    child: Container(
                      height: 1150,
                      width: screenWidth * 0.95,
                      child: Column(children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start, //Center Row contents horizontally,
                          children: <Widget>[
                            const Text(
                              "Analysis",
                              style: TextStyle(
                                height: 2, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                            ),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    )
                                  ),
                                  builder: (context) => Center(
                                    child: analysisInfo(darkTheme ? Colors.white : Colors.black),
                                  )
                                );
                              },
                              icon: const Icon(Icons.info_outlined),
                              iconSize: 15,
                              padding: EdgeInsets.all(5),
                              constraints: BoxConstraints(maxHeight: 28, maxWidth: 16),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5
                        ),
                        if (canSee == true)
                          Table(
                          // border: TableBorder.all(),
                          columnWidths: <int, TableColumnWidth>{
                            0: FixedColumnWidth(screenWidth * 0.95),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            TableRow(
                              children: <Widget> [
                                Container(
                                  margin: const EdgeInsets.all(1.0),
                                  padding: const EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: darkTheme ? Colors.white : Colors.black,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  height: 100,
                                  child: Column(
                                    children: <Widget> [
                                      Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: screenWidth*0.431,
                                            child: Row(
                                              children: <Widget> [
                                                Align(
                                                  alignment: Alignment.bottomCenter,
                                                  child: Image.network(
                                                    'https://i.postimg.cc/6QCj5gVx/R-for-Retrospect-in-App.png',
                                                    fit: BoxFit.cover,
                                                    height: 22,
                                                  ),
                                                ),
                                                RichText(
                                                    text: TextSpan(
                                                        text: "etro",
                                                        style: blueRetroTitleStyle,
                                                        children: <TextSpan>[
                                                          TextSpan(text:"-Score©", style: TextStyle(
                                                            height: 2,
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                            color: darkTheme ? Colors.white : Colors.black,
                                                          )),
                                                        ]
                                                    )
                                                ),
                                              ]
                                            ),
                                          ),
                                          SizedBox(width:screenWidth*0.161),
                                          SizedBox(
                                            width: screenWidth*0.323,
                                            child: Text(
                                              "${double.parse(TopCryptos[widget.passedIndex].score).toStringAsFixed(3)}",
                                              textAlign: TextAlign.right,
                                              softWrap: false,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: scoreColor,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      analysisGauge(scoreGge[0], scoreGge[1], scoreGge[2], scoreGge[3], darkTheme ? Colors.white : Colors.black),
                                    ],
                                  )
                                ),

                              ],
                            ),
                            TableRow(
                              children: <Widget> [
                                Container(
                                    margin: const EdgeInsets.all(1.0),
                                    padding: const EdgeInsets.all(3.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: darkTheme ? Colors.white : Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    height: 100,
                                    child: Column(
                                      children: <Widget> [
                                        Row(
                                          children: <Widget>[
                                            SizedBox(
                                              width: screenWidth*0.431,
                                              child: RichText(
                                                  text: TextSpan(
                                                      text: "Market ",
                                                      style: TextStyle(
                                                        height: 2,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: darkTheme ? Colors.white : Colors.black,
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(text:"View ", style: blueTitleStyle),
                                                        TextSpan(text:"score: "),
                                                      ]
                                                  )
                                              ),
                                            ),
                                            SizedBox(width:screenWidth*0.161),
                                            SizedBox(
                                              width: screenWidth*0.323,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget> [
                                                  Image.network(
                                                    marketUrl,
                                                    height: 15,
                                                  ),
                                                  Text(
                                                    " ${double.parse(TopCryptos[widget.passedIndex].marketView).toStringAsFixed(3)}",
                                                    textAlign: TextAlign.right,
                                                    softWrap: false,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: marketViewColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        analysisGauge(marketviewGge[0], marketviewGge[1], marketviewGge[2], marketviewGge[3], darkTheme ? Colors.white : Colors.black),
                                      ],
                                    )
                                ),
                              ],
                            ),
                            TableRow(
                              children: <Widget> [
                                Container(
                                    margin: const EdgeInsets.all(1.0),
                                    padding: const EdgeInsets.all(3.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: darkTheme ? Colors.white : Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    height: 47,
                                    child: Column(
                                      children: <Widget> [
                                        Row(
                                          children: <Widget>[
                                            SizedBox(
                                              width: screenWidth*0.431,
                                              child: const Text(
                                                "Prediction (24h)",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  height: 2,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width:screenWidth*0.134),
                                            SizedBox(
                                              width: screenWidth*0.359,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget> [
                                                  Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: SizedBox(
                                                      height: 30,
                                                      width: 20,
                                                      child: Image.network(
                                                        predUrl,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    " ${TopCryptos[widget.passedIndex].prediction}",
                                                    textAlign: TextAlign.right,
                                                    softWrap: false,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      height: 2,
                                                      color: predictionColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (canSee == false)
                          Container(
                            width: screenWidth * 0.95,
                            height: 220,
                            child: Column(
                              children: <Widget> [
                                SizedBox(height: 20),
                                Image.network(
                                  "https://i.postimg.cc/VkpYychz/Lock.png",
                                  height:60,
                                ),
                                const Text(
                                  "You have reached your daily limit!",
                                  style: TextStyle(
                                    height: 3,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  "Get Premium to access more analysis!\n\nYou still have access to:",
                                  style: TextStyle(
                                    height: 1,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  width: screenWidth * 0.8,
                                  child: Text(
                                    "${introdata.read("used")}",
                                    style: const TextStyle(
                                      height: 1,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(
                          height: 30,
                        ),
                        if (canSee == true)
                          Row(children: <Widget>[
                          const SizedBox(
                            width: 50,
                          ),
                          socialsChange(percentageTw, "${baTw[0]}${TopCryptos[widget.passedIndex].tweets}%${baTw[1]}", tweetsColor, "Tweets count (7d)"),
                          const SizedBox(
                            width: 50,
                          ),
                          socialsChange(percentageCm, "${baCm[0]}${TopCryptos[widget.passedIndex].commits}%${baCm[1]}", commitsColor, "Commit count (7d)"),
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
                        // Center(
                        //   child: cryptoInfoChart("Price Chart", _trackballBehavior, _cryptoData[0], true, Colors.blue),
                        // ),
                        const SizedBox(
                          height: 20,
                        ),

                        Center(
                          child: Container(
                            width: screenWidth * 0.95,
                            height: 530,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                Center(
                                  child: cryptoInfoChart("Volume", _trackballBehavior2, _cryptoData[selectedIdxVol+5], false, screenWidth * 0.93),
                                ),
                                Center(
                                  child: Text(subtitle, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ),
                                Center(
                                  child: ToggleButtons(
                                    direction: Axis.horizontal,
                                    onPressed: (int index) {
                                      setState(() {
                                        // The button that is tapped is set to true, and the others to false.
                                        for (int i = 0; i < isSelectedVol.length; i++) {
                                          isSelectedVol[i] = i == index;
                                          if (isSelectedVol[i] == true) {
                                            selectedIdxVol = i;
                                          }
                                        }
                                      });
                                    },
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    selectedBorderColor: Colors.transparent,
                                    selectedColor: Colors.black,
                                    fillColor: Colors.white,
                                    // color: Colors.white,
                                    borderWidth: 2,
                                    constraints: BoxConstraints(
                                      minHeight: 40.0,
                                      minWidth: screenWidth*0.15,
                                    ),
                                    isSelected: isSelectedVol,
                                    children: periodsVol,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    List<PriceData> priceDataD = [];
    List<PriceData> priceDataY = [];
    List<PriceData> priceDataM = [];
    List<PriceData> priceDataW = [];
    List<PriceData> priceDataYTD = [];
    List<PriceData> volumeDataY = [];
    List<PriceData> volumeDataW = [];
    List<PriceData> volumeDataM = [];
    List<PriceData> volumeDataYTD = [];

    final String url = "https://api.coingecko.com/api/v3/coins/${TopCryptos[widget.passedIndex].id}/market_chart?vs_currency=usd&days=365&interval=daily";
    final String url2 = "https://api.coingecko.com/api/v3/coins/${TopCryptos[widget.passedIndex].id}/market_chart?vs_currency=usd&days=7&interval=hourly";

    for (int i=0;i<maxFetchTries;i++) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode != 200) {
          throw Exception('Could not fetch data!');
        }

        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> prices = data['prices'];
        List<dynamic> volume = data['total_volumes'];

        DateTime now = DateTime.now();

        int counter = 0;
        int pricesLen = prices.length;
        int volumeLen = volume.length;

        for (List<dynamic> time in prices) {
          PriceData adding = PriceData(DateTime.fromMillisecondsSinceEpoch(time[0]),time[1]);
          priceDataY.add(adding);
          if (pricesLen-counter <= 28) {
            priceDataM.add(adding);
          }
          if (adding.time.year == now.year) {
            priceDataYTD.add(adding);
          }

          counter+=1;
        }

        double largest = 0;

        for (List<dynamic> time in volume) {
          if (time[1] > largest) {
            largest = time[1];
          }
        }

        int curIndex = 0;

        for (int i=0;i<types.length;i++) {
          if (largest / numbers[i] > 1) {
            type = types[i];
            subtitle = sub[i];
            curIndex = i;
          }
          else {
            break;
          }
        }

        counter = 0;

        for (List<dynamic> time in volume) {
          PriceData adding = PriceData(DateTime.fromMillisecondsSinceEpoch(time[0]), double.parse((time[1]/numbers[curIndex]).toStringAsFixed(3)));
          volumeDataY.add(adding);

          if (volumeLen-counter <= 28) {
            volumeDataM.add(adding);
          }
          if (volumeLen-counter <= 7) {
            volumeDataW.add(adding);
          }
          if (adding.time.year == now.year) {
            volumeDataYTD.add(adding);
          }
          counter+=1;
        }

        final response2 = await http.get(Uri.parse(url2));

        if (response2.statusCode != 200) {
          throw Exception('Could not fetch data!');
        }

        Map<String, dynamic> data2 = json.decode(response2.body);
        List<dynamic> prices2 = data2['prices'];

        int add = 3;

        for (List<dynamic> time in prices2) {
          PriceData adding = PriceData(DateTime.fromMillisecondsSinceEpoch(time[0]),time[1]);
          if (add == 3) {
            priceDataW.add(adding);
            add = 0;
          }
          else {
            add += 1;
          }
          if (adding.time.day == now.day && adding.time.month == now.month) {
            priceDataD.add(adding);
          }
        }

        cryptoData.add(priceDataD);
        cryptoData.add(priceDataW);
        cryptoData.add(priceDataM);
        cryptoData.add(priceDataY);
        cryptoData.add(priceDataYTD);
        cryptoData.add(volumeDataW);
        cryptoData.add(volumeDataM);
        cryptoData.add(volumeDataY);
        cryptoData.add(volumeDataYTD);
        break;
      }
      catch (e) {
        print(e);
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
          print(err);
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
