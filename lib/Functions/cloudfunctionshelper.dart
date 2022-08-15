import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
    return works['expire'];

  } catch (e){
    return 0;
  }
}