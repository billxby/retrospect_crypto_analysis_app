import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/UI/delete_account.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../change_password.dart';
import '../detailspage.dart';

Color cGreen = Color(0xff0DC9AB);
Color cRed = Color(0xffF45656);

const Color lightGreen = Color(0xffabf7c1);
const Color lightRed = Color(0xfff7abab);

Text listviewTextTitle(String content) {
  return Text(
    content,
    style:
        const TextStyle(height: 1.4, fontSize: 14, fontWeight: FontWeight.bold),
  );
}

Text listviewTextInfo(String content, Color color) {
  return Text(content,
      style: TextStyle(
        height: 1.6,
        fontSize: 13,
        color: color,
      ));
}

Text detailsPageTitle(String content) {
  return Text(
    content,
    style:
        const TextStyle(height: 2, fontSize: 15, fontWeight: FontWeight.bold),
  );
}

Text detailsPageInfo(String content, Color color) {
  return Text(
    content,
    style: TextStyle(
      height: 2.2,
      fontSize: 14,
      color: color,
    ),
  );
}

Text additionalInfo(String content, bool italic) {
  return Text(
    content,
    style: TextStyle(
      height: 1,
      fontSize: 15,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    ),
  );
}

Row title(String content) {
  return Row(children: <Widget>[
    Text(
      content,
      style: titleStyle,
    )
  ]);
}

TextStyle blueRetroTitleStyle = const TextStyle(
  height: 2,
  fontSize: 15,
  fontWeight: FontWeight.bold,
  color: Colors.lightBlueAccent,
);

TextStyle blueTitleStyle = const TextStyle(
  height: 2,
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.lightBlue,
);

TextStyle titleStyle = TextStyle(
  height: 2,
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: darkTheme ? Colors.white : Colors.black,
);

Text buttonBlueText(String content) {
  return Text(
    content,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.blue,
    ),
  );
}

TextStyle hugeTitleStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

Icon creditImage = const Icon(
  Icons.donut_large,
  size: 28,
  color: Colors.blue,
);



TableRow buildRow(List<String> cells, {bool isHeader = false}) => TableRow(
  children: cells.map((cell) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: 14,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(child: Text(cell, style: style)),
    );
  }).toList(),
);

TextStyle tableStyleHeader({bool isHeader = false}) {
  return TextStyle(
    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    fontSize: 18,
    height: 2,
  );
}

TextStyle tableStyle({bool isHeader = false}) {
  return TextStyle(
    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    fontSize: 14,
    height: 3,
  );
}

TextStyle tableStyleBelow({bool isHeader = false}) {
  return TextStyle(
    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    fontSize: 14,
    height: 2,
  );
}

TableRow compareRow(String text1, String text2, String text3) {
  return TableRow(
      children: <Widget>[
        Container(
          color: Colors.blue,
          child: Text(text1, style:tableStyle(isHeader: true), textAlign: TextAlign.center),
        ),
        Text(text2, style:tableStyle(), textAlign: TextAlign.center),
        Text(text3, style:const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 3,
          color: Colors.blue,
        ), textAlign: TextAlign.center),
      ]
  );
}

TableRow infoRow(String stat, String text, Color borderColor) {
  return TableRow(
    children: <Widget> [
      Container(
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: borderColor,
              width: 0.5,
            ),
          ),
        ),
        height: 35,
        child: Row(
          children: <Widget> [
            SizedBox(
              width: screenWidth*0.431,
              child: Text(
                stat,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                softWrap: false,
              ),
            ),
            SizedBox(width:screenWidth*0.161),
            SizedBox(
              width: screenWidth*0.323,
              child: Text(
                text,
                textAlign: TextAlign.right,
                softWrap: false,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            )
          ],
        ),
      ),
    ],
  );
}

ButtonStyle roundButton(Color color) {
  return ButtonStyle(
    overlayColor: MaterialStateColor.resolveWith((states) => Colors.black12),
    backgroundColor: MaterialStatePropertyAll<Color>(color),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        )
    ),
  );
}

Row infoWidget(String title, String description, String url, IconData icon) {
  return Row(
    children: [
      Container(
          width: screenWidth*0.7,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.white10,
          ),
          padding: const EdgeInsets.all(2),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget> [
                      SizedBox(
                        width: screenWidth*0.03,
                      ),
                      Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Icon(
                        icon,
                      )
                    ]
                ),
                SizedBox(height: 20),
                SizedBox(
                    width: screenWidth*0.62,
                    child: Column(
                        children: <Widget> [
                          Text(description, style: TextStyle(fontSize: 15), textAlign: TextAlign.left,),
                        ]
                    )
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(width: screenWidth*0.03),
                    ElevatedButton(
                      style: roundButton(Colors.white),
                      onPressed: () {
                        launch(url);
                      },
                      child: Text('Learn More', style: TextStyle(color: Colors.black,)),
                    ),
                  ],
                )

              ]
          )
      ),
      SizedBox(
        width: screenWidth*0.07,
      ),
    ],
  );
}