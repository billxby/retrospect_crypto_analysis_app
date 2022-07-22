import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/updatelog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';

import 'cryptosearchdelegate.dart';
import "detailspage.dart";
import 'cryptoinfoclass.dart';
import 'updatelog.dart';

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

int globalIndex = 0;
List<dynamic> data = [];

//Declare styles
const TextStyle cryptosListStyle =
    TextStyle(height: 1.8, fontSize: 15, fontWeight: FontWeight.bold);

//Settings variables
bool darkTheme = true;
String sortBy = "⬆A-Z";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();

  for (int tries = 0; tries < maxFetchTries; tries++) {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.24:5000/analyze'));
      data = await jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception('Could not fetch data!');
      }

      Sort["⬆A-Z"] = [];
      Sort["⬇A-Z"] = [];
      Sort["⬆Mrkt"] = [];
      Sort["⬇Mrkt"] = [];
      Sort["⬆24h"] = [];
      Sort["⬇24h"] = [];
      // Sort["⬆Vol"] = [];
      // Sort["⬇Vol"] = [];
      // Volume doesn't work lol

      for (int i = 0; i < cryptosCap; i++) {
        late Future<CryptoInfo> Responses;
        Responses = getData(i);
        TopCryptos.add(await Responses);
        Sort["⬆A-Z"]?.add(i);
        Sort["⬇A-Z"]?.add(cryptosCap-i-1);
      }

      break;
    } catch (e) {
      if (e is ClientException) {
        if (e.message == 'Connection closed while receiving data') {
          await Future.delayed(const Duration(seconds: 5), () {});
          print('Exception Connection closed while receiving data');
          print('Trying again in 5 seconds');
          continue;
        }
      } else {
        exit(0);
      }
    }
  }

  // Sort cryptos by marketCap and Change
  List<CryptoInfo> copy = List.from(TopCryptos);

  copy.sort((a,b) => int.parse(a.market_cap_rank).compareTo(int.parse(b.market_cap_rank)));
  for (CryptoInfo crypto in copy) {
    Sort["⬇Mrkt"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => int.parse(b.market_cap_rank).compareTo(int.parse(a.market_cap_rank)));
  for (CryptoInfo crypto in copy) {
    Sort["⬆Mrkt"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (double.tryParse(a.price_change_precentage_24h) ?? 0.0).compareTo(double.tryParse(b.price_change_precentage_24h) ?? 0.0));
  for (CryptoInfo crypto in copy) {
    Sort["⬇24h"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (double.tryParse(b.price_change_precentage_24h) ?? 0.0).compareTo(double.tryParse(a.price_change_precentage_24h) ?? 0.0));
  for (CryptoInfo crypto in copy) {
    Sort["⬆24h"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  // copy.sort((a,b) => (int.tryParse(a.total_volume.substring(0, a.total_volume.length-1)) ?? 0).compareTo(int.tryParse(b.total_volume.substring(0, b.total_volume.length-1)) ?? 0));
  // for (CryptoInfo crypto in copy) {
  //   Sort["⬆Vol"]?.add(CryptosIndex![crypto.id] ?? 0);
  // }
  //
  // copy.sort((a,b) => (int.tryParse(b.total_volume.substring(0, b.total_volume.length-1)) ?? 0).compareTo(int.tryParse(a.total_volume.substring(0, a.total_volume.length-1)) ?? 0));
  // for (CryptoInfo crypto in copy) {
  //   Sort["⬇Vol"]?.add(CryptosIndex![crypto.id] ?? 0);
  // }

  runApp(const MyApp());
}

Future<CryptoInfo> getData(int index) async {
  final Res = CryptoInfo.fromJson(jsonDecode(data[index]));
  return await Res;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.changeTheme(ThemeData.dark());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const MainPages(),
    );
  }
}

class MainPages extends StatefulWidget {
  const MainPages({Key? key}) : super(key: key);

  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    hideScreen();
  }

  ///hide your splash screen
  Future<void> hideScreen() async {
    Future.delayed(const Duration(milliseconds: 3600), () {
      FlutterSplashScreen.hide();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              items: <String>["⬆A-Z", '⬇A-Z', '⬆Mrkt', '⬇Mrkt', '⬆24h', '⬇24h'/*, '⬆Vol', '⬇Vol'*/]
                  .map<DropdownMenuItem<String>>((String value) {
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
              style: const TextStyle(
                fontSize: 15,
              ),
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
        body: ListView.builder(
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
                                    fontSize: 20, fontWeight: FontWeight.bold),
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
                            const SizedBox(
                              width: 3,
                              height: 1,
                            ),
                            const Text(
                              "24h: ",
                              style: cryptosListStyle,
                            ),
                            Text(
                              TopCryptos[Sort[sortBy]![index]].price_change_precentage_24h,
                              style: TextStyle(
                                  height: 2.2,
                                  fontSize: 14,
                                  color: TopCryptos[Sort[sortBy]![index]]
                                          .price_change_precentage_24h
                                          .contains("-")
                                      ? Colors.red
                                      : Colors.green),
                            ),
                            Text(
                              "%",
                              style: TextStyle(
                                  height: 2.2,
                                  fontSize: 12,
                                  color: TopCryptos[Sort[sortBy]![index]]
                                          .price_change_precentage_24h
                                          .contains("-")
                                      ? Colors.red
                                      : Colors.green),
                            ),
                            const SizedBox(
                              width: 3,
                              height: 1,
                            ),
                            const Text(
                              "Mrkt Cap: ",
                              style: cryptosListStyle,
                            ),
                            Text(
                              TopCryptos[Sort[sortBy]![index]].market_cap,
                              style: const TextStyle(
                                height: 2.2,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                              height: 1,
                            ),
                            const Text(
                              "Vol: ",
                              style: cryptosListStyle,
                            ),
                            Text(
                              TopCryptos[Sort[sortBy]![index]].market_cap,
                              style: const TextStyle(
                                height: 2.2,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    } else {
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
                  leading: Icon(Icons.language),
                  title: Text('App Version'),
                  value: Text('0.1.1'),
                ),
                SettingsTile.navigation(
                    leading: Icon(Icons.edit_note),
                    title: Text('Update Log'),
                    value: Text('Latest App Updates!'),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateLog()),
                      );
                    }),
              ],
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    }
  }
}
