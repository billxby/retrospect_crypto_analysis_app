import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../Functions/accounts.dart';
import '../Functions/cloudfunctionshelper.dart';
import '../Functions/premium.dart';
import '../Functions/purchase.dart';
import '../main.dart';
import '../utils.dart';
import 'UI helpers/paywallwidget.dart';
import 'UI helpers/style.dart';
import 'mainpages.dart';
import 'package:intl/intl.dart';

String currentCode = "none";

class GetPremiumPage extends StatefulWidget {
  const GetPremiumPage({super.key});

  @override
  State<GetPremiumPage> createState() => _GetPremiumPageState();
}

class _GetPremiumPageState extends State<GetPremiumPage> {
  late StreamSubscription iosSubscription;
  TextEditingController promoCode = TextEditingController();
  final localStorage = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Premium', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Container(
                  height: 850,
                  width: screenWidth * 0.93,
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(5),
                  child: Column(children: <Widget>[
                    SizedBox(
                      height: 32,
                      child: RichText(
                        text: const TextSpan(
                          text: "Get ",
                          style: TextStyle(
                              height: 2,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                          children: <TextSpan> [
                            TextSpan(
                              text: " Premium",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            TextSpan(
                                text: ".\n"
                            ),
                          ],
                        ),
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        text: "Get the ",
                        style: TextStyle(
                            height: 2,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                        children: <TextSpan> [
                          TextSpan(
                            text: " Ultimate ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                              text: " Experience."
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      "images/Premium Crown.gif",
                      width: screenWidth*0.5,
                    ),
                    Text("Compare Plans", style: TextStyle(fontSize: 22, height: 2, color: Colors.white)),
                    SizedBox(
                      height: screenHeight*0.52,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children: [
                              SizedBox(
                                width: screenWidth*0.1,
                              ),
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget> [
                                        Text("Premium ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                                        Image.network(
                                          "https://i.postimg.cc/N0vc0vzn/Premium-Crown-Crisp.png",
                                          width: 25,
                                        ),
                                      ]
                                    ),
                                    SizedBox(height: 20),
                                    SizedBox(
                                      width: screenWidth*0.55,
                                      child: Column(
                                        children: const <Widget> [
                                          Text("\u2022 Unlimited Cryptocurrencies Analysis each day\n", style: TextStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.left,),
                                          Text("\u2022 20 Alerts to Stay on Top of the Market\n", style: TextStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.left,),
                                          Text("\u2022 Keep Track of Cryptos Rating over 365 days\n", style: TextStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.left,),
                                          Text("\u2022 Exclusive Discord Roles & Trading Channels \n", style: TextStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.left,),
                                          Text("\u2022 Fast Support & Assistance", style: TextStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.left,),
                                        ]
                                      )
                                    ),
                                    SizedBox(height: 15),
                                    ElevatedButton(
                                      style: roundButton(userHasPremium() ? Colors.grey : Colors.white),
                                      onPressed: () {
                                        if (userHasPremium()) {
                                          return;
                                        }
                                        if (fetching == true) {}
                                        else {
                                          fetching = true;
                                          fetchOffers();
                                          fetching = false;
                                        }
                                      },
                                      child: Text(userHasPremium() ? 'Current Plan' : 'See Plans', style: TextStyle(color: Colors.black,)),
                                    ),
                                  ]
                                )
                              ),
                              SizedBox(
                                width: screenWidth*0.07,
                              ),
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget> [
                                            Text("Free", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                          ]
                                      ),
                                      SizedBox(height: 20),
                                      SizedBox(
                                          width: screenWidth*0.55,
                                          child: Column(
                                              children: const <Widget> [
                                                Text("\u2022 5 Cryptocurrencies Analysis each day\n", style: TextStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.left,),
                                                Text("\u2022 Keep Track of Cryptos Rating for 7 days\n", style: TextStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.left,),
                                                Text("\u2022 Discord Support & Assistance \n", style: TextStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.left,),
                                              ]
                                          )
                                      ),
                                      SizedBox(
                                        height: 90,
                                      ),
                                      ElevatedButton(
                                        style: roundButton(userHasPremium() ? Colors.white : Colors.grey),
                                        onPressed: () {},
                                        child: Text('Default Plan', style: TextStyle(color: Colors.black,)),
                                      ),
                                    ]
                                )
                              ),
                              SizedBox(
                                width: screenWidth*0.05,
                              ),
                            ]
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              backgroundColor: const Color(0xff1B1B1B),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  )
                              ),
                              builder: (context) => Container(
                                height: 600,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget> [
                                      SizedBox(height: 20),
                                      Text("Enter Promocode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                                      SizedBox(
                                        width: screenWidth*0.8,
                                        child: TextFormField(
                                          controller: promoCode,
                                          decoration: const InputDecoration(
                                            border: UnderlineInputBorder(),
                                            labelText: 'Enter Code',
                                            labelStyle: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          print(promoCode.text);

                                          bool worked = await redeemPromocode(promoCode.text);

                                          if (worked == true) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => refDialog(context, "Promo Code Valid", "You just applied a promocode for $offerMsg!")
                                              ),
                                            );
                                            currentCode = promoCode.text;
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
                                        style: roundButton(Colors.white),
                                        child: Text('Submit', style: TextStyle(color: Colors.black,)),
                                      ),
                                    ]
                                ),

                              ),
                          );
                        },
                        child: Text('Promo Code', style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                      ),
                    ),
                    const SizedBox(height: 20,),
                  ])),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
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
        title: 'Upgrade to Premium',
        description: 'Enjoy unlimited analysis, alerts, and rating history',
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
}