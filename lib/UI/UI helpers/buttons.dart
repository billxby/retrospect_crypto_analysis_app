import 'package:crypto_app/UI/UI%20helpers/alerts.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import '../../Functions/premium.dart';
import '../../main.dart';

List<String> alertChoices = ['Very Bearish', 'Bearish', 'Smwht Bearish', 'Smwht Bullish', 'Bullish', 'Very Bullish'];

SizedBox alertPredButton(int id, Color targetColor, Map<String, String> inputData, BuildContext context) {
  return SizedBox(
    height: 20,
    width: screenWidth*0.0809,
    child: ElevatedButton(
        onPressed: () {
          Map<String, String> alert = Map<String, String>.from(introdata.read("alerts"));

          if (alert.length < 20 || alert.containsKey(inputData['crypto'])) {
            if (alert.containsKey(inputData['crypto'])) {
              alert.update(inputData['crypto']!, (value) => value = alertChoices[id]);
            }
            else {
              alert[inputData['crypto']!] = alertChoices[id];
            }

            introdata.write("alerts", alert);
          }

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
          backgroundColor: targetColor,
        )
    ),
  );
}