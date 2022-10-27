import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/UI/UI%20helpers/style.dart';
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
            series: <ColumnSeries<PriceData, String>>[
              ColumnSeries(
                dataSource: cryptoData,
                color: lineColor,
                xValueMapper: (PriceData prices, _) => DateFormat('MM-dd').format(prices.time),
                yValueMapper: (PriceData prices, _) => prices.price,
              )
            ],
          ),
        ),
      ],
    ),
  );
}

Container cryptoAnalChart(TrackballBehavior trackballBehavior,
    List<PriceData> cryptoData, bool showAxis, double width, Color? upAccent, Color? downAccent) {
  Color lineColor = cryptoData[0].price - cryptoData[cryptoData.length - 1].price > 0 ? Colors.blueAccent : Colors.lightBlueAccent;
  if (upAccent != null) {
    lineColor = ((cryptoData[0].price - cryptoData[cryptoData.length - 1].price > 0) ? upAccent : downAccent) ?? Colors.blueAccent;
  }
  List<PriceData> horizontalLine = [];

  for (PriceData data in cryptoData) {
    horizontalLine.add(
      PriceData(
        data.time,
        0,
      )
    );
  }

  return Container(
    height: 300,
    width: width,
    child: Column(
      children: <Widget>[
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 285,
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
            onTrackballPositionChanging: (TrackballArgs args) {
              ChartSeries<dynamic, dynamic> series = args.chartPointInfo.series as ChartSeries;
              if (series.name == 'Line') {
                args.chartPointInfo.header = '';
                args.chartPointInfo.label = '';
              }
            },
            series: <LineSeries<PriceData, String>>[
              LineSeries<PriceData, String>(
                color: Colors.grey[200],
                width: 0.2,
                dataSource: horizontalLine,
                name: "Line",
                xValueMapper: (PriceData prices, _) =>
                    DateFormat('MM-dd').format(prices.time),
                yValueMapper: (PriceData prices, _) => prices.price,
              ),
              LineSeries<PriceData, String>(
                color: lineColor,
                dataSource: cryptoData,
                name: "Data",
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


