import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cron/cron.dart';
import 'package:crypto_app/Functions/basicfunctions.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
import 'package:flutter_login/flutter_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils.dart';
import '../Functions/cloudfunctionshelper.dart';
import '../Functions/premium.dart';
import '../Functions/purchase.dart';
import 'UI helpers/paywallwidget.dart';
import 'UI helpers/themes.dart';
import 'adhelper.dart';
import 'cryptosearchdelegate.dart';
import "detailspage.dart";
import '../Functions/cryptoinfoclass.dart';
import 'information.dart';
import 'notifications.dart';
import 'updatelog.dart';
import '../Functions/database.dart';
import '../main.dart';
import 'UI helpers/textelements.dart';
import '../Functions/premium.dart';
import 'package:flutter/services.dart';

bool fetching = false;
List<String> sortOptions = <String>[
  'Starred',
  "⬆A-Z",
  '⬇A-Z',
  '⬆Mrkt',
  '⬇Mrkt',
  '⬆24h',
  '⬇24h',
  "⬆Rscr",
  '⬇Rscr',
  '⬆Vol',
  '⬇Vol',
];


class MainPages extends StatefulWidget {
  const MainPages({Key? key}) : super(key: key);

  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> with WidgetsBindingObserver {
  static final AdRequest request = AdRequest();
  late final FirebaseMessaging _messaging;
  late StreamSubscription iosSubscription;

  Duration get loginTime => Duration(milliseconds: 2250);

  int maxFailedLoadAttempts = 3;
  int _selectedIndex = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final introdata = GetStorage();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _createRewardedAd();
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

    bool worked = await fetchDatabase();

    if (worked) {
      setState(() {
        TopCryptos = TopCryptos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final introdata = GetStorage();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    useMobileLayout = MediaQuery.of(context).size.shortestSide < 600;


    if (_selectedIndex == 0) {
      return FutureBuilder(
          future: checkExpire(introdata.read("username")),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Market'),
                  centerTitle: true,
                  toolbarHeight: 30,
                ),
                body: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color> (Colors.blue),
                  ),
                ),
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
                  // leading: DropdownButton<String>(
                  //   value: sortBy,
                  //   isExpanded: true,
                  //   icon: const Icon(Icons.sort),
                  //   items: <String>[
                  //     'Starred',
                  //     "⬆A-Z",
                  //     '⬇A-Z',
                  //     '⬆Mrkt',
                  //     '⬇Mrkt',
                  //     '⬆24h',
                  //     '⬇24h',
                  //     "⬆Rscr",
                  //     '⬇Rscr',
                  //     '⬆Vol',
                  //     '⬇Vol',
                  //   ].map<DropdownMenuItem<String>>((String value) {
                  //     return DropdownMenuItem<String>(
                  //       value: value,
                  //       child: Text(value),
                  //     );
                  //   }).toList(),
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       sortBy = newValue!;
                  //     });
                  //   },
                  //   style: TextStyle(
                  //     fontSize: 15,
                  //     color: darkTheme ? Colors.white : Colors.black,
                  //   ),
                  //   borderRadius: BorderRadius.circular(10),
                  //   itemHeight: 50,
                  //   menuMaxHeight: 250,
                  // ),
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
                child: Column(
                  children: <Widget> [
                    SizedBox(
                      height: 45,
                      child: ListView.builder(
                        // This next line does the trick.
                        scrollDirection: Axis.horizontal,
                        itemCount: sortOptions.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: sortOptions[index] == "Starred" ? 95 : 85,
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
                                    backgroundColor: MaterialStateProperty.all(sortByIdx == index ? Colors.white : (darkTheme ? Colors.white10 : Colors.grey[200])),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                          )
                                      )
                                  ),
                                  child: Text(sortOptions[index], style: TextStyle(color: sortByIdx == index ? Colors.black : Colors.white)),
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
                            return ListTile(
                              tileColor: Colors.transparent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailsPage(
                                        passedIndex: Sort[sortBy]?[index] ?? 0,
                                      )),
                                ).then((_)=>setState((){}));
                              },
                              title: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: darkTheme ? Colors.white10 : Colors.grey[200],
                                ),
                                padding: const EdgeInsets.all(2),
                                child: Center(
                                  child: Row(
                                    children: <Widget> [
                                      SizedBox(
                                        width: screenWidth*0.02,
                                      ),
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
                                            width: useMobileLayout ? screenWidth*0.43 : screenWidth*0.47,
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
                                              listviewTextTitle("R "),
                                              listviewTextInfo(
                                                  TopCryptos[Sort[sortBy]![index]].realScore,
                                                  TopCryptos[Sort[sortBy]![index]]
                                                      .realScore
                                                      .contains("-")
                                                      ? cRed
                                                      : Color(0xff0DC9AB)),
                                              // listviewTextTitle(" Vol "),
                                              // listviewTextInfo(
                                              //     TopCryptos[Sort[sortBy]![index]].total_volume,
                                              //     darkTheme ? Colors.white : Colors.black),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: useMobileLayout ? screenWidth*0.29 : screenWidth*0.39,
                                        color: Colors.transparent,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              TopCryptos[Sort[sortBy]![index]].current_price,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.8,
                                              ),
                                              softWrap: false,
                                            ),
                                            Text(
                                              "${TopCryptos[Sort[sortBy]![index]].price_change_precentage_24h.contains("-") ? "" : "+"}${TopCryptos[Sort[sortBy]![index]].price_change_precentage_24h}%",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: TopCryptos[Sort[sortBy]![index]].price_change_precentage_24h.contains("-") ? cRed : cGreen,
                                              ),
                                              textAlign: TextAlign.right,
                                              softWrap: false,
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
                            );
                          }),
                    )
                  ],
                )
              ),
              bottomNavigationBar: getBar(),
            );
          }
      );
    }
    else if (_selectedIndex == 1) {
      if (introdata.read("logged in") == false) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Premium'),
            centerTitle: true,
            toolbarHeight: 40,
          ),
          body: Center(
            child: detailsPageTitle("Please log in to proceed"),
          ),
          bottomNavigationBar: getBar(),
        );
      } else {
        return premiumPage();
      }
    }
    else if (_selectedIndex == 2) {
      if (introdata.read("logged in") == false) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
            centerTitle: true,
            toolbarHeight: 40,
          ),
          body: FlutterLogin(
            title: 'Retrospect',
            theme: LoginTheme(
              // pageColorLight: Colors.white,
              primaryColor: Colors.black,
            ),

            logo: Image.network(
                "https://i.postimg.cc/26yTSgvq/Retro-Spect-Trans.png")
                .image,
            onLogin: _authUser,
            onSignup: _signupUser,
            onSubmitAnimationCompleted: () {
              introdata.write("logged in", true);
              setState(() {});
              // Navigator.of(context).pushReplacement(MaterialPageRoute(
              //   builder: (context) => MainPages(),
              // ));
            },
            userValidator: null,
            onRecoverPassword: _recoverPassword,
            hideForgotPasswordButton: false,
            loginAfterSignUp: false,

            messages: LoginMessages(
              recoverPasswordIntro: "Get your password here",
              recoverPasswordDescription: "We will send you your password to this email account.",
            ),
          ),
          bottomNavigationBar: getBar(),
        );
      } else {
        return FutureBuilder(
            future: checkExpire(introdata.read("username")),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Premium'),
                    centerTitle: true,
                    toolbarHeight: 35,
                  ),
                  body: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color> (Colors.blue),
                    ),
                  ),
                  bottomNavigationBar: getBar(),
                );
              }
              return accountPage();
            }
        );
      }
    } else {
      return settingsPage();
    }
  }

  Future<String?> _authUser(LoginData data) async {
    debugPrint('Name: ${data.name}, Password: ${data.password}');

    List<bool> back = await checkLogin(data.name.toString(), data.password.toString());

    return Future.delayed(loginTime).then((_) {
      if (back[0] == false) {
        return 'User not exists';
      }
      if (back[1] == false) {
        return 'Password does not match';
      }
      if (back[2] == false) {
        return 'Please verify your email';
      }
      introdata.write("username", data.name);
      introdata.write("password", data.password);
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) async {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');

    bool worked = await register(data.name.toString(), data.password.toString());

    return Future.delayed(loginTime).then((_) {
      if (worked) {
        return null;
      }
      else {
        return "Something went wrong with registering, please try again later";
      }
    });
  }

  Future<String?> _recoverPassword(String name) async {
    debugPrint('Name: $name');

    bool worked = await forgotPassword(name);

    return Future.delayed(loginTime).then((_) {
      if (worked) {
        return null;
      }
      return "Failed to send";
    });
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      setState(() {
        introdata.write("credits", introdata.read("credits") + 30);
      });
    });
    _rewardedAd = null;
  }

  BottomNavigationBar getBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.show_chart,
          ),
          label: 'Market',
          backgroundColor: darkTheme ? Colors.black45 : Colors.grey[300],
        ),
        // BottomNavigationBarItem(
        //   icon: const Icon(Icons.monetization_on),
        //   label: 'Earn',
        //   backgroundColor: darkTheme ? Colors.black45 : Colors.grey[300],
        // ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.star),
          label: 'Premium',
          backgroundColor: darkTheme ? Colors.black45 : Colors.grey[300],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_circle_outlined),
          label: 'Account',
          backgroundColor: darkTheme ? Colors.black45 : Colors.grey[300],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_sharp),
          label: 'Settings',
          backgroundColor: darkTheme ? Colors.black45 : Colors.grey[300],
        ),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.white,
    );
  }

  Scaffold premiumPage() {
    TextEditingController promoCode = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 80,
            ),
            Center(
              child: Container(
                  height: userHasPremium() ? 780 : 900,
                  width: screenWidth * 0.93,
                  color: Colors.transparent,
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(5.0),
                  //   border: Border.all(
                  //       color: darkTheme ? Colors.white : Colors.black),
                  //   color: darkTheme ? Colors.grey[900] : Colors.white,
                  // ),
                  padding: const EdgeInsets.all(5),
                  child: Column(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget> [
                        RichText(
                          text: TextSpan(
                            text: " Hi, ",
                            style: TextStyle(
                              height: 2,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                                color: darkTheme ? Colors.white : Colors.black
                            ),
                            children: <TextSpan> [
                              TextSpan(
                                text: " ${introdata.read("username")} !",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: userHasPremium() ? Colors.blue : (darkTheme ? Colors.white : Colors.black),
                                ),
                              )
                            ],
                          ),
                        ),
                      ]
                    ),
                    if (userHasPremium())
                      Column(
                        children: <Widget> [
                          Image.network(
                            "https://i.postimg.cc/N0vc0vzn/Premium-Crown-Crisp.png",
                            width: 200,
                          ),
                          detailsPageTitle("You are a PREMIUM user :)"),
                          const Text("You have unlimited access to all analysis"),
                          Text("\nYour membership expires on ${DateFormat('MM-dd-yy').format(DateTime.fromMillisecondsSinceEpoch(premiumExpire))}",
                            style: TextStyle(fontSize: 10,)
                          ),
                        ]
                      ),
                    if (!userHasPremium())
                      Column(
                          children: <Widget> [
                            Image.network(
                              "https://i.postimg.cc/8CS2SBFQ/Premium-Crown-Crisp-Broken.png",
                              width: 200,
                            ),
                            detailsPageTitle("You do not have Premium"),
                            const Text("Get premium for Unlimited access to the app, helping you make better trades! \n",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: OutlinedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                // side: BorderSide(width: 5.0, color: Colors.blue),
                              ),
                              onPressed: () {
                                if (fetching == true) {}
                                else {
                                  fetching = true;
                                  fetchOffers();
                                  fetching = false;
                                }
                              },
                              child: const Text('See Plans', style: TextStyle(color: Colors.white,)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: OutlinedButton(
                                onPressed: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
                                    title: const Text('Promo Codes', textAlign: TextAlign.center),
                                    content: Container(
                                      height: 121,
                                      child: Column(
                                          children: <Widget> [
                                            TextFormField(
                                              controller: promoCode,
                                              decoration: const InputDecoration(
                                                border: UnderlineInputBorder(),
                                                labelText: 'Enter Code',
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text('Get exclusive Offers by following us on Twitter! \n\n',
                                                style: TextStyle(fontSize: 12,)
                                            ),
                                          ]
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          print(promoCode.text);

                                          bool worked = await redeemPromocode(promoCode.text, introdata.read("username"));

                                          if (worked == true) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => refDialog(context, "Promo Code Valid", "You just applied a promocode for $offerMsg!")
                                              ),
                                            );
                                          }
                                          else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => refDialog(context, "Promo Code Invalid", "Your promo code is invalid.")
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                ),
                                // onPressed:() {},
                                child: const Text('Promo Code'),
                              ),
                            ),
                          ]
                      ),
                    const SizedBox(height: 20,),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: Table(
                        border: TableBorder.all(color: darkTheme? Colors.white : Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(12))
                        ),
                        columnWidths: const {
                          0: FractionColumnWidth(0.36), // 1. Column
                          1: FractionColumnWidth(0.32), // 2. Column
                          2: FractionColumnWidth(0.32), // 3. Column
                        },
                        children: <TableRow>[
                          TableRow(
                            children: <Widget>[
                              Container(
                                decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                    )
                                ),
                                child: Text("Feature", style:tableStyleHeader(isHeader: true), textAlign: TextAlign.center),
                              ),
                              Container(
                                color: Colors.lightBlueAccent,
                                child:Text("Free", style:tableStyleHeader(isHeader: true), textAlign: TextAlign.center),
                              ),
                              Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.lightBlueAccent,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10.0),
                                      )
                                  ),
                                child: Image.network(
                                  "https://i.postimg.cc/N0vc0vzn/Premium-Crown-Crisp.png",
                                  height: 36,
                                ),
                              ),
                            ]
                          ),
                          compareRow("Analysis","5","∞"),
                          compareRow("Alerts","0","20"),
                          compareRow("History*","7d","365d"),
                          TableRow(
                              children: <Widget>[
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10.0),
                                      )
                                  ),
                                  child: Text("Your Plan", style:tableStyleBelow(isHeader: true), textAlign: TextAlign.center),
                                ),
                                Icon(userHasPremium() ? null : Icons.check_circle_outline),
                                Icon(userHasPremium() ? Icons.check_circle_outline : null, color: Colors.blue),
                              ]
                          )
                        ],
                      ),
                    ),
                    Text("*Released VERY soon! ⚠️"),
                    SizedBox(height: 50),
                    Text("NOTE:", style: TextStyle(color: cRed, fontSize: 15)),
                    Text("Premium is not associated with your Retrospect Account, but with your ${Platform.isAndroid ? 'Google Play' : 'Apple ID'} account. Thus, Premium is local. Your Retrospect log-in is for future updates!",
                    textAlign: TextAlign.center,),
                    // if (userHasPremium())
                    //   const SizedBox(
                    //     height: 40,
                    //   ),
                  ])),
            ),
            Center(
              child: Container(
                  height: 100,
                  width: screenWidth * 0.93,
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          TextButton(
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Credits'),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                                backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
                                content: const Text(
                                  'Credits can be used to access the analysis of more cryptocurrencies every day, or to get Premium for free! \n \nNOTE: Credits are local, so they are not saved onto your account.',
                                  textAlign: TextAlign.justify,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            ),
                            child: Text(
                              "Credits:",
                              style: hugeTitleStyle,
                            ),
                          ),
                          Text(
                            "${introdata.read("credits")} ",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Icon(
                            Icons.donut_large,
                            size: 28,
                            color: Colors.blue,
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          SizedBox(
                            height: 30,
                            child: OutlinedButton(
                              onPressed: () async {
                                // _createRewardedAd();
                                _showRewardedAd();
                              },
                              style: OutlinedButton.styleFrom(
                                primary: Colors.black,
                                onSurface: Colors.white,
                                backgroundColor: Colors.white,
                              ),
                              child: Row(
                                children: const <Widget> [
                                  Text('Get 30 ', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,)),
                                  Icon(
                                    Icons.donut_large,
                                    size: 22,
                                    color: Colors.black,
                                  ),
                                ]
                              )
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(
                        height: 23,
                      ),
                    ],
                  ),
                ),
              ),
            Center(
              child: Container(
                  height: 321,
                  width: screenWidth * 0.93,
                  child: Column(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget> [
                        Text(
                          "Redeem",
                          style: hugeTitleStyle,
                        ),
                        SizedBox(
                          width:20,
                          child:IconButton(
                            onPressed: () async {
                              await checkPending(introdata.read("username"), introdata.read("password"));
                              setState(() {});
                            },
                            // splashRadius: 0.1,
                            icon: Icon(Icons.refresh, size: 20,),
                          ),
                        ),
                      ]
                    ),
                    title("\n  1 week Premium: "),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => redeemPremiumDialog(context, 7, 1000),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            buttonBlueText("1000 "),
                            creditImage,
                          ],
                        ),
                      ),
                    ),
                    title("  2 weeks Premium: "),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => redeemPremiumDialog(context, 14, 1500),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            buttonBlueText("1500 "),
                            creditImage,
                          ],
                        ),
                      ),
                    ),
                    title("  3 weeks Premium: "),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => redeemPremiumDialog(context, 21, 1800),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            buttonBlueText("1800 "),
                            creditImage,
                          ],
                        ),
                      ),
                    ),
                  ])),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      bottomNavigationBar: getBar(),
    );
  }

  Scaffold accountPage() {
    TextEditingController curPassw = TextEditingController();
    TextEditingController newPassw1 = TextEditingController();
    TextEditingController newPassw2 = TextEditingController();
    TextEditingController referrer = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 80,
            ),
            Center(
              child: Container(
                  height: 50,
                  width: screenWidth * 0.93,
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(5),
                  child: Column(children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget> [
                          RichText(
                            text: TextSpan(
                              text: " Hello, ",
                              style: TextStyle(
                                  height: 2,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: darkTheme ? Colors.white : Colors.black
                              ),
                              children: <TextSpan> [
                                TextSpan(
                                  text: " ${introdata.read("username")} !",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: userHasPremium() ? Colors.blue : (darkTheme ? Colors.white : Colors.black),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ]
                    ),
                    // if (userHasPremium())
                    //   const SizedBox(
                    //     height: 40,
                    //   ),
                  ])),
            ),
            const SizedBox(height:50),
            Center(
              child: Container(
                  height: 150,
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: darkTheme ? Colors.white : Colors.black),
                    color: Colors.transparent,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Column(children: <Widget>[
                    Text(
                      "Referral",
                      style: hugeTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 23,
                    ),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: darkTheme ? const Color(0xff1B1B1B) : Colors.grey[200],
                            title: const Text('Referrals', textAlign: TextAlign.center),
                            content: Container(
                              height: 183,
                              child: Column(
                                  children: <Widget> [
                                    TextFormField(
                                      controller: referrer,
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'Enter your Referrer\'s email',
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text('You will get 100 C if you complete this! \n\n',
                                        style: TextStyle(fontSize: 12,)
                                    ),
                                    const Text('Refer people, ask them to write your email here, and you and your friends will both earn rewards! (You get 200 C/person)',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ]
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  print(referrer.text);

                                  List<bool> worked = await getReferer(introdata.read("username"), referrer.text);

                                  print(worked);

                                  if (worked[1] == false) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => refDialog(context, "Verify Email", "You have not verified your email yet. Please verify it to continue.")
                                      ),
                                    );
                                  } else if (worked[2] == false) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => refDialog(context, "Referred", "You have already done that prompt.")
                                      ),
                                    );
                                  } else if (worked[0] == false) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => refDialog(context, "User doesn't exist", "The user does not exist. ")
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
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                        // onPressed:() {},
                        child: Text('Referral (200 C)', style: TextStyle(color: darkTheme ? Colors.blueAccent : Colors.black)),
                      ),
                    ),
                  ])),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Container(
                height: 360,
                width: screenWidth * 0.93,
                color: Colors.transparent,
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: <Widget> [
                    Text("Change Password", style: hugeTitleStyle),
                    const SizedBox(height: 20),
                    changePasswordField(curPassw, 'Current Password'),
                    changePasswordField(newPassw1, 'New Password'),
                    changePasswordField(newPassw2, 'Confirm Password'),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      onPressed: () async {
                        if (newPassw1.text == newPassw2.text) {
                          worked = await changePassword(introdata.read("username"), curPassw.text, newPassw1.text);
                          if (worked == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => refDialog(context, "Changed Password", "Your password was changed!")
                              ),
                            );
                            introdata.write("password", newPassw1.text);
                          }
                          if (worked == false) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => refDialog(context, "Change Password Failed", "Your current password is incorrect, or something else went wrong.")
                              ),
                            );
                          }
                        }
                        else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => refDialog(context, "Password don\'t match", "Your new passwords do not match.")
                            ),
                          );
                        }
                      },
                      child: Text('Change Password',  style: TextStyle(color: darkTheme ? Colors.white : Colors.black)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height:30),

            OutlinedButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 15),
              ),
              onPressed: () {
                introdata.write("username", "");
                introdata.write("password", "");
                introdata.write("logged in", false);

                setState(() {});
              },
              child: Text('Log Out', style: TextStyle(color: darkTheme ? Colors.white : Colors.black)),
            ),

            const SizedBox(height:150),
          ],
        ),
      ),
      bottomNavigationBar: getBar(),
    );
  }

  Future fetchOffers() async {
    final offerings = await fetchCurrentOffers();

    if (offerings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No Plans Found'),
      ));
    }
    else {
      final packages = offerings.map((offer) => offer.availablePackages).expand((pair) => pair).toList();

      Utils.showSheet(context, (context) => PaywallWidget(
        packages: packages,
        title: '⭐ Upgrade to Premium',
        description: 'Upgrade to premium to enjoy unlimited access and browsing without ads.',
        onClickedPackage: (package) async {
          bool worked = await purchasePackage(package);

          if (worked) {
            setState(() {});
          }

          Navigator.pop(context);
        },
      ));
    }
  }

  Scaffold earnPage() {
    TextEditingController referrer = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earn'),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
          child: Container(
        height: 900,
        // color: Colors.blueGrey[700],
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 80,
            ),
            Center(
              child: Container(
                  height: 300,
                  width: screenWidth * 0.93,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: darkTheme ? Colors.white : Colors.black),
                    color: darkTheme ? Colors.grey[900] : Colors.white,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Column(children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          " YOUR CREDITS",
                          style: hugeTitleStyle,
                        ),
                        Container(
                          child: IconButton(
                            icon: const Icon(Icons.info_outline_rounded),
                            iconSize: 20,
                            splashRadius: 5,
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Credits'),
                                content: const Text(
                                    'Credits can be used to access the analysis of more cryptocurrencies every day, or to get Premium for free! \n \nNOTE: Credits are local, so they are not saved onto your account.',
                                    textAlign: TextAlign.justify,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 23,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "${introdata.read("credits")} ",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Image.network(
                          "https://i.postimg.cc/D0PrC6Fz/Credits.png",
                          height: 36,
                          width: 36,
                        ),
                      ],
                    ),
                    title(" \n  Get Credits: "),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          // _showRewardedAd();
                        },
                        child: const Text('    Get 20 Credits!    \n   (not working atm)   '),
                      ),
                    ),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Referrals'),
                            content: Container(
                              height: 160,
                              child: Column(
                                  children: <Widget> [
                                    TextFormField(
                                      controller: referrer,
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'Enter your Referrer\'s email',
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text('(You will also get 100 Credits) \n\n',
                                        style: TextStyle(fontSize: 12,)
                                    ),
                                    const Text('Refer people, ask them to write your email here to earn 200 CR/person referred!',
                                        style: TextStyle(fontSize: 14),
                                    ),
                                  ]
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  print(referrer.text);

                                  List<bool> worked = await getReferer(introdata.read("username"), referrer.text);

                                  print(worked);

                                  if (worked[1] == false) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => refDialog(context, "Verify Email", "You have not verified your email yet. Please verify it to continue.")
                                      ),
                                    );
                                  } else if (worked[2] == false) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => refDialog(context, "Referred", "You have already done that prompt.")
                                      ),
                                    );
                                  } else if (worked[0] == false) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => refDialog(context, "User doesn't exist", "The user does not exist. ")
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => refDialog(context, "Successful", "You have completed the prompt. \n Refresh your credits (scroll down) :)")
                                      ),
                                    );
                                  }

                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                        // onPressed:() {},
                        child: const Text('200 Credits Referral'),
                      ),
                    ),
                  ])),
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: Container(
                  height: 400,
                  width: screenWidth * 0.93,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: darkTheme ? Colors.white : Colors.black),
                    color: darkTheme ? Colors.grey[900] : Colors.white,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Column(children: <Widget>[
                    Text(
                      "REDEEM",
                      style: hugeTitleStyle,
                    ),
                    title("\n  1 week Premium: "),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => redeemPremiumDialog(context, 7, 1000).then((_)=>getPending()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            buttonBlueText("1000 "),
                            creditImage,
                          ],
                        ),
                      ),
                    ),
                    title("  2 weeks Premium: "),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => redeemPremiumDialog(context, 14, 1500).then((_)=>getPending()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            buttonBlueText("1500 "),
                            creditImage,
                          ],
                        ),
                      ),
                    ),
                    title("  3 weeks Premium: "),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => redeemPremiumDialog(context, 21, 1800).then((_)=>getPending()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            buttonBlueText("1800 "),
                            creditImage,
                          ],
                        ),
                      ),
                    ),
                  ])),
            ),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              onPressed: () async {
                getPending();
              },
              child: const Text("Refresh Credits \n (if someone use your referral)",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      )),
      bottomNavigationBar: getBar(),
    );
  }

  void getPending() async {
    await checkPending(introdata.read("username"), introdata.read("password"));
    setState(() {});
  }

  Scaffold settingsPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: SettingsList(
        sections: [
          // SettingsSection(
          //   title: const Text('General'),
          //   tiles: <SettingsTile>[
          //     SettingsTile.switchTile(
          //       initialValue: darkTheme,
          //       leading: const Icon(Icons.format_paint),
          //       title: const Text('Enable dark theme'),
          //       onToggle: (value) {
          //         setState(() {
          //           darkTheme = value;
          //           introdata.write("darkTheme", value);
          //         });
          //         if (darkTheme) {
          //           Get.changeTheme(customDark);
          //         } else {
          //           Get.changeTheme(customWhite);
          //         }
          //       },
          //     ),
          //   ],
          // ),
          SettingsSection(
            title: const Text('Information'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  leading: Icon(Icons.book_outlined),
                  title: Text('App Intro'),
                  value: Text(Platform.isAndroid ? 'Load the app intro again!' : ""),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IntroPage()),
                    );
                  }),
              SettingsTile.navigation(
                  leading: Icon(Icons.notifications_off_outlined),
                  title: Text('Clear Alerts'),
                  value: Text(Platform.isAndroid ? 'Delete all active alerts' : ""),
                  onPressed: (context) {
                    introdata.write("alerts", <String, String> {});
                    Workmanager().cancelAll();
                  }),
              SettingsTile.navigation(
                  leading: Icon(Icons.question_answer_sharp),
                  title: Text('Support'),
                  value: Text(Platform.isAndroid ? 'Join our discord server!' : ""),
                  onPressed: (context) => launch('https://discord.io/retrospect')),
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('App Version'),
                value: Text(app_version),
              ),

            ],
          )
        ],
      ),
      bottomNavigationBar: getBar(),
    );
  }

}
