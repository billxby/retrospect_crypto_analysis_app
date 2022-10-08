import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/Functions/premium.dart';
import 'package:crypto_app/Functions/purchase.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:crypto_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../UI/get_premium.dart';
import '../UI/mainpages.dart';

Future<bool> checkPremium() async {
  CustomerInfo purchaserInfo = await Purchases.getCustomerInfo();
  final entitlements = purchaserInfo.entitlements.active.values.toList();
  var isPro = purchaserInfo.entitlements.all['premium_membership']?.isActive;

  if (entitlements.length > 0) {
    isPremium = true;
  }
  else {
    isPremium = false;
  }

  return true;
}

Future<bool> appVersion() async {
  try {
    String url = 'https://us-central1-crypto-project-001.cloudfunctions.net/current-version-ios';
    if (Platform.isAndroid) {
      url = 'https://us-central1-crypto-project-001.cloudfunctions.net/current-android-version';

    }
    final response = await http.get(Uri.parse(url));

    String works = response.body.toString();

    new_version = works;
    return true;
  } catch (e){
    return false;
  }
}

Future<bool> refferalProgram(String packageTitle) async {
  if (currentCode == "none") {
    return false;
  }

  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/referral-program?code=$currentCode&yearly=${packageTitle.contains("Yearly") ? 1 : 0}'));

    Map<String, dynamic> works = jsonDecode(response.body);

    if (works['worked'] == "True") {
      return true;
    }
  } catch (e){
    return false;
  }

  return false;
}

Future<int> checkPending(String username, String password) async {
  User? user = FirebaseAuth.instance.currentUser;

  final db = FirebaseFirestore.instance;
  await db.collection("users").doc(user?.uid).get().then((DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    credits = data['credits'];
    return data['credits'];
  },
    onError: (e) {
      print("error getting doc");
      return 0;
    },
  );

  return 0;
}

Future<bool> addReferrer(String referrer) async {
  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/claim-referral-rewards?uid=${FirebaseAuth.instance.currentUser?.uid}&referrer=$referrer'));
    print(response.body);

    Map<String, dynamic> works = jsonDecode(response.body);

    if (works['worked'] == "True") {
      return true;
    }

  } catch (e){
    return false;
  }

  return false;
}


Future<bool> redeemPromocode(String code) async {
  try {
    print(code);
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/promocode?promocode=$code'));
    print(response.body);

    Map<String, dynamic> works = jsonDecode(response.body);
    if (works['worked'] == "True") {
      currentPromo = works["package"];
      offerMsg = works["message"];
      return true;
    }
  } catch (e){
    currentPromo = "none";
    return false;
  }

  currentPromo = "none";
  return false;
}

Future<bool> redeemPremiumFunction(String duration) async {
  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/redeem-premium?uid=${FirebaseAuth.instance.currentUser?.uid}&duration=$duration'));
    print(response.body);

    if (response.body == "True") {
      return true;
    }

  } catch (e){
    return false;
  }

  return false;
}