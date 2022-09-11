import 'package:flutter/material.dart';
import '../../main.dart';
import 'buttons.dart';

AlertDialog alertPage(BuildContext context, Map<String, String> inputData) {
  return AlertDialog(
    title: const Text("Alerts", textAlign: TextAlign.center),
    backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
    content: Text('Alerts coming out soon!', textAlign: TextAlign.center),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, 'OK'),
        child: const Text('OK'),
      ),
    ],
  );
  // return AlertDialog(
  //   title: const Text("Alerts", textAlign: TextAlign.center),
  //   content: SizedBox(
  //     height: 100,
  //     child: Column(
  //       children: <Widget> [
  //         Text('Get alerted when predictions go to...'),
  //         Row(
  //           children: [
  //             Image.network("https://i.postimg.cc/0yxgzGs1/bear.png", height: 35),
  //             SizedBox(width: 5),
  //             alertPredButton(0, Colors.red.shade900, inputData),
  //             alertPredButton(1, Colors.red.shade600, inputData),
  //             alertPredButton(2, Colors.red.shade300, inputData),
  //             alertPredButton(3, Colors.green.shade300, inputData),
  //             alertPredButton(4, Colors.green.shade600, inputData),
  //             alertPredButton(5, Colors.green.shade900, inputData),
  //             SizedBox(width: 5),
  //             Image.network("https://i.postimg.cc/SNcFQTHG/bull.png", height: 35),
  //           ],
  //         ),
  //       ],
  //     ),
  //   ),
  //   actions: <Widget>[
  //     TextButton(
  //       onPressed: () => Navigator.pop(context, 'Cancel'),
  //       child: const Text('Cancel'),
  //     ),
  //     TextButton(
  //       onPressed: () => Navigator.pop(context, 'OK'),
  //       child: const Text('OK'),
  //     ),
  //   ],
  // );
}