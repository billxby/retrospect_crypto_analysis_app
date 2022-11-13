import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cron/cron.dart';
import 'package:crypto_app/Functions/basicfunctions.dart';
import 'package:crypto_app/UI/get_premium.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Functions/accounts.dart';
import '../utils.dart';
import '../Functions/cloudfunctionshelper.dart';
import '../Functions/premium.dart';
import '../Functions/purchase.dart';
import 'UI helpers/paywallwidget.dart';
import 'UI helpers/themes.dart';
import 'change_password.dart';
import 'cryptosearchdelegate.dart';
import 'delete_account.dart';
import "detailspage.dart";
import '../Functions/cryptoinfoclass.dart';
import 'information.dart';
import 'login_page.dart';
import 'notifications.dart';
import 'updatelog.dart';
import '../Functions/database.dart';
import '../main.dart';
import 'UI helpers/style.dart';
import '../Functions/premium.dart';
import 'package:flutter/services.dart';
import 'package:number_slide_animation/number_slide_animation.dart';

bool fetching = false;
bool reloading = false;
bool loggingOut = false;
List<String> sortOptions = <String>['Starred', "↑A-Z", '↓A-Z', '↑Mrkt', '↓Mrkt', '↑24h', '↓24h', "↑Pred", '↓Pred', '↑Vol', '↓Vol',];
int credits = 0;

