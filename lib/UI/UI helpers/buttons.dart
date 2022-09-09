import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import '../../Functions/premium.dart';
import '../../main.dart';

List<String> alertChoices = ['Very Bearish', 'Bearish', 'Somewhat Bearish', 'Somewhat Bullish', 'Bullish', 'Very Bullish'];

SizedBox alertPredButton(int id, Color targetColor, Map<String, String> inputData) {
  return SizedBox(
    height: 20,
    width: 30,
    child: ElevatedButton(
        onPressed: () {
          print(introdata.read("alerts").runtimeType);
          Map<String, String> alert = Map<String, String>.from(introdata.read("alerts"));

          print(inputData);

          if (alert.length < 20 || alert.containsKey(inputData['crypto'])) {
            if (alert.containsKey(inputData['crypto'])) {
              alert.update(inputData['crypto']!, (value) => value = alertChoices[id]);
            }
            else {
              alert[inputData['crypto']!] = alertChoices[id];
            }

            introdata.write("alerts", alert);

            Workmanager().registerPeriodicTask("${inputData['crypto']}", "Alert", inputData: {"crypto":inputData['crypto'],"trigger":alertChoices[id]}, frequency: Duration(seconds: 5));
          }
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