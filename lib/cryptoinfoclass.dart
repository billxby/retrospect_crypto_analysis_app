import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';

import 'main.dart';

class CryptoInfo {
  final String market_cap_rank;
  final String ath;
  final String market_cap;
  final String low_24h;
  final String high_24h;
  final String current_price;
  final String total_volume;
  final String symbol;
  final String last_updated;
  final String id;
  final String image;
  final String total_supply;
  final String price_change_precentage_24h;
  final String prediction;
  final String marketView;
  final String tweets;
  final String commits;

  CryptoInfo({
    required this.market_cap_rank,
    required this.ath,
    required this.market_cap,
    required this.low_24h,
    required this.high_24h,
    required this.current_price,
    required this.total_volume,
    required this.symbol,
    required this.last_updated,
    required this.id,
    required this.image,
    required this.total_supply,
    required this.price_change_precentage_24h,
    required this.prediction,
    required this.marketView,
    required this.tweets,
    required this.commits,
  });

  factory CryptoInfo.fromJson(Map<String, dynamic> json) {
    String marketCap = Numeral(json['market_cap'].toInt()).format().toString();
    String volume = Numeral(json['total_volume'].toInt()).format().toString();
    String price = json['current_price'].toString();
    String twtyFHigh = json['high_24h'].toString();
    String twtyFLow = json['low_24h'].toString();
    String twentyFourHours = json['price_change_percentage_24h'].toString();
    String id = json['id'].toString();
    String prediction = json['prediction'].toString();

    if (marketCap.contains(".")) {
      marketCap = marketCap.substring(0, marketCap.indexOf(".")) +
          marketCap.substring(marketCap.length - 1, marketCap.length);
    }
    if (volume.contains(".")) {
      volume = volume.substring(0, volume.indexOf(".")) +
          volume.substring(volume.length - 1, volume.length);
    }

    if (price.length < 5) {
      price = price.substring(0, price.length);
    } else {
      price = price.substring(0, 5);
    }
    if (twtyFHigh.length < 5) {
      twtyFHigh = twtyFHigh.substring(0, twtyFHigh.length);
    } else {
      twtyFHigh = twtyFHigh.substring(0, 5);
    }
    if (twtyFLow.length < 5) {
      twtyFLow = twtyFLow.substring(0, twtyFLow.length);
    } else {
      twtyFLow = twtyFLow.substring(0, 5);
    }
    if (twentyFourHours.contains('.')) {
      twentyFourHours = twentyFourHours.substring(0, twentyFourHours.indexOf('.')+2);
    }

    final addCryptoIndex = <String, int>{id: globalIndex};
    globalIndex += 1;

    CryptosIndex.addEntries(addCryptoIndex.entries);
    CryptosList.add(id);

    return CryptoInfo(
      market_cap_rank: json['market_cap_rank'].toString(),
      ath: json['ath'].toString(),
      market_cap: marketCap,
      low_24h: twtyFLow,
      high_24h: twtyFHigh,
      current_price: price,
      total_volume: volume,
      symbol: json['symbol'].toString(),
      last_updated: json['last_updated'].toString(),
      id: id,
      image: json['image'].toString(),
      total_supply: json['total_supply'].toString(),
      price_change_precentage_24h: twentyFourHours,
      prediction: prediction,
      marketView: json['marketView'].toString(),
      tweets: json['tweets'].toString(),
      commits: json['commits'].toString(),
    );
  }
}
