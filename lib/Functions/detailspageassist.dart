import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../UI/UI helpers/textelements.dart';
import '../UI/detailspage.dart';

Color getTextColor(String input) {
  Color cur = Colors.green;

  if (input != null) {
    if (input.contains("-")) {
      cur = Colors.red;
    }
  }

  return cur;
}

Color getSpecialTextColor(String input) {
  Color cur = Colors.green;

  if (input != null) {
    if (input.contains("-")) {
      cur = Colors.red;
    }
    if (int.parse(input) > 100) {
      cur = Colors.lightBlue;
    }
  }

  return cur;
}

List<String> updateStartEnd(String input) {
  String before = "+", after = "";

  if (input.contains("-")) {
    before = "";
  }
  if (int.parse(input) > 100) {
    after = "!";
  }

  return <String> [
    before, after
  ];
}

List<double> updateMetrics(String input) {
  double start = 0, end = 0, min = -100, max = 100;

  if (input != "updating database") {
    if (double.parse(input) >= 0) {
      end = double.parse(input) <= 100
          ? double.parse(input)
          : 100;
    } else {
      start = double.parse(input) >= -100
          ? double.parse(input)
          : -100;
    }

    if (double.parse(input) < 40 &&
        double.parse(input) > -40) {
      min = -50;
      max = 50;
    }

    if (double.parse(input) < 20 &&
        double.parse(input) > -20) {
      min = -25;
      max = 25;
    }

    if (double.parse(input) < 8 &&
        double.parse(input) > -8) {
      min = -15;
      max = 15;
    }

    if (double.parse(input) < 4 &&
        double.parse(input) > -4) {
      min = -10;
      max = 10;
    }
  }

  return <double> [
    start, end, min, max
  ];
}

