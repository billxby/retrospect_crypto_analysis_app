import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../main.dart';
import '../detailspage.dart';

Text listviewTextTitle(String content) {
  return Text(
    content,
    style:
        const TextStyle(height: 1.8, fontSize: 15, fontWeight: FontWeight.bold),
  );
}

Text listviewTextInfo(String content, Color color) {
  return Text(content,
      style: TextStyle(
        height: 2.2,
        fontSize: 14,
        color: color,
      ));
}

Text detailsPageTitle(String content) {
  return Text(
    content,
    style:
        const TextStyle(height: 2, fontSize: 15, fontWeight: FontWeight.bold),
  );
}

Text detailsPageInfo(String content, Color color) {
  return Text(
    content,
    style: TextStyle(
      height: 2.2,
      fontSize: 14,
      color: color,
    ),
  );
}

Text additionalInfo(String content, bool italic) {
  return Text(
    content,
    style: TextStyle(
      height: 1,
      fontSize: 15,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    ),
  );
}

Row title(String content) {
  return Row(children: <Widget>[
    Text(
      content,
      style: titleStyle,
    )
  ]);
}

TextStyle blueRetroTitleStyle = const TextStyle(
  height: 2,
  fontSize: 15,
  fontWeight: FontWeight.bold,
  color: Colors.lightBlue,
);

TextStyle retroTitleStyle = TextStyle(
  height: 2,
  fontSize: 15,
  fontWeight: FontWeight.bold,
  color: darkTheme ? Colors.white : Colors.black,
);

TextStyle blueTitleStyle = const TextStyle(
  height: 2,
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.lightBlue,
);

TextStyle titleStyle = TextStyle(
  height: 2,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

Text buttonBlueText(String content) {
  return Text(
    content,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.blue,
    ),
  );
}

TextStyle hugeTitleStyle = const TextStyle(
  height: 2,
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

Image creditImage = Image.network(
  "https://i.postimg.cc/D0PrC6Fz/Credits.png",
  height: 20,
  width: 20,
);

const Color lightGreen = Color(0xffabf7c1);
const Color lightRed = Color(0xfff7abab);

SfLinearGauge analysisGauge(double start, double end, double min, double max) {
  return SfLinearGauge(
    minimum: min,
    maximum: max,
    ranges: <LinearGaugeRange>[
      LinearGaugeRange(
        startValue: 0,
        endValue: max,
        color: lightGreen,
        position: LinearElementPosition.inside,
      ),
      LinearGaugeRange(
        startValue: min,
        endValue: 0,
        color: lightRed,
        position: LinearElementPosition.inside,
      ),
      LinearGaugeRange(
        startValue: start,
        endValue: end,
        color: Colors.blue,
        position: LinearElementPosition.cross,
      ),
    ],
    markerPointers: [
      LinearShapePointer(
        value: start == 0 ? end : start,
        animationType: LinearAnimationType.ease,
      ),
    ],
  );
}

CircularPercentIndicator socialsChange(
    double percentage, String content, Color color, String footer) {
  return CircularPercentIndicator(
    radius: 45.0,
    lineWidth: 8.0,
    percent: percentage,
    center: Text(
      content,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
    progressColor: color,
    footer: Text(
      footer,
      style:
          const TextStyle(height: 2, fontSize: 12, fontWeight: FontWeight.bold),
    ),
    animation: true,
    animationDuration: 1000,
  );
}

Container cryptoInfoChart(String title, TrackballBehavior trackballBehavior,
    List<PriceData> cryptoData, bool showAxis, Color lineColor) {
  return Container(
    height: 275,
    width: 350,
    child: Column(
      children: <Widget>[
        Center(
            child: Text(
          title,
          style: const TextStyle(
              height: 2, fontSize: 22, fontWeight: FontWeight.bold),
        )),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 225,
          width: 350,
          child: SfCartesianChart(
            trackballBehavior: trackballBehavior,
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(isVisible: showAxis),
            legend: Legend(isVisible: false),
            series: <LineSeries<PriceData, String>>[
              LineSeries<PriceData, String>(
                color: lineColor,
                dataSource: cryptoData,
                xValueMapper: (PriceData prices, _) =>
                    DateFormat('MM-dd').format(prices.time),
                yValueMapper: (PriceData prices, _) => prices.price,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
