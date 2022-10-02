import 'package:crypto_app/UI/UI%20helpers/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Functions/premium.dart';
import '../../main.dart';
import 'buttons.dart';

List<Color> alertColorChoices = [cRed, Color(0xffe57662), Colors.red.shade200, Colors.green.shade300, Color(0xff27c772), cGreen];

AlertDialog alertPage(BuildContext context, Map<String, String> inputData) {
  if (!userHasPremium()) {
    return AlertDialog(
      title: const Text("Alerts", textAlign: TextAlign.center),
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(20.0))),
      backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
      content: Text('This is a Premium Feature!', textAlign: TextAlign.center),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Map<String, String> alerts = Map<String, String>.from(localStorage.read("alerts"));

  return AlertDialog(
    title: const Text("Alerts", textAlign: TextAlign.center),
    shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.all(Radius.circular(20.0))),
    backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
    content: SizedBox(
      height: alerts.containsKey(inputData['crypto']) ? 140 : 120,
      child: Column(
        children: <Widget> [
          const Text('Get alerted when prediction is...'),
          Row(
            children: [
              Image.network("https://i.postimg.cc/mZVHWjHX/bear-v2.png", height: screenWidth*0.08),
              SizedBox(width: 5),
              alertPredButton(0, alertColorChoices[0], inputData, context),
              alertPredButton(1, alertColorChoices[1], inputData, context),
              alertPredButton(2, alertColorChoices[2], inputData, context),
              alertPredButton(3, alertColorChoices[3], inputData, context),
              alertPredButton(4, alertColorChoices[4], inputData, context),
              alertPredButton(5, alertColorChoices[5], inputData, context),
              SizedBox(width: 5),
              Image.network("https://i.postimg.cc/tCTVq6dX/bull-v2.png", height: screenWidth*0.08),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            width: screenWidth*0.54,
            color: darkTheme ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 15),
          Text(alerts.containsKey(inputData['crypto']) ? "Alert when ${(inputData['crypto'] ?? "none").capitalizeFirst} is ${alerts[inputData['crypto']]}" : "No alert set for ${(inputData['crypto'] ?? "none").capitalizeFirst}", textAlign: TextAlign.center),
          const Text("alerts will not work if the app is not running in bckgrd", style: TextStyle(fontSize: 9, height:2,)),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          alerts.remove(inputData['crypto']);

          localStorage.write("alerts", alerts);

          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (context) => alertPage(context, inputData),
          );
        },
        child: const Text('Remove', style: TextStyle(color: Colors.blue)),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, 'OK'),
        child: const Text('OK', style: TextStyle(color: Colors.blue)),
      ),
    ],
  );
}