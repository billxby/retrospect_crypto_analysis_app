import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_app/UI/intropage.dart';
import 'package:crypto_app/UI/updatelog.dart';
import 'package:flutter/material.dart';
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

import '../UI/cryptosearchdelegate.dart';
import '../UI/detailspage.dart';
import 'cryptoinfoclass.dart';
import '../UI/information.dart';
import '../UI/updatelog.dart';
import '../main.dart';

Future<bool> fetchDatabase() async {
  print("Refreshing");
  for (int tries = 0; tries < maxFetchTries; tries++) {
    try {
      final response =
      await http.get(Uri.parse('http://3.142.236.93:5000/'));
      data = await jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception('Could not fetch data!');
      }
      if (data.contains('refreshing_data')) {
        throw Exception('Updating data');
      }

      worked = true;

      Sort["⬆A-Z"] = [];
      Sort["⬇A-Z"] = [];
      Sort["⬆Mrkt"] = [];
      Sort["⬇Mrkt"] = [];
      Sort["⬆24h"] = [];
      Sort["⬇24h"] = [];
      Sort["⬆Vol"] = [];
      Sort["⬇Vol"] = [];
      Sort["⬆Rscr"] = [];
      Sort["⬇Rscr"] = [];

      int count = 0;

      for (String idx in data) {
        final Res = CryptoInfo.fromJson(jsonDecode(idx));
        TopCryptos.add(await Res);
        count+=1;
      }

      for (int i=0;i<count;i++) {
        Sort["⬆A-Z"]?.add(i);
        Sort["⬇A-Z"]?.add(count-i-1);
      }

      // for (int i = 0; i < cryptosCap; i++) {
      //   late Future<CryptoInfo> Responses;
      //   Responses = getData(i);
      //   TopCryptos.add(await Responses);
      //   Sort["⬆A-Z"]?.add(i);
      //   Sort["⬇A-Z"]?.add(cryptosCap-i-1);
      // }

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
        print('Updating data');
        print('Trying again in 10 seconds');
        print(e);
        await Future.delayed(const Duration(seconds: 10), () {});
        continue;
      }
    }
  }

  if (worked == false) {
    return worked;
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

  copy.sort((a,b) => (int.tryParse(a.realVolume) ?? 0).compareTo(int.tryParse(b.realVolume) ?? 0));
  for (CryptoInfo crypto in copy) {
    Sort["⬆Vol"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (int.tryParse(b.realVolume) ?? 0).compareTo(int.tryParse(a.realVolume) ?? 0));
  for (CryptoInfo crypto in copy) {
    Sort["⬇Vol"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (double.tryParse(a.realScore) ?? 0).compareTo(double.tryParse(b.realScore) ?? 0));
  for (CryptoInfo crypto in copy) {
    Sort["⬆Rscr"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  copy.sort((a,b) => (double.tryParse(b.realScore) ?? 0).compareTo(double.tryParse(a.realScore) ?? 0));
  for (CryptoInfo crypto in copy) {
    Sort["⬇Rscr"]?.add(CryptosIndex[crypto.id] ?? 0);
  }

  return worked;
}

Future<CryptoInfo> getData(int index) async {
  final Res = CryptoInfo.fromJson(jsonDecode(data[index]));
  return await Res;
}