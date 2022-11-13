import 'dart:io';
import 'package:crypto_app/Functions/premium.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../main.dart';
import 'cloudfunctionshelper.dart';


Future<void> initPlatformState() async {
  await Purchases.setDebugLogsEnabled(true);

  PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration("goog_DawDwtyoQrWvoQRlDlRVBWQvlhD");
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration("appl_pzRjjQWXGnjwWgIEvgOnXsYcvAF");
  } else {
    configuration = PurchasesConfiguration("amzn_inmrnQiAZoTVjDyHJEAxcIiHyPf");
  }

  await Purchases.configure(configuration);
}

Future<List<Offering>> fetchCurrentOffers() async {
  try {
    Offerings offerings = await Purchases.getOfferings();

    var current = offerings.current;

    if (currentPromo != "none") {
      current = offerings.getOffering(currentPromo);
    }

    return current == null ? [] : [current];
  } on PlatformException catch(e) {
    return [];
  }
}

Future<bool> purchasePackage(Package package) async {

  try {
    CustomerInfo purchaserInfo = await Purchases.purchasePackage(package);

    final entitlements = purchaserInfo.entitlements.active.values.toList();
    var isPro = purchaserInfo.entitlements.all["premium_membership"]?.isActive;

    print(entitlements);

    if (isPro == true) {
      refferalProgram(package.storeProduct.title);
    }

    return true;
  } catch (e) {
    return false;
  }
}