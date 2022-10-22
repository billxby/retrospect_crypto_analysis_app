import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:crypto_app/Functions/purchase.dart';
import 'package:crypto_app/UI/UI%20helpers/style.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'Functions/cloudfunctionshelper.dart';
import 'Functions/premium.dart';
import 'UI/UI helpers/pages.dart';
import 'UI/UI helpers/themes.dart';
import 'UI/notifications.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cron/cron.dart';
import 'package:flutter/services.dart';

import 'UI/cryptosearchdelegate.dart';
import "UI/detailspage.dart";
import 'Functions/cryptoinfoclass.dart';
import 'UI/information.dart';
import 'UI/updatelog.dart';
import 'Functions/database.dart';
import 'UI/mainpages.dart';
import 'firebase_options.dart';

//Program Settings
const int cryptosCap = 500;
const int maxFetchTries = 4;
final int limit = 5;
int premiumExpire = 0;
bool isPremium = false;
bool loggedIn = false;
bool rememberMe = false;

//Declare variables
List<String> CryptosList = [];
Map<String, int> CryptosIndex = {};
List<CryptoInfo> TopCryptos = [];
Map<String, List<int>> Sort = {};
Map<dynamic, dynamic> alerts = {};
List<int> Ascending = [];
List<int> Descending = [];
List<int> MarketCapA = [];
List<int> MarketCapD = [];
List<int> ChangeA = [];
List<int> ChangeD = [];

DateTime lastRefreshed = DateTime.now();
int globalIndex = 0;
Map<String, dynamic> data = {};
const fetchBackground = "getAlerts";

//Declare styles

//Settings variables
String sortBy = "↑A-Z";
int sortByIdx = 1;
bool worked = false;
String currentPromo = "none";
String offerMsg = "none";
String app_version = "0.2.0";
String new_version = app_version;
double screenWidth = 0.0;
double screenHeight = 0.0;
bool useMobileLayout = true;
bool darkTheme = true;
final LocalNotificationService service = LocalNotificationService();

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  await initPlatformState();

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
      print('User is currently signed out!');
      loggedIn = false;
      await Purchases.logOut();
    } else {
      print('User is signed in with UID ${user.uid}!');
      loggedIn = true;
      LogInResult result = await Purchases.logIn(user.uid);
      print(result.customerInfo);
    }
  });

  service.intialize();
  listenToNotification();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);


  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  await GetStorage.init();
  final localStorage = GetStorage();

  final worked = await fetchDatabase();
  await appVersion();

  if (worked == false) {
    exit(0);
  }

  DateTime lastRefreshed = DateTime.now();

  final cron = Cron();

  cron.schedule(Schedule.parse('*/5 * * * *'), () async {
    print("Every 5 minutes");
    getAlerts();
  });

  // Workmanager().registerPeriodicTask("taskOne", "alerts");

  localStorage.writeIfNull("displayed", false);
  localStorage.writeIfNull("credits", 0);
  localStorage.writeIfNull("username", "");
  localStorage.writeIfNull("password", "");
  localStorage.writeIfNull("used", <String> []);
  localStorage.writeIfNull("last open", DateTime.now().millisecondsSinceEpoch);
  localStorage.writeIfNull("alerts", <String, String> {});
  localStorage.writeIfNull("starred", <int> []);
  localStorage.writeIfNull("notificationN", 0);
  // final prefs = await SharedPreferences.getInstance();
  // final int? notificationIdN = prefs.getInt('notificationN');
  //
  // if (notificationIdN == null) {
  //   await prefs.setInt('notificationN', 0);
  // }


  var brightness = SchedulerBinding.instance!.window.platformBrightness;
  bool isDarkMode = brightness == Brightness.dark;

  localStorage.writeIfNull("darkTheme", isDarkMode);
  darkTheme = localStorage.read("darkTheme");

  DateTime now = DateTime.now();
  if (DateTime.fromMillisecondsSinceEpoch(localStorage.read("last open")).compareTo(DateTime(now.year, now.month, now.day, 0, 0, 0)) < 0) {
    localStorage.write("used", <String> []);
  }

  Map<String, String> alerts = Map<String, String>.from(localStorage.read("alerts"));
  List<String> toRemove = [];

  localStorage.write("last open", DateTime.now().millisecondsSinceEpoch);


  runApp(
    MultiProvider( // create the provider
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localStorage = GetStorage();

    return OverlaySupport.global(child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Retrospect',
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      home: app_version == new_version ? localStorage.read("displayed") ? const MainPages() : IntroPage() : const UpdateApp(),
    ));
  }
}

Future<void> getAlerts() async {
  await GetStorage.init();
  final localStorage = GetStorage();
  List<String> toRemove = [];
  Map<String, String> alerts = Map<String, String>.from(localStorage.read("alerts"));
  print(alerts);

  await fetchDatabase();
  for (String crypto in alerts.keys) {
    int idx = CryptosIndex[crypto] ?? 0;

    if (TopCryptos[idx].prediction == alerts[crypto]) {
      toRemove.add(crypto);
      await service.showNotificationWithPayload(
          id: localStorage.read("notificationN"),
          title: '${crypto.capitalizeFirst} Predictions Change!',
          body: '${crypto.capitalizeFirst}\'s rating is now ${alerts[crypto]}',
          payload: idx.toString());
      localStorage.write("notificationN", localStorage.read("notificationN")+1);
    }
  }

  for (String remove in toRemove) {
    alerts.remove(remove);
  }

  localStorage.write("alerts", alerts);
}

void listenToNotification() => service.onNotificationClick.stream.listen(onNoticationListener);

void onNoticationListener(String? payload) {
  if (payload != null && payload.isNotEmpty) {
    print('payload $payload');

    Get.to(DetailsPage(passedIndex: int.tryParse(payload) ?? 0));
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Container(
        height: 250,
        width: 250,
        child: Image.asset(
          "images/Loading.gif"
        )
      ),
      nextScreen: app_version == new_version ? localStorage.read("displayed") ? const MainPages() : IntroPage() : const UpdateApp(),
      backgroundColor: Colors.black,
      animationDuration: Duration(milliseconds: 50),
      splashIconSize: 250,
    );
  }
}

