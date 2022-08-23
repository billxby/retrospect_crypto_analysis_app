import 'package:flutter/cupertino.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// class RevenueCatProvider extends ChangeNotifier {
//   RevenueCatProvider() {
//     init();
//   }
//
//   int coins = 0;
//
//   Entitlement _entitlement = Entitlement.free;
//   Entitlement get entitlement => _entitlement;
//
//   Future init() async {
//
//     Purchases.addCustomerInfoUpdateListener((purchaserInfo) async {
//       print("hi");
//
//
//       updatePurchaseStatus();
//     });
//
//   }
//
//   Future updatePurchaseStatus() async {
//     final purchaserInfo = await Purchases.getCustomerInfo();
//
//     final entitlements = purchaserInfo.entitlements.active.values.toList();
//
//     // if (entitlement.isEmpty)
//
//     _entitlement = entitlements.isEmpty ? Entitlement.free : Entitlement.premium_membership;
//
//     notifyListeners();
//   }
// }
//
// enum Entitlement { free, premium_membership }