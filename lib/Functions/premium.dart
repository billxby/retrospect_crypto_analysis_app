import 'dart:convert';
import 'package:crypto_app/Functions/cloudfunctionshelper.dart';
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

import '../main.dart';
import '../UI/UI helpers/textelements.dart';
import '../UI/detailspage.dart';

final introdata = GetStorage();

bool userHasPremium() {

  if (introdata.read("username") != "") {

    DateTime now = DateTime.now();
    DateTime begin = DateTime.fromMillisecondsSinceEpoch(0);

    if ((DateTime.fromMillisecondsSinceEpoch(premiumExpire) ?? begin).compareTo(now) > 0) {
      return true;
    }
  }

  return false;
}

bool userLimitAvailable(int passedIndex) {
  if (userHasPremium()) {
    return true;
  }
  String selectedCrypto = TopCryptos[Sort[sortBy]![passedIndex]].id;
  List<dynamic> used = introdata.read("used");
  if (introdata.read("used").contains(selectedCrypto)) {
    return true;
  }
  else if (introdata.read("used").length < limit) {
    used.add(selectedCrypto);
    introdata.write("used", used);
    return true;
  }
  else {
    return false;
  }

  return false;
}

bool redeemCreditsDetails(int passedIndex) {
  String selectedCrypto = TopCryptos[Sort[sortBy]![passedIndex]].id;
  List<dynamic> used = introdata.read("used");

  if (introdata.read("credits") >= 60) {
    int newNum = introdata.read("credits")-60;
    introdata.write("credits", newNum);
    used.add(selectedCrypto);
    introdata.write("used", used);
    return true;
  }
  else {
    return false;
  }
}