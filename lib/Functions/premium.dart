import 'dart:convert';
import 'package:crypto_app/Functions/cloudfunctionshelper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
  if (isPremium) {
    return true;
  }

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
  String selectedCrypto = TopCryptos[Sort["⬆A-Z"]![passedIndex]].id;
  List<dynamic> used = introdata.read("used");
  if (introdata.read("used").contains(selectedCrypto)) {
    return true;
  } else if (introdata.read("used").length < limit) {
    used.add(selectedCrypto);
    introdata.write("used", used);
    return true;
  } else {
    return false;
  }

  return false;
}

bool redeemCreditsDetails(int passedIndex) {
  String selectedCrypto = TopCryptos[passedIndex].id;
  List<dynamic> used = introdata.read("used");

  if (introdata.read("credits") >= 50) {
    int newNum = introdata.read("credits") - 50;
    introdata.write("credits", newNum);
    used.add(selectedCrypto);
    introdata.write("used", used);
    return true;
  } else {
    return false;
  }
}

refDialog(BuildContext context, String title, String content) {
  return AlertDialog(
    title: Text(title),
    backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
    content: Text(content),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'OK'),
        child: const Text('OK'),
      ),
    ],
  );
}

redeemPremiumDialog(BuildContext context, int days, int requirement) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(20.0))),
      backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
      title: const Text('Redeem Premium?'),
      content: Text('Redeem $days days of Premium for $requirement credits?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            bool worked = await redeemCreditsPremium(days, requirement);
            if (worked == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(20.0))),
                    backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
                    title: const Text('Successful!'),
                    content: const Text('Enjoy your premium subscription!'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(20.0))),
                    backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
                    title: const Text('An Error Occurred!'),
                    content: const Text(
                        'You either already have premium or do not have enough credits'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

limitDialog(BuildContext context, int index) {
  return AlertDialog(
    title: const Text('Limit Reached'),
    content: Text(
        'You have reached your daily limit of cryptocurrency analysis ☹️  \n\nYou still have access to: ${introdata.read("used")}\n\nGet premium to access more!'),
        //'You have reached your daily limit of cryptocurrency analysis ☹️  \n\nYou may use your credits or get premium to access more'),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: const Text('Cancel'),
      ),
    ],
  );
}

Future<bool> redeemCreditsPremium(int days, int require) async {
  if (introdata.read("credits") >= require) {
    int newNum = introdata.read("credits") - require;
    introdata.write("credits", newNum);

    bool worked = await redeemPremium(introdata.read("username"), days~/7);

    return worked;
  }

  return false;
}
