import 'package:flutter/material.dart';

import 'main.dart';
import 'UI/mainpages.dart';

class Utils {

  static Future showSheet(BuildContext context, WidgetBuilder builder) =>
      showModalBottomSheet(
        useRootNavigator: true,
        isDismissible: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        context: context,
        builder: builder,
      );
}