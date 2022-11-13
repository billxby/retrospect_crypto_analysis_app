import 'dart:convert';

import 'package:crypto_app/UI/UI%20helpers/alerts.dart';
import 'package:crypto_app/UI/get_premium.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import '../../Functions/database.dart';
import '../../Functions/premium.dart';
import '../../main.dart';

List<String> alertChoices = ['Very Bearish', 'Bearish', 'Smwht Bearish', 'Smwht Bullish', 'Bullish', 'Very Bullish'];

SizedBox alertPredButton(int id, Color targetColor, Map<String, String> inputData, BuildContext context) {
  return SizedBox(
    height: 20,
    width: screenWidth*0.0809,
    child: ElevatedButton(
        onPressed: () async {
          final ref = FirebaseDatabase.instance.ref('alerts/users/${FirebaseAuth.instance.currentUser?.uid}');
          refreshAlerts();

          Map<String, String> newAlert = {};
          if (alerts.length < (userHasPremium() ? 100 : 5) || alerts.containsKey(inputData['crypto'])) {
            if (alerts.containsKey(inputData['crypto'])) {
              print("contain");
              alerts.update(inputData['crypto']!, (value) => value = alertChoices[id]);
            }
            else {
              print("doesn't contain");
              alerts[inputData['crypto']!] = alertChoices[id];
            }

            await ref.set(alerts);

            newAlert[FirebaseAuth.instance.currentUser?.uid ?? "None"] = alertChoices[id];
          }
          else {
            if (userHasPremium()) {
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('You have reached 100 Alerts!'),
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(20.0))),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: const <Widget>[
                          Text('We\'d give you more alerts but our server would die. Thanks for you support <3'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Ok', style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                    ],
                  );
                },
              );
            }
            else {
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('You have reached 5 Alerts!'),
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(20.0))),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: const <Widget>[
                          Text('To get more alerts, consider getting Premium!'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Ok', style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text('Premium', style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GetPremiumPage()),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            }
            return;
          }

          if (newAlert.containsKey("None")) {
            return;
          }

          final secondRef = FirebaseDatabase.instance.ref('alerts/predictions/${inputData['crypto']}/');
          secondRef.update(newAlert);

          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (context) => alertPage(context, inputData),
          );

        },
        child: null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          primary: targetColor,
        )
    ),
  );
}