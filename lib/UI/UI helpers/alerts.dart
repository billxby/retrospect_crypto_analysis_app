import 'package:crypto_app/UI/UI%20helpers/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Functions/database.dart';
import '../../Functions/premium.dart';
import '../../main.dart';
import 'buttons.dart';

List<Color> alertColorChoices = [cRed, Color(0xffe57662), Colors.red.shade200, Colors.green.shade300, Color(0xff27c772), cGreen];

AlertDialog alertPage(BuildContext context, Map<String, String> inputData) {
  refreshAlerts();

  if (!loggedIn) {
    return AlertDialog(
      title: const Text("Alerts", textAlign: TextAlign.center),
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(20.0))),
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      content: Text('Please Log In!', textAlign: TextAlign.center),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  return AlertDialog(
    title: const Text("Alerts", textAlign: TextAlign.center),
    shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.all(Radius.circular(20.0))),
    backgroundColor: Theme.of(context).colorScheme.tertiary,
    content: SizedBox(
      height: alerts.containsKey(inputData['crypto']) ? 140 : 120,
      child: Column(
        children: <Widget> [
          const Text('Get alerted when prediction is...'),
          Row(
            children: [
              Image.network("https://i.postimg.cc/mZVHWjHX/bear-v2.png", height: screenWidth*0.078),
              SizedBox(width: screenWidth*0.001),
              alertPredButton(0, alertColorChoices[0], inputData, context),
              alertPredButton(1, alertColorChoices[1], inputData, context),
              alertPredButton(2, alertColorChoices[2], inputData, context),
              alertPredButton(3, alertColorChoices[3], inputData, context),
              alertPredButton(4, alertColorChoices[4], inputData, context),
              alertPredButton(5, alertColorChoices[5], inputData, context),
              SizedBox(width: screenWidth*0.001),
              Image.network("https://i.postimg.cc/tCTVq6dX/bull-v2.png", height: screenWidth*0.078),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            width: screenWidth*0.54,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 15),
          Text(alerts.containsKey(inputData['crypto']) ? "Alert when ${(inputData['crypto'] ?? "none").capitalizeFirst} is ${alerts[inputData['crypto']]}" : "No alert set for ${(inputData['crypto'] ?? "none").capitalizeFirst}", textAlign: TextAlign.center),
          const Text("You will keep getting alerted until you remove your alert", style: TextStyle(fontSize: 10)),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () async {
          final ref = FirebaseDatabase.instance.ref('alerts/users/${FirebaseAuth.instance.currentUser?.uid}');
          refreshAlerts();

          alerts.remove(inputData['crypto']);

          ref.set(alerts);

          final ref2 = FirebaseDatabase.instance.ref('alerts/predictions/${inputData['crypto']}');
          ref2.update({"${FirebaseAuth.instance.currentUser?.uid}":null});

          Navigator.pop(context);
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