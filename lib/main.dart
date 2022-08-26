import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/Functions/purchase.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Functions/cloudfunctionshelper.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'UI/cryptosearchdelegate.dart';
import "UI/detailspage.dart";
import 'Functions/cryptoinfoclass.dart';
import 'UI/information.dart';
import 'UI/updatelog.dart';
import 'Functions/database.dart';
import 'UI/mainpages.dart';
import 'UI/adhelper.dart';
import 'firebase_options.dart';

//Program Settings
const int cryptosCap = 500;
const int maxFetchTries = 4;
final int limit = 5;
int premiumExpire = 0;
bool isPremium = false;

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

List<String> testDeviceIds = ["CFA4604CA7FDF96FC2E2B539F1B430E9"];

//Declare styles

//Settings variables
bool darkTheme = true;
String sortBy = "⬆A-Z";
bool worked = false;
String currentPromo = "none";
String offerMsg = "none";


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "Retrospect",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initPlatformState();
  // MobileAds.instance
  //   ..initialize()
  //   ..updateRequestConfiguration(
  //     RequestConfiguration(testDeviceIds: testDeviceIds),
  //   );
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
  introdata.writeIfNull("used", <String> []);
  introdata.writeIfNull("premiumUser", "");
  introdata.writeIfNull("last open", DateTime.now().millisecondsSinceEpoch);

  DateTime now = DateTime.now();
  if (DateTime.fromMillisecondsSinceEpoch(introdata.read("last open")).compareTo(DateTime(now.year, now.month, now.day, 0, 0, 0)) < 0) {
    introdata.write("used", <String> []);
  }

  darkTheme = introdata.read("darkTheme");
  introdata.write("last open", DateTime.now().millisecondsSinceEpoch);

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
      title: 'Retrospect',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: introdata.read("displayed") ? const MainPages() : IntroPage(),
    );
  }
}


