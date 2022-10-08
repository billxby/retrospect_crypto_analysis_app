import 'dart:convert';
import 'package:crypto_app/Functions/cloudfunctionshelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../UI/UI helpers/style.dart';
import '../UI/detailspage.dart';

final localStorage = GetStorage();

bool userHasPremium() {
  return isPremium;
}

bool userLimitAvailable(int passedIndex) {
  if (userHasPremium()) {
    return true;
  }
  String selectedCrypto = TopCryptos[Sort["⬆A-Z"]![passedIndex]].id;
  List<dynamic> used = localStorage.read("used");
  if (localStorage.read("used").contains(selectedCrypto)) {
    return true;
  } else if (localStorage.read("used").length < limit) {
    used.add(selectedCrypto);
    localStorage.write("used", used);
    return true;
  } else {
    return false;
  }
}

Future<bool> redeemCreditsDetails(int passedIndex) async {
  String selectedCrypto = TopCryptos[passedIndex].id;
  List<dynamic> used = localStorage.read("used");

  User? user = FirebaseAuth.instance.currentUser;

  final db = FirebaseFirestore.instance;
  await db.collection("users").doc(user?.uid).get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['credits'] >= 50) {
        db.collection("users").doc(user?.uid).update({'credits': data['credits']-50}).then((value) {},
            onError: (e) {
              return false;
            }
        );
        used.add(selectedCrypto);
        localStorage.write("used", used);
        return true;
      }
    },
    onError: (e) {
      print("error getting doc");
      return false;
    },
  );
  return false;
}

refDialog(BuildContext context, String title, String content) {
  return AlertDialog(
    title: Text(title),
    backgroundColor: Theme.of(context).colorScheme.tertiary,
    content: Text(content),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'OK'),
        child: const Text('OK', style: TextStyle(color: Colors.blue)),
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
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      title: const Text('Redeem Premium?'),
      content: Text('Redeem $days days of Premium for $requirement credits?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () async {
            bool worked = await redeemCreditsPremium(days, requirement);

            print("worked is $worked");

            if (worked == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(20.0))),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    title: const Text('Successful!'),
                    content: const Text('Go to Settings and click "REFRESH PREMIUM STATUS". \n Enjoy your premium subscription!', textAlign: TextAlign.center,),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK', style: TextStyle(color: Colors.blue)),
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
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    title: const Text('An Error Occurred!'),
                    content: const Text(
                        'You either already have premium or do not have enough credits'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          child: const Text('OK', style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}

Future<bool> redeemCreditsPremium(int days, int require) async {
  if (userHasPremium()) {
    return false;
  }

  User? user = FirebaseAuth.instance.currentUser;

  final db = FirebaseFirestore.instance;
  bool worked = await db.collection("users").doc(user?.uid).get().then((DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    if (data['credits'] >= require) {
      db.collection("users").doc(user?.uid).update({'credits': data['credits']-require}).then((value) {},
          onError: (e) {
            print("Error updating document: $e");
            return false;
          }
      );
      String duration = "daily";

      switch(days) {
        case 7: {duration = "weekly"; }
          break;

        case 28: {duration = "monthly"; }
          break;
      }
      bool worked = await redeemPremiumFunction(duration);
      return worked;
    }
    return false;

  },
    onError: (e) {
      print("Error getting document: $e");
      return false;
    },
  );
  return worked;

}
