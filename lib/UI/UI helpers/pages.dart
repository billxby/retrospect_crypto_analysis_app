
import 'dart:io';
import 'dart:async';
import 'package:crypto_app/UI/UI%20helpers/style.dart';
import 'package:crypto_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateApp extends StatefulWidget {
  const UpdateApp({super.key});

  @override
  State<UpdateApp> createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('A new version is available!'),
            shape: const RoundedRectangleBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(20.0))),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Please Update your app!'),
                ],
              ),
            ),
            actions: <Widget>[
              if (Platform.isAndroid)
                TextButton(
                child: const Text('Update!', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  launch("https://play.google.com/store/apps/details?id=com.retrospectapps.retrospect");
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 240,
        ),
        Image.asset("images/Loading.gif", height: 300),
      ],
    );
  }
}