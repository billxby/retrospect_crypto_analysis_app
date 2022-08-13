import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/Functions/firestorehelper.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
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

import 'adhelper.dart';
import 'cryptosearchdelegate.dart';
import "detailspage.dart";
import '../Functions/cryptoinfoclass.dart';
import 'information.dart';
import 'updatelog.dart';
import '../Functions/database.dart';
import '../main.dart';
import 'UI helpers/textelements.dart';

const users = const {
  'xubill0707@gmail.com': '12345',
  'kevin': 'dad??',
};

class MainPages extends StatefulWidget {
  const MainPages({Key? key}) : super(key: key);

  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> {
  static final AdRequest request = AdRequest();

  Duration get loginTime => Duration(milliseconds: 2250);

  int maxFailedLoadAttempts = 3;
  int _selectedIndex = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final introdata = GetStorage();

  @override
  void initState() {
    super.initState();
    _createRewardedAd();
    _checkUsername();
  }

  Future<void> _checkUsername() async {
    bool docExist = await checkIfDocExists("xubill0707@gmail.com");
    print("checking if exists ${docExist}");
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

    if (_selectedIndex == 0) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('Top $cryptosCap Cryptos'),
            centerTitle: true,
            toolbarHeight: 40,
            leadingWidth: 80,
            leading: DropdownButton<String>(
              value: sortBy,
              isExpanded: true,
              icon: const Icon(Icons.sort),
              items: <String>[
                "⬆A-Z",
                '⬇A-Z',
                '⬆Mrkt',
                '⬇Mrkt',
                '⬆24h',
                '⬇24h',
                "⬆Rscr",
                '⬇Rscr',
                '⬆Vol',
                '⬇Vol'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  sortBy = newValue!;
                });
              },
              style: TextStyle(
                fontSize: 15,
                color: darkTheme ? Colors.white : Colors.black,
              ),
              borderRadius: BorderRadius.circular(10),
              itemHeight: 50,
              menuMaxHeight: 250,
            ),
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
          onRefresh: refreshPage,
          child: ListView.builder(
              itemCount: TopCryptos.length,
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
                    );
                  },
                  title: Container(
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: darkTheme ? Colors.white : Colors.black)),
                      color: Colors.transparent,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Image.network(
                                TopCryptos[Sort[sortBy]![index]].image,
                                height: 25,
                                width: 25,
                              ),
                              const SizedBox(
                                width: 15,
                                height: 10,
                              ),
                              Expanded(
                                child: Text(
                                  TopCryptos[Sort[sortBy]![index]].id,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                TopCryptos[Sort[sortBy]![index]].current_price,
                                style: const TextStyle(height: 2, fontSize: 15),
                              ),
                              listviewTextTitle(" 24h: "),
                              listviewTextInfo(
                                  "${TopCryptos[Sort[sortBy]![index]].price_change_precentage_24h}%",
                                  TopCryptos[Sort[sortBy]![index]]
                                          .price_change_precentage_24h
                                          .contains("-")
                                      ? Colors.red
                                      : Colors.green),
                              listviewTextTitle(" R "),
                              listviewTextInfo(
                                  TopCryptos[Sort[sortBy]![index]].realScore,
                                  TopCryptos[Sort[sortBy]![index]]
                                          .realScore
                                          .contains("-")
                                      ? Colors.red
                                      : Colors.green),
                              listviewTextTitle(" Mrkt Cap: "),
                              listviewTextInfo(
                                  TopCryptos[Sort[sortBy]![index]].market_cap,
                                  darkTheme ? Colors.white : Colors.black),
                              listviewTextTitle(" Vol "),
                              listviewTextInfo(
                                  TopCryptos[Sort[sortBy]![index]].total_volume,
                                  darkTheme ? Colors.white : Colors.black),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
        bottomNavigationBar: getBar(),
      );
    } else if (_selectedIndex == 1) {
      return earnPage();
    } else if (_selectedIndex == 2) {
      if (introdata.read("logged in") == false) {
        return FlutterLogin(
          title: 'Retrospect',
          logo: Image.network(
                  "https://i.postimg.cc/26yTSgvq/Retro-Spect-Trans.png")
              .image,
          onLogin: _authUser,
          onSignup: _signupUser,
          onSubmitAnimationCompleted: () {
            introdata.write("logged in", true);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MainPages(),
            ));
          },
          userValidator: null,
          onRecoverPassword: _recoverPassword,
          hideForgotPasswordButton: true,
          loginAfterSignUp: true,
        );
      } else {
        return premiumPage();
      }
    } else {
      return settingsPage();
    }
  }

  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      introdata.write("username", data.name);
      introdata.write("password", data.password);
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return 'Hi';
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
        introdata.write("credits", introdata.read("credits") + 20);
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
            Icons.list,
          ),
          label: 'List',
          backgroundColor: darkTheme ? Colors.black45 : Colors.grey[300],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.monetization_on),
          label: 'Earn',
          backgroundColor: darkTheme ? Colors.black45 : Colors.grey[300],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.stars),
          label: 'Premium',
          backgroundColor: darkTheme ? Colors.black45 : Colors.grey[300],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: 'Settings',
          backgroundColor: darkTheme ? Colors.black45 : Colors.grey[300],
        ),
      ],
      selectedItemColor: Colors.blue,
    );
  }

  Scaffold premiumPage() {
    final Stream<QuerySnapshot> users =
        FirebaseFirestore.instance.collection("cryptos").snapshots();

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
                  height: 300,
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: darkTheme ? Colors.white : Colors.black),
                    color: Colors.grey[900],
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Column(children: <Widget>[
                    Text(
                      " Hello ${introdata.read("username")} ",
                      style: hugeTitleStyle,
                    ),
                  ])),
            ),
            Container(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                  stream: users,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('somethign went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    final data = snapshot.requireData;
                    return ListView.builder(
                        itemCount: data.size,
                        itemBuilder: (context, index) {
                          return Text(
                              "User is ${data.docs[index]['uid']} has password ${data.docs[index]['password']}");
                        });
                  }),
            )
          ],
        ),
      ),
      bottomNavigationBar: getBar(),
    );
  }

  Scaffold earnPage() {
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
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: darkTheme ? Colors.white : Colors.black),
                    color: Colors.grey[900],
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
                                    'Credits can be used to access the analysis of more cryptocurrencies every day, or to get Premium for free!'),
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
                          _showRewardedAd();
                        },
                        child: const Text('    Get 20 Credits!    '),
                      ),
                    ),
                    Center(
                      child: OutlinedButton(
                        onPressed: () {},
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
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        color: darkTheme ? Colors.white : Colors.black),
                    color: Colors.grey[900],
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
                        onPressed: () {},
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
                        onPressed: () {},
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
                        onPressed: () {},
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
      )),
      bottomNavigationBar: getBar(),
    );
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
          SettingsSection(
            title: const Text('General'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                initialValue: darkTheme,
                leading: const Icon(Icons.format_paint),
                title: const Text('Enable dark theme'),
                onToggle: (value) {
                  setState(() {
                    darkTheme = value;
                    introdata.write("darkTheme", value);
                  });
                  if (darkTheme) {
                    Get.changeTheme(ThemeData.dark());
                  } else {
                    Get.changeTheme(ThemeData.light());
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Information'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  leading: Icon(Icons.rule_rounded),
                  title: Text('Metrics Meaning'),
                  value: Text('Learn more about the metrics!'),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Information()),
                    );
                  }),
              SettingsTile.navigation(
                  leading: Icon(Icons.book_outlined),
                  title: Text('App Intro'),
                  value: Text('Load the app intro again!'),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IntroPage()),
                    );
                  }),
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('App Version'),
                value: Text('1.0.7'),
              ),
              // SettingsTile.navigation(
              //     leading: Icon(Icons.edit_note),
              //     title: Text('Update Log'),
              //     value: Text('Latest App Updates!'),
              //     onPressed: (context) {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => UpdateLog()),
              //       );
              //     }),
            ],
          )
        ],
      ),
      bottomNavigationBar: getBar(),
    );
  }
}
