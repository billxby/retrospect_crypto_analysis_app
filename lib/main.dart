import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'UI/cryptosearchdelegate.dart';
import "UI/detailspage.dart";
import 'Functions/cryptoinfoclass.dart';
import 'UI/information.dart';
import 'UI/updatelog.dart';
import 'Functions/database.dart';
import 'UI/mainpages.dart';
import 'UI/adhelper.dart';

//Program Settings
const int cryptosCap = 500;
const int maxFetchTries = 4;

//Declare variables
List<String> CryptosList = [];
Map<String, int> CryptosIndex = {};
List<CryptoInfo> TopCryptos = [];
Map<String, List<int>> Sort = {};
List<int> Ascending = [];
List<int> Descending = [];
List<int> MarketCapA = [];
List<int> MarketCapD = [];
List<int> ChangeA = [];
List<int> ChangeD = [];

DateTime lastRefreshed = DateTime.now();
int globalIndex = 0;
List<dynamic> data = [];

List<String> testDeviceIds = ['CECBD9E93B5FEC5E0260450BD959DA93'];

//Declare styles

//Settings variables
bool darkTheme = true;
String sortBy = "⬆A-Z";
bool worked = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'Retrospect',
    options: DefaultFirebaseOptions.currentPlatform,
  );


  MobileAds.instance
    ..initialize()
    ..updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: testDeviceIds),
    );
  // MobileAds.instance.initialize();
  // RequestConfiguration configuration = RequestConfiguration(testDeviceIds: testDeviceIds);
  // MobileAds.instance.updateRequestConfiguration(configuration);

  await GetStorage.init();
  final introdata = GetStorage();

  final worked = await fetchDatabase();

  if (worked == false) {
    exit(0);
  }

  DateTime lastRefreshed = DateTime.now();

  introdata.writeIfNull("displayed", false);
  introdata.writeIfNull("darkTheme", true);
  introdata.writeIfNull("credits", 0);
  introdata.writeIfNull("logged in", false);
  introdata.writeIfNull("username", "");
  introdata.writeIfNull("password", "");

  darkTheme = introdata.read("darkTheme");

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final introdata = GetStorage();

  @override
  Widget build(BuildContext context) {

    // introdata.write("displayed", false);
    if (darkTheme == true) {
      Get.changeTheme(ThemeData.dark());
    }
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: introdata.read("displayed") ? const MainPages() : IntroPage(),
    );
  }
}


