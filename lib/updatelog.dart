import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:settings_ui/settings_ui.dart';
import 'cryptosearchdelegate.dart';
import "detailspage.dart";
import 'cryptoinfoclass.dart';
import 'package:get/get.dart';

class UpdateLog extends StatelessWidget {
  const UpdateLog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Log'),
        centerTitle: true,
        toolbarHeight: 35,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    height: 70,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            "08.08.2022",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "- Updated UI and allowed user to re-enable welcome screen",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ])),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    height: 50,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            "08.03.2022",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "- Added Intro Screen",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ])),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    height: 70,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            "07.21.2022",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "- Added Crypto Prediction Analysis Using \n  DecisionTreeRegressor",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ])),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    height: 50,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            "07.02.2022",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "- Added Cryptos Sort",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ])),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    height: 50,
                    width: 350,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            "06.27.2022",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "- Added Settings",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ])),
              ),
              const SizedBox(
                height: 30,
              ),
            ]),
      ),
    );
  }
}
