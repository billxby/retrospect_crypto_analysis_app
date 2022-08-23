import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/Functions/premium.dart';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:crypto_app/main.dart';
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

Future<List<bool>> checkLogin(String username, String password) async {
  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/check_login?username=$username&password=$password'));
    print(response.body);

    Map<String, dynamic> works = jsonDecode(response.body);

    List<bool> back = [];

    back.add(works['username'] == "True");
    back.add(works['password'] == "True");
    back.add(works['verified'] == "True");

    return back;

  } catch (e){


    return <bool>[false, false];
  }
}

Future<bool> register(String username, String password) async {
  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/register?username=$username&password=$password'));
    print(response.body);

    Map<String, dynamic> works = jsonDecode(response.body);
    if (works['exist'] == "False") {
      return true;
    }

  } catch (e){
    return false;
  }

  return false;
}

Future<int> checkExpire(String username) async {
  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/get_expire?username=$username'));

    Map<String, dynamic> works = jsonDecode(response.body);

    premiumExpire = works['expire'];

    CustomerInfo purchaserInfo = await Purchases.getCustomerInfo();
    final entitlements = purchaserInfo.entitlements.active.values.toList();
    var isPro = purchaserInfo.entitlements.all['premium_membership']?.isActive;

    if (entitlements.length > 0) {
      DateTime dt1 = DateTime.tryParse(entitlements[0].toJson()['latestPurchaseDate']) ?? DateTime(2000,07,07);
      int newEpoch = dt1.millisecondsSinceEpoch;

      if (newEpoch  + (86400000*5) > premiumExpire) {
        String p = "Monthly";
        if (entitlements[0].toJson()['productIdentifier'] == "retrospect_premium_1y") {
          p = "Yearly";
        }
        updateExistingPremium(introdata.read("premiumUser"), p, newEpoch);
      }
    }

    return works['expire'];

  } catch (e){
    return 0;
  }
}

Future<bool> updatePremium(String username, String packageTitle) async {
  int days = 31;

  if (packageTitle.contains("Yearly")) days = 365;

  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/update_premium?username=$username&epoch=${DateTime.now().toUtc().millisecondsSinceEpoch}&days=$days'));
    print(response.body);

    Map<String, dynamic> works = jsonDecode(response.body);
    introdata.write("premiumUser",username);

    print("updated subscription");

    if (works['worked'] == "True") {
      return true;
    }

  } catch (e){
    return false;
  }

  return false;
}

Future<bool> updateExistingPremium(String username, String packageTitle, int epoch) async {
  int days = 31;

  if (packageTitle.contains("Yearly")) days = 365;

  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/update_premium?username=$username&epoch=$epoch&days=$days'));
    print(response.body);

    Map<String, dynamic> works = jsonDecode(response.body);
    introdata.write("premiumUser",username);

    print("updated subscription");

    if (works['worked'] == "True") {
      return true;
    }

  } catch (e){
    return false;
  }

  return false;
}

Future<bool> redeemPremium(String username, int days) async {
  if (userHasPremium()) {
    return false;
  }

  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/update_premium?username=$username&epoch=${DateTime.now().toUtc().millisecondsSinceEpoch}&days=$days'));
    print(response.body);

    Map<String, dynamic> works = jsonDecode(response.body);

    print("redeemed subscription");

    if (works['worked'] == "True") {
      return true;
    }
  } catch (e){
    return false;
  }

  return false;
}

Future<List<bool>> getReferer(String username, String target) async {
  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/update_ref?username=$username&target=$target'));
    print(response.body);

    Map<String, dynamic> works = jsonDecode(response.body);

    print(works);

    List<bool> back = [];

    back.add(works['verified'] == "True");
    back.add(works['refed'] == "False");
    back.add(works['exist'] == "True");

    print("here");

    return back;

  } catch (e){


    return <bool>[false, false, false];
  }
}

Future<int> checkPending(String username, String password) async {
  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/get_pending_credits?username=$username&password=$password'));

    Map<String, dynamic> works = jsonDecode(response.body);

    int cur = introdata.read("credits") + works['pending'];
    introdata.write("credits", cur);

    return works['pending'];

  } catch (e){
    return 0;
  }
}

Future<bool> forgotPassword(String username) async {
  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/forgot_password?username=$username'));
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

Future<bool> changePassword(String username, String password, String newP) async {
  try {
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/change_password?username=$username&password=$password&new=$newP'));
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

Future<bool> redeemPromocode(String code, String username) async {
  try {
    print(code);
    final response = await http.get(Uri.parse('https://us-central1-crypto-project-001.cloudfunctions.net/promocode?username=$username&promocode=$code'));
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