class MainPages extends StatefulWidget {
  const MainPages({Key? key}) : super(key: key);

  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> with WidgetsBindingObserver {
  late final FirebaseMessaging _messaging;
  late StreamSubscription iosSubscription;
  TextEditingController _referredByController = TextEditingController();
  bool referredIdValid = false;

  int maxFailedLoadAttempts = 3;
  int _selectedIndex = 1;
  final localStorage = GetStorage();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      if (event.notification == null) {
        return;
      }
      
      String bodyText = event.notification!.body ?? "";

      if (bodyText.indexOf(" is now") == -1) {
        showOverlayNotification((context) {
          return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                color: Colors.lightBlueAccent,
                child: SafeArea(
                  child: ListTile(
                    leading: SizedBox.fromSize(
                        size: const Size(40, 40),
                        child: ClipOval(
                          child: SizedBox(
                            child: Image.network(event.notification!.android?.imageUrl ?? ""),
                            width: 30,
                          ),)),
                    title: Text(event.notification!.title ?? ""),
                    subtitle: Text(event.notification!.body ?? ""),
                    tileColor: Colors.lightBlueAccent,
                    onTap: () {
                      if (bodyText.toLowerCase().indexOf("discord") != -1) {
                        launch("https://www.retrospectapps.com/join-discord");
                      }
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        OverlaySupportEntry.of(context)?.dismiss();
                      },
                    ),
                  ),
                ),
              )
          );
        }, duration: Duration(milliseconds: 60000));
        return;
      }

      String cryptoName = bodyText.substring(0, bodyText.indexOf(" is now")).toLowerCase();
      int targetIndex = CryptosIndex[cryptoName] ?? 0;

      showOverlayNotification((context) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            child: SafeArea(
              child: ListTile(
                leading: SizedBox.fromSize(
                    size: const Size(40, 40),
                    child: ClipOval(
                      child: SizedBox(
                        child: Image.network(event.notification!.android?.imageUrl ?? ""),
                        width: 30,
                      ),)),
                title: Text('Predictions Change!'),
                subtitle: Text(event.notification!.body ?? ""),
                tileColor: Theme.of(context).colorScheme.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailsPage(
                          passedIndex: Sort["↑A-Z"]?[targetIndex] ?? 0,
                        )),
                  );
                },
                trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context)?.dismiss();
                    },
                ),
              ),
            ),
          )
        );
      }, duration: Duration(milliseconds: 8000));

    });

    _referredByController.addListener(() {
      final String text = _referredByController.text;
      referredIdValid = text.length > 8;
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      return;
    }

    if (state == AppLifecycleState.resumed) {
      return;
    }

    final isBackground = state == AppLifecycleState.paused;

    if (isBackground) {
      print("Now in background");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future refreshPage() async {
    DateTime currentTime = DateTime.now();
    // Workmanager().registerOneOffTask("taskTwo", "alerts", initialDelay: Duration(seconds: 1));

    bool worked = await fetchDatabase();

    if (worked) {
      setState(() {
        TopCryptos = TopCryptos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localStorage = GetStorage();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    useMobileLayout = MediaQuery.of(context).size.shortestSide < 600;

    if (_selectedIndex == 0) {
      return FutureBuilder(
          future: checkPremium(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return homePage();
            }
            return homePage();
          }
      );
    }
    else if (_selectedIndex == 1) {
      return FutureBuilder(
          future: checkPremium(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Market'),
                  centerTitle: true,
                  toolbarHeight: 30,
                ),
                body: mainListings(),
                bottomNavigationBar: getBar(),
              );
            }
            return Scaffold(
              appBar: AppBar(
                  title: const Text('Market'),
                  centerTitle: true,
                  toolbarHeight: 30,
                  leadingWidth: 80,
                  elevation: 0,
                  actions: [
                    IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          showSearch(
                              context: context,
                              delegate: CryptosSearchDelegate(CryptosList));
                        })
                  ]),
              body: RefreshIndicator(
                  onRefresh:refreshPage,
                  child: mainListings()
              ),
              bottomNavigationBar: getBar(),
            );
          }
      );
    }
    else {
      return FutureBuilder(
          future: checkPremium(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return settingsPage();
            }
            return settingsPage();
          }
      );
      }
    }

  BottomNavigationBar getBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Theme.of(context).colorScheme.primary,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.show_chart,
          ),
          label: 'Market',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Theme.of(context).colorScheme.secondary,
    );
  }

  Column mainListings() {
    return Column(
      children: <Widget> [
        SizedBox(
          height: 45,
          child: ListView.builder(
            // This next line does the trick.
            scrollDirection: Axis.horizontal,
            itemCount: sortOptions.length,
            itemBuilder: (context, index) {
              return SizedBox(
                  width: sortOptions[index] == "Starred" ? 95 : 87,
                  child: Row(
                      children: <Widget> [
                        SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              sortByIdx = index;
                              sortBy = sortOptions[index];
                            });
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(sortByIdx == index ? Theme.of(context).colorScheme.onBackground : (Theme.of(context).colorScheme.background)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  )
                              )
                          ),
                          child: Text(sortOptions[index], style: TextStyle(color: sortByIdx == index ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.secondary,), softWrap: true,),
                        ),
                      ]
                  )
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: Sort[sortBy]?.length,
              itemBuilder: (context, index) {
                String currentPrice = TopCryptos[Sort[sortBy]![index]].current_price;
                String percentageChange = TopCryptos[Sort[sortBy]![index]].price_change_precentage_24h;

                return Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: ListTile(
                    tileColor: Colors.transparent,
                    onTap: () {},
                    title: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                passedIndex: Sort[sortBy]?[index] ?? 0,
                              )),
                        ).then((_)=>setState((){}));
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                              )
                          ),
                        overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.background),
                        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.background,),

                      ),
                      child: Center(
                        child: Row(
                          children: <Widget> [
                            CircleAvatar(
                              backgroundImage: NetworkImage(TopCryptos[Sort[sortBy]![index]].image),
                              backgroundColor: Colors.transparent,
                              radius: 23,
                            ),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: useMobileLayout ? screenWidth*0.429 : screenWidth*0.469,
                                  child: Text(
                                    TopCryptos[Sort[sortBy]![index]].id.capitalizeFirst ?? TopCryptos[Sort[sortBy]![index]].id,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                    softWrap: false,
                                  ),
                                ),
                                Text(
                                  TopCryptos[Sort[sortBy]![index]].symbol.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.left,
                                  softWrap: false,
                                ),
                                Row(
                                  children: <Widget>[
                                    listviewTextTitle("24h "),
                                    Image.network(
                                      !TopCryptos[Sort[sortBy]![index]].prediction.contains("Bearish") ? "https://i.postimg.cc/tgYj7XSn/bull-v2-offset.png" : "https://i.postimg.cc/BvkGKdkY/bear-v2-offset.png",
                                      width: 16,
                                    ),
                                    // listviewTextInfo(
                                    //     TopCryptos[Sort[sortBy]![index]].realScore,
                                    //     TopCryptos[Sort[sortBy]![index]]
                                    //         .realScore
                                    //         .contains("-")
                                    //         ? cRed
                                    //         : Color(0xff0DC9AB)),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: useMobileLayout ? screenWidth*0.27 : screenWidth*0.37,
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  !currentPrice.contains("e") ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      NumberSlideAnimation(
                                        number: currentPrice.substring(0, !currentPrice.contains(".") ? currentPrice.length : currentPrice.indexOf(".")),
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.bounceIn,
                                        textStyle: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      if (currentPrice.contains("."))
                                        const Text(
                                          ".",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      if (currentPrice.contains("."))
                                        Flexible(
                                          child: NumberSlideAnimation(
                                            number: currentPrice.substring(currentPrice.indexOf(".")+1, currentPrice.length-currentPrice.indexOf(".")+1 > 6 ? currentPrice.indexOf(".")+6 : currentPrice.length),
                                            duration: const Duration(milliseconds: 600),
                                            curve: Curves.bounceIn,
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                        )
                                    ],
                                  ) :
                                  Text(
                                    currentPrice,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${percentageChange.contains("-") ? "-" : "+"}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: percentageChange.contains("-") ? cRed : cGreen,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      NumberSlideAnimation(
                                        number: percentageChange.substring(percentageChange.contains("-") ? 1 : 0, percentageChange.indexOf(".")),
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.bounceIn,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          color: percentageChange.contains("-") ? cRed : cGreen,
                                        ),
                                      ),
                                      Text(
                                          ".",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: percentageChange.contains("-") ? cRed : cGreen,
                                          ),
                                        ),
                                      Flexible(
                                        child: NumberSlideAnimation(
                                            number: percentageChange.substring(percentageChange.indexOf(".")+1, percentageChange.length),
                                            duration: const Duration(milliseconds: 600),
                                            curve: Curves.bounceIn,
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              color: percentageChange.contains("-") ? cRed : cGreen,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        "%",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: percentageChange.contains("-") ? cRed : cGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    TopCryptos[Sort[sortBy]![index]].market_cap,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      height: 2,
                                    ),
                                    softWrap: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }


  Future<int> getCredits() async {
    return await checkPending(localStorage.read("username"), localStorage.read("password"));
  }

  StatefulWidget homePage() {
    return FutureBuilder(
        future: getCredits(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return homePageScaffold();
          }
          return homePageScaffold();
        }
    );
  }

  Scaffold homePageScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        toolbarHeight: 40,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              SizedBox(height: 30),
              Row(
                  children: <Widget> [
                    SizedBox(width: screenWidth*0.1),
                    Text(
                      FirebaseAuth.instance.currentUser?.displayName == null ? "Welcome back!" : "Welcome back, ${FirebaseAuth.instance.currentUser?.displayName}!",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Container(
                  height: 445,
                  width: screenWidth * 0.85+0.8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    color: Theme.of(context).colorScheme.background,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      SizedBox(height: 20),
                      Row(
                        children: <Widget> [
                          SizedBox(
                            width: screenWidth*0.05,
                          ),
                          Text("Watchlist", style: TextStyle(fontSize: 22, height: 1.2), textAlign: TextAlign.start,),
                        ],
                      ),
                      SizedBox(height: 15),
                      Sort['Starred']!.isEmpty ? Expanded(
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Spacer(flex: 6),
                              Icon(
                                Icons.star_border_outlined,
                                size: 80,
                              ),
                              Spacer(),
                              Text("You do not have any \"Starred\" cryptos yet! \n\n Get started by selecting ⭐ on the top bar"),
                              Spacer(flex: 12)
                            ],
                          ),
                        )
                      ) : Expanded(
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (Sort['Starred']?.length ?? 0) > 5 ? 5 : Sort['Starred']?.length ?? 0,
                            itemBuilder: (context, index) {
                              return ListTile(
                                tileColor: Colors.transparent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailsPage(
                                          passedIndex: Sort['Starred']?[index] ?? 0,
                                        )),
                                  ).then((_)=>setState((){}));
                                },
                                title: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: Colors.transparent,
                                  ),
                                  padding: const EdgeInsets.all(0),
                                  child: Center(
                                    child: Column(
                                      children: <Widget> [
                                        Row(
                                          children: <Widget> [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(TopCryptos[Sort['Starred']![index]].image),
                                              backgroundColor: Colors.transparent,
                                              radius: 20,
                                            ),
                                            SizedBox(
                                              width: screenWidth*0.02,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: useMobileLayout ? screenWidth*0.38 : screenWidth*0.4,
                                                  child: Text(
                                                    TopCryptos[Sort['Starred']![index]].id.capitalizeFirst ?? TopCryptos[Sort['Starred']![index]].id,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1.5,
                                                    ),
                                                    softWrap: false,
                                                  ),
                                                ),
                                                Text(
                                                  TopCryptos[Sort['Starred']![index]].symbol.toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                  softWrap: false,
                                                ),

                                                Row(
                                                  children: <Widget>[
                                                    listviewTextTitle("24h "),
                                                    Image.network(
                                                      !TopCryptos[Sort[sortBy]![index]].prediction.contains("Bearish") ? "https://i.postimg.cc/tgYj7XSn/bull-v2-offset.png" : "https://i.postimg.cc/BvkGKdkY/bear-v2-offset.png",
                                                      width: 16,
                                                    ),
                                                    // listviewTextTitle(" Vol "),
                                                    // listviewTextInfo(
                                                    //     TopCryptos[Sort[sortBy]![index]].total_volume,
                                                    //     darkTheme ? Colors.white : Colors.black),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: useMobileLayout ? screenWidth*0.23 : screenWidth*0.32,
                                              color: Colors.transparent,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                    TopCryptos[Sort['Starred']![index]].current_price,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.8,
                                                    ),
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    "${TopCryptos[Sort['Starred']![index]].price_change_precentage_24h.contains("-") ? "" : "+"}${TopCryptos[Sort['↓Mrkt']![index]].price_change_precentage_24h}%",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: TopCryptos[Sort['Starred']![index]].price_change_precentage_24h.contains("-") ? cRed : cGreen,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    TopCryptos[Sort['Starred']![index]].market_cap,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      height: 2,
                                                    ),
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]
                                    )
                                  ),
                                ),
                              );
                            }),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          children: [
                            SizedBox(
                              width: screenWidth*0.7,
                              child: Divider(
                                height: 0.5,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: TextButton(
                                  onPressed: () {
                                    _selectedIndex = 1;
                                    sortBy = "Starred";
                                    sortByIdx = 0;
                                    setState(() {});
                                  },
                                  style: ButtonStyle(
                                    overlayColor: MaterialStatePropertyAll<Color>(Colors.transparent),
                                  ),
                                  child: Text("View More", style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 14))
                              ),
                            )
                          ],
                        )
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 180,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                        ),
                        infoWidget("Blogs ", "Stay on top of the market with our Blogs", "https://www.retrospectapps.com/latest-blogs/", Icons.paste_rounded, Theme.of(context).colorScheme.background),
                        infoWidget("Charting ", "Chart out the Market for Technical Analysis!", "https://www.retrospectapps.com/latest-blogs/resources/how-to-technical-analysis/", Icons.bar_chart, Theme.of(context).colorScheme.background),
                        infoWidget("Sites ", "Check out our recommended Crypto Sites!", "https://www.retrospectapps.com/latest-blogs/beginners/top-cryptocurrency-websites/", Icons.currency_exchange, Theme.of(context).colorScheme.background),
                        infoWidget("Terms ", "Get to know the cryptocurrency terms!", "https://www.retrospectapps.com/latest-blogs/beginners/cryptocurrency-terms-for-beginners/", Icons.add_chart_rounded, Theme.of(context).colorScheme.background),
                        SizedBox(
                          width: screenWidth*0.05,
                        ),
                      ]
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                  height: 400,
                  width: screenWidth * 0.85,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).colorScheme.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: loggedIn ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      SizedBox(height: 20),
                      Row(
                        children: <Widget> [
                          SizedBox(
                            width: screenWidth*0.05,
                          ),
                          SizedBox(
                            width: screenWidth*0.3,
                            child: Text("Credits", style: TextStyle(fontSize: 22, height: 1.2), textAlign: TextAlign.start,),
                          ),
                          SizedBox(
                            width: screenWidth*0.44,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "$credits ",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.donut_large,
                                  size: 23,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ],
                            )
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Center(
                        child: Image.asset(
                          "images/main/home/Referral.png",
                          width: screenWidth*0.5,
                        ),
                      ),
                      Center(
                        child: Text("Tell your friends about this app! \n Get 200 Credits per person \n", textAlign: TextAlign.center,),
                      ),
                      Center(
                        child: ElevatedButton(
                          style: roundButton(Colors.white),
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    )
                                ),
                                builder: (context) => Center(
                                  child: SizedBox(
                                    width: screenWidth*0.8,
                                    child: Column(
                                        children: <Widget> [
                                          TextFormField(
                                            controller: _referredByController,
                                            decoration: InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText: 'Enter your Referrer\'s ID',
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary,),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary,),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          const Text('You will get 100 C if you complete this! \n\n',
                                              style: TextStyle(fontSize: 12,)
                                          ),
                                          SizedBox(height: 2),
                                          Image.asset(
                                            "images/main/home/Rewards.png",
                                            width: screenWidth*0.6,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                                text: 'For every person you refer, you will get Credits! Use credits to redeem',
                                                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary,),
                                                children: const <TextSpan> [
                                                  TextSpan(
                                                    text: ' Premium ',
                                                    style: TextStyle(color: Colors.blue),
                                                  ),
                                                  TextSpan(
                                                    text: ', or even get paid back in ',
                                                  ),
                                                  TextSpan(
                                                    text: 'Bitcoin!',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  )
                                                ]
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              overlayColor: MaterialStateColor.resolveWith((states) => Colors.black12),
                                              backgroundColor: MaterialStatePropertyAll<Color>(referredIdValid ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(25.0),
                                                  )
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (!referredIdValid) {
                                                return;
                                              }

                                              bool worked = await addReferrer(_referredByController.text);

                                              if (worked == false) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => refDialog(context, "Referred", "You have already done that prompt or user does not exist")
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => refDialog(context, "Successful", "You have completed the prompt! 😀")
                                                    // builder: (context) => refDialog(context, "Successful", "You have completed the prompt. \n Refresh your credits (scroll down) :)")
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text('Submit!', style: TextStyle(color: Theme.of(context).colorScheme.primary,)),
                                          ),
                                        ]
                                    ),
                                  )
                                )
                            );
                          },
                          child: Text('Someone Referred Me!', style: TextStyle(color: Colors.black,)),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          style: roundButton(Theme.of(context).colorScheme.secondaryVariant),
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    )
                                ),
                                builder: (context) => Center(
                                    child: SizedBox(
                                      width: screenWidth*0.8,
                                      child: Center(
                                        child: SingleChildScrollView(
                                          child: Column(children: <Widget>[
                                            Text(
                                              "Redeem",
                                              style: hugeTitleStyle,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            title("  1 day Premium: "),
                                            Center(
                                              child: OutlinedButton(
                                                onPressed: () => redeemPremiumDialog(context, 1, 250),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    buttonBlueText("250 "),
                                                    creditImage,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            title("  1 week Premium: "),
                                            Center(
                                              child: OutlinedButton(
                                                onPressed: () => redeemPremiumDialog(context, 7, 800),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    buttonBlueText("800 "),
                                                    creditImage,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            title("  4 weeks Premium: "),
                                            Center(
                                              child: OutlinedButton(
                                                onPressed: () => redeemPremiumDialog(context, 28, 1800),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    buttonBlueText("1800 "),
                                                    creditImage,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            title("  \$5 in Bitcoin: "),
                                            Center(
                                              child: OutlinedButton(
                                                onPressed: () {},
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    buttonBlueText("Coming Soon!"),
                                                    const Icon(
                                                      Icons.currency_bitcoin,
                                                      size: 24,
                                                      color: Colors.blue,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            title("  \$10 in Bitcoin: "),
                                            Center(
                                              child: OutlinedButton(
                                                onPressed: () {},
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    buttonBlueText("Coming Soon!"),
                                                    const Icon(
                                                      Icons.currency_bitcoin,
                                                      size: 24,
                                                      color: Colors.blue,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ])
                                        )
                                      ),
                                    ),
                                )
                            );
                          },
                          child: Text('Redeem', style: TextStyle(color: Colors.white,)),
                        ),
                      ),
                    ],
                  ) : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      SizedBox(height: 20),
                      Row(
                        children: <Widget> [
                          Spacer(),
                          Text("Sign In", style: TextStyle(fontSize: 22, height: 1.2), textAlign: TextAlign.center,),
                          Spacer(),
                        ],
                      ),
                      Spacer(),
                      Center(
                        child: Image.asset(
                          "images/main/home/Log In.png",
                          width: screenWidth*0.4,
                        ),
                      ),
                      Spacer(),
                      Center(
                        child: Text("Create an account to keep a watchlist, get Alerts, access in-depth Analysis, and more! \n", textAlign: TextAlign.center,),
                      ),
                      Spacer(flex: 2),
                      Center(
                        child: ElevatedButton(
                          style: roundButton(Theme.of(context).colorScheme.secondary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            ).then((_)=>setState((){}));
                          },
                          child: Text('Get Started', style: TextStyle(color: Theme.of(context).colorScheme.primary,)),
                        ),
                      ),
                      Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          )
      ),
      bottomNavigationBar: getBar(),
    );
  }

  Scaffold settingsPage() {
    TextEditingController _displayNameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        toolbarHeight: 40,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget> [
            SizedBox(height: 30),
            Center(
              child: Container(
                height: loggedIn ? 195 : 160,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Theme.of(context).colorScheme.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Row(
                        children: <Widget> [
                          Text("  Account ", style: TextStyle(fontSize: 22, height: 1.2), textAlign: TextAlign.start,),
                          Image.network(
                            userHasPremium() ? "https://i.postimg.cc/N0vc0vzn/Premium-Crown-Crisp.png" : "https://i.postimg.cc/N0c8Wqrw/Empty-Pixel.png",
                            height: 20,
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget> [
                          SizedBox(width: screenWidth*0.03),
                          Column(
                            children: <Widget> [
                              Container(height: 10, color: Colors.transparent),
                              CircleAvatar(
                                backgroundImage: AssetImage("images/Profile.png"),
                                backgroundColor: Colors.grey,
                                radius: 25,
                              ),
                            ]
                          ),
                          SizedBox(width: screenWidth*0.03),
                          if (loggedIn)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                Row(
                                  children: <Widget> [
                                    Text(FirebaseAuth.instance.currentUser?.displayName ?? "Set Name", style: TextStyle(fontSize: 17)),
                                    SizedBox(
                                      width: 12,
                                      child: IconButton(
                                        onPressed: () => showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) => AlertDialog(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(20.0))),
                                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                                            title: const Text('Set Name'),
                                            content: SizedBox(
                                              height: 100,
                                              child:  Column(
                                                  children: <Widget> [
                                                    TextFormField(
                                                      controller: _displayNameController,
                                                      decoration: InputDecoration(
                                                        border: UnderlineInputBorder(),
                                                        hintText: "Name",
                                                        enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary,),
                                                        ),
                                                        focusedBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary,),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                  ]
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                                child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  if (_displayNameController.text.isNotEmpty) {
                                                    await FirebaseAuth.instance.currentUser?.updateDisplayName(_displayNameController.text);
                                                  }
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('OK', style: TextStyle(color: Colors.blue)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        splashColor: Colors.transparent,
                                        icon: Icon(Icons.edit, size: screenWidth*0.04),
                                      ),
                                    )
                                  ]
                                ),
                                Text(FirebaseAuth.instance.currentUser?.email ?? "Please log in"),
                                if (FirebaseAuth.instance.currentUser?.uid != null)
                                  Row(
                                    children: [
                                      Text(FirebaseAuth.instance.currentUser?.uid ?? "Log In"),
                                      SizedBox(
                                        width: screenWidth*0.05,
                                        height: screenHeight*0.05,
                                        child: IconButton(
                                          icon: Icon(Icons.copy, size: 18),
                                          onPressed: () async {
                                            await Clipboard.setData(ClipboardData(text: FirebaseAuth.instance.currentUser?.uid));
                                          },
                                        )
                                      ),
                                    ],
                                  )
                              ]
                            )
                          else
                            Text("Please log in"),
                        ],
                      ),
                      if (loggedIn)
                        Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => GetPremiumPage()),
                                  ).then((_)=>setState((){}));
                                },
                                style: roundButton(Theme.of(context).colorScheme.secondary),
                                child: Text(userHasPremium() ? "See plans" : "Upgrade", style: TextStyle(color: Theme.of(context).colorScheme.primary))
                            ),
                        ),
                      if (!loggedIn)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget> [
                            SizedBox(
                              width: screenWidth*0.3,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                  ).then((_)=>setState((){}));
                                },
                                style: roundButton(Theme.of(context).colorScheme.secondary),
                                child: Text("Log In", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth*0.03,
                            ),
                          ],
                        ),

                    ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            settingsTile("Change Password", Icons.lock_open, 0, context),
            settingsTile("Retrospect Account", Icons.account_circle_outlined, 1, context),
            settingsTile("Alerts", Icons.notifications_none_rounded, 2, context),
            settingsTile("Refresh Premium Status", Icons.refresh_rounded, 3, context),
            settingsTile("Log Out", Icons.logout_rounded, 4, context),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenWidth*0.06
                ),
                Text("General", style: TextStyle(fontSize: 22,)),
              ],
            ),
            ElevatedButton(
                onPressed:() async {
                  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                  localStorage.write("darkTheme", !localStorage.read("darkTheme"));
                  setState(() {

                  });
                  localStorage.read("darkTheme") ? themeProvider.setDarkmode() : themeProvider.setLightMode();
                },
                style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
                  overlayColor: MaterialStateColor.resolveWith((states) => Colors.white24),
                  shadowColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
                ),
                child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1,
                            )
                        )
                    ),
                    width: screenWidth*0.9,
                    child: Row(
                        children: <Widget> [
                          SizedBox(width: screenWidth*0.01),
                          Icon(
                              Icons.dark_mode_outlined,
                              color: Theme.of(context).colorScheme.secondary
                          ),
                          SizedBox(width: screenWidth*0.03),
                          SizedBox(
                            width: screenWidth*0.7,
                            child: Text(
                                "Dark Theme", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, height: 1.5, color: Theme.of(context).colorScheme.secondary)
                            ),
                          ),
                          Container(
                              height: 20,
                              width: screenWidth*0.09,
                              child: Icon(
                                localStorage.read("darkTheme") ? Icons.toggle_on : Icons.toggle_off,
                                color: Theme.of(context).colorScheme.secondary,
                                // size: screenWidth*0.05,
                              )
                          )
                        ]
                    )
                )
            ),
            settingsTile("App Intro", Icons.phone_android_rounded, 5, context),
            settingsTile("Support", Icons.chat_bubble_outline_rounded, 6, context),
            settingsTile("Website", Icons.web_rounded, 7, context),
            settingsInfo("App Version", app_version, Icons.access_time_rounded),
          ],
        )
      ),
      bottomNavigationBar: getBar(),
    );
  }

  ElevatedButton settingsTile(String value, IconData icon, int functionN, BuildContext context) {
    return ElevatedButton(
        onPressed:() async {
          if (functionN < 5 && loggedIn == false) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            ).then((_)=>setState((){}));
            return;
          }

          switch(functionN) {
            case 0: {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdatePasswordPage()),
              );
            }
              break;

            case 1: {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeleteAccountPage()),
              );
            }
              break;

            case 2: {
              FirebaseMessaging messaging = FirebaseMessaging.instance;

              NotificationSettings settings = await messaging.requestPermission(
                alert: true,
                announcement: false,
                badge: true,
                carPlay: false,
                criticalAlert: false,
                provisional: false,
                sound: true,
              );

              if (settings.authorizationStatus == AuthorizationStatus.denied) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Please Enable Notifications!'),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(20.0))),
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: const <Widget>[
                              Text('Please Allow Notifications to allow alerts!'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK', style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      );
                    });

                return;
              }

              showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      )
                  ),
                  builder: (context) => Center(
                      child: !loggedIn ? Column(
                        children: [
                          SizedBox(
                              height: 10
                          ),
                          Text(
                            "Active Alerts",
                            style: TextStyle(fontSize: 20,),
                          ),
                          SizedBox(height: 120,),
                          Image.network("https://i.postimg.cc/VkpYychz/Lock.png", width: screenWidth*0.3),
                          SizedBox(height: 20,),
                          Text("Sign Up to Use Alerts! It's free.", style: TextStyle(fontSize: 17)),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => GetPremiumPage()),
                                ).then((_)=>setState((){}));
                              },
                              style: roundButton(Colors.white),
                              child: Text("Sign Up!", style: TextStyle(color: Colors.black, fontSize: 15),)
                          ),
                        ],
                      ) : configureAlerts()
                  )
              );
            }
              break;

            case 3: {
              if (reloading == false) {
                reloading = true;
                await initPlatformState();
                setState(() {});
                await Future.delayed(Duration(seconds: 10));
                reloading = false;
              }
            }
              break;

            case 4: {
              if (loggingOut == true) {
                return;
              }
              loggingOut = true;

              final fcmToken = await FirebaseMessaging.instance.getToken();
              final db = FirebaseFirestore.instance;
              User? user = await FirebaseAuth.instance.currentUser;

              final docRef = db.collection("users").doc(user?.uid);
              await docRef.get().then((DocumentSnapshot doc) async {
                final data = doc.data() as Map<String, dynamic>;
                List<dynamic> fcmTokens = [];
                if (data.containsKey("fcm_tokens")) {
                  fcmTokens = data["fcm_tokens"];
                }
                if (fcmTokens.contains(fcmToken)) {
                  fcmTokens.removeWhere((item) => item == fcmToken);
                  Map<String, dynamic> entry = {};
                  entry["fcm_tokens"] = fcmTokens;

                  docRef.update(
                      entry
                  );
                  print("Removed token for user");
                }
              },
                onError: (e) => print("Error getting document: $e"),
              );

              await FirebaseAuth.instance.signOut();
              isPremium = false;
              loggingOut = false;
              setState(() {});
            }
              break;

            case 5: {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IntroPage()),
              );
            }
              break;

            case 6: {
              launch("https://www.retrospectapps.com/join-discord");
            }
              break;

            case 7: {
              launch("https://www.retrospectapps.com");

            }
          }
        },
        style: ButtonStyle(
          backgroundColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
          overlayColor: MaterialStateColor.resolveWith((states) => localStorage.read("darkTheme") ? Colors.white24 : Colors.black12),
          shadowColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
        ),
        child: Container(
            height: 45,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1,
                    )
                )
            ),
            width: screenWidth*0.9,
            child: Row(
                children: <Widget> [
                  SizedBox(width: screenWidth*0.01),
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.secondary
                  ),
                  SizedBox(width: screenWidth*0.03),
                  SizedBox(
                    width: screenWidth*0.7,
                    child: Text(
                        value, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, height: 1.5, color: Theme.of(context).colorScheme.secondary)
                    ),
                  ),
                  Container(
                      height: 20,
                      width: screenWidth*0.09,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                  )
                ]
            )
        )
    );
  }

  Container settingsInfo(String value, String? secondValue, IconData icon) {
    return Container(
        height: 45,
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: 1,
                )
            )
        ),
        width: screenWidth*0.9,
        child: Row(
            children: <Widget> [
              SizedBox(width: screenWidth*0.01),
              Icon(
                icon,
              ),
              SizedBox(width: screenWidth*0.03),
              SizedBox(
                width: screenWidth*0.7,
                child: Text(
                    value, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, height: 1.5)
                ),
              ),
              Container(
                  height: 20,
                  width: screenWidth*0.09,
                  child: Text(
                      secondValue!,
                    style: TextStyle(
                      height: 1.8,
                    )
                  )
              )
            ]
        )
    );
  }

  SingleChildScrollView configureAlerts() {
    refreshAlerts();


    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 10
            ),
            Text(
              "Active Alerts",
              style: TextStyle(fontSize: 20,),
            ),
            !alerts.isEmpty ? SizedBox(
              width: screenWidth*0.93,
              height: 400,
              child: ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary,
                                    width: 1,
                                  )
                              )
                          ),
                          width: screenWidth*0.92,
                          child: Row(
                              children: <Widget> [
                                SizedBox(width: screenWidth*0.01),
                                const Icon(
                                  Icons.notifications_none_rounded,
                                ),
                                SizedBox(width: screenWidth*0.03),
                                SizedBox(
                                    width: screenWidth*0.65,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            alerts.keys.toList()[index], style: TextStyle( fontWeight: FontWeight.normal, fontSize: 16, height: 1.5)
                                        ),
                                        Text(
                                            alerts[alerts.keys.toList()[index]], style: TextStyle(color: alerts[alerts.keys.toList()[index]].contains("Bullish") ? cGreen : cRed, fontWeight: FontWeight.normal, fontSize: 16, height: 1.5)
                                        ),
                                      ],
                                    )
                                ),
                                Container(
                                    height: 20,
                                    width: 20,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.highlight_remove_rounded,
                                      ),
                                      onPressed: () async {
                                        final ref2 = FirebaseDatabase.instance.ref('alerts/predictions/${alerts.keys.toList()[index]}');
                                        ref2.update({"${FirebaseAuth.instance.currentUser?.uid}":null});

                                        alerts.remove(alerts.keys.toList()[index]);

                                        final ref = FirebaseDatabase.instance.ref('alerts/users/${FirebaseAuth.instance.currentUser?.uid}');
                                        ref.set(alerts);

                                        Navigator.pop(context);

                                        showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                )
                                            ),
                                            builder: (context) => configureAlerts()
                                        );

                                      },
                                    )
                                )
                              ]
                          )
                      )
                  );
                },
              ),
            ) : SizedBox(
              width: screenWidth*0.93,
              height: 400,
              child: Center(
                child: Column(
                  children: <Widget> [
                    Spacer(flex: 3),
                    Image.asset(
                      "images/Broken Bell.png",
                      width: 125,
                    ),
                    Spacer(),
                    Text("You do not have any active alerts."),
                    Spacer(flex: 5),
                  ],
                )
              )
            ),
          ],
        )
    );
  }
}
