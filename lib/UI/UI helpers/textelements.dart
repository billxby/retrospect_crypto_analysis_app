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

Color cGreen = Color(0xff0DC9AB);
Color cRed = Color(0xffF45656);

Text listviewTextTitle(String content) {
  return Text(
    content,
    style:
        const TextStyle(height: 1.4, fontSize: 14, fontWeight: FontWeight.bold),
  );
}

Text listviewTextInfo(String content, Color color) {
  return Text(content,
      style: TextStyle(
        height: 1.6,
        fontSize: 13,
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
  color: Colors.lightBlueAccent,
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
  color: darkTheme ? Colors.white : Colors.black,
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

TextStyle hugeTitleStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

Icon creditImage = const Icon(
  Icons.donut_large,
  size: 28,
  color: Colors.blue,
);

const Color lightGreen = Color(0xffabf7c1);
const Color lightRed = Color(0xfff7abab);

SfLinearGauge analysisGauge(double start, double end, double min, double max, Color pointerColor) {
  return SfLinearGauge(
    minimum: min,
    maximum: max,
    maximumLabels: 2,
    animateAxis: true,
    axisTrackStyle: const LinearAxisTrackStyle(
      color: Colors.transparent,
    ),
    ranges: <LinearGaugeRange>[
      LinearGaugeRange(
        startValue: 0,
        endValue: max,
        color: cGreen,
        position: LinearElementPosition.cross,
      ),
      LinearGaugeRange(
        startValue: min,
        endValue: 0,
        color: cRed,
        position: LinearElementPosition.cross,
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
        color: pointerColor,
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
    List<PriceData> cryptoData, bool showAxis, double width) {
  Color lineColor = cryptoData[0].price - cryptoData[cryptoData.length - 1].price > 0 ? cRed : cGreen;

  return Container(
    height: 300,
    width: width,
    child: Column(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
              height: 2, fontSize: 20, fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 250,
          width: width,
          child: SfCartesianChart(
            trackballBehavior: trackballBehavior,
            borderColor: Colors.transparent,
            plotAreaBorderColor: Colors.transparent,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              isVisible: showAxis,
            ),
            primaryYAxis: NumericAxis(
              isVisible: showAxis,
              majorGridLines: const MajorGridLines(width: 0),
              rangePadding: ChartRangePadding.round,
            ),
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

Container cryptoAnalChart(TrackballBehavior trackballBehavior,
    List<PriceData> cryptoData, bool showAxis, double width) {
  Color lineColor = cryptoData[0].price - cryptoData[cryptoData.length - 1].price > 0 ? Colors.blueAccent : Colors.lightBlueAccent;

  return Container(
    height: 265,
    width: width,
    child: Column(
      children: <Widget>[
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 250,
          width: width,
          child: SfCartesianChart(
            trackballBehavior: trackballBehavior,
            borderColor: Colors.transparent,
            plotAreaBorderColor: Colors.transparent,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              isVisible: showAxis,
            ),
            primaryYAxis: NumericAxis(
              isVisible: showAxis,
              majorGridLines: const MajorGridLines(width: 0),
              rangePadding: ChartRangePadding.round,
            ),
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

Container cryptoPriceChart(TrackballBehavior trackballBehavior,
    List<PriceData> cryptoData, bool showAxis, double width) {
  Color lineColor = cryptoData[0].price - cryptoData[cryptoData.length - 1].price > 0 ? cRed : cGreen;
  return Container(
    height: 350,
    width: width,
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 350,
          width: width,
          child: SfCartesianChart(
            trackballBehavior: trackballBehavior,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              isVisible: showAxis,
            ),
            primaryYAxis: NumericAxis(
              isVisible: showAxis,
              majorGridLines: const MajorGridLines(width: 0),
              rangePadding: ChartRangePadding.round,
              // labelFormat: '\${value}',
            ),
            borderColor: Colors.transparent,
            plotAreaBorderColor: Colors.transparent,
            legend: Legend(isVisible: false),
            series: <LineSeries<PriceData, String>>[
              LineSeries<PriceData, String>(
                color: lineColor,
                dataSource: cryptoData,
                xValueMapper: (PriceData prices, _) =>
                    DateFormat('MM-dd HH:00').format(prices.time),
                yValueMapper: (PriceData prices, _) => prices.price,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

SizedBox changePasswordField(TextEditingController controller, String text) {
  return SizedBox(
    width: 300,
    child: TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        labelText: text,
      ),
    ),
  );
}

TableRow buildRow(List<String> cells, {bool isHeader = false}) => TableRow(
  children: cells.map((cell) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: 14,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(child: Text(cell, style: style)),
    );
  }).toList(),
);

TextStyle tableStyleHeader({bool isHeader = false}) {
  return TextStyle(
    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    fontSize: 18,
    height: 2,
  );
}

TextStyle tableStyle({bool isHeader = false}) {
  return TextStyle(
    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    fontSize: 14,
    height: 3,
  );
}

TextStyle tableStyleBelow({bool isHeader = false}) {
  return TextStyle(
    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    fontSize: 14,
    height: 2,
  );
}

TableRow compareRow(String text1, String text2, String text3) {
  return TableRow(
      children: <Widget>[
        Container(
          color: Colors.blue,
          child: Text(text1, style:tableStyle(isHeader: true), textAlign: TextAlign.center),
        ),
        Text(text2, style:tableStyle(), textAlign: TextAlign.center),
        Text(text3, style:const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 3,
          color: Colors.blue,
        ), textAlign: TextAlign.center),
      ]
  );
}

TableRow infoRow(String stat, String text, Color borderColor) {
  return TableRow(
    children: <Widget> [
      Container(
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: borderColor,
              width: 0.5,
            ),
          ),
        ),
        height: 35,
        child: Row(
          children: <Widget> [
            SizedBox(
              width: screenWidth*0.431,
              child: Text(
                stat,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                softWrap: false,
              ),
            ),
            SizedBox(width:screenWidth*0.161),
            SizedBox(
              width: screenWidth*0.323,
              child: Text(
                text,
                textAlign: TextAlign.right,
                softWrap: false,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            )
          ],
        ),
      ),
    ],
  );
}

