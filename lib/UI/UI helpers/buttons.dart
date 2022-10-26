import 'dart:convert';

import 'package:crypto_app/UI/UI%20helpers/alerts.dart';
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
          if (alerts.length < 20 || alerts.containsKey(inputData['crypto'])) {
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

            // localStorage.write("alerts", alert);
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