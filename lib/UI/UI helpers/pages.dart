import 'package:crypto_app/UI/UI%20helpers/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateApp extends StatelessWidget {
  const UpdateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 200,
        ),
        const Center(
            child: Text("A new version is available!", style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ))
        ),
        Center(
          child: OutlinedButton(
            onPressed: () async {
              launch("https://play.google.com/store/apps/details?id=com.cryptos.crypto_app");
            },
            child: const Text(
              "Update my App!",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Image.asset("images/Logo.png", height: 300),
      ],
    );
  }
}