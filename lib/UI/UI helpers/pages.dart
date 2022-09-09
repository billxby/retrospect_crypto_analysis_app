import 'package:crypto_app/UI/UI%20helpers/textelements.dart';
import 'package:flutter/cupertino.dart';

class UpdateApp extends StatelessWidget {
  const UpdateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 200,
        ),
        Center(
            child: Text("Please update your app!", style: titleStyle)
        ),
        Center(
          child: detailsPageTitle("A new version is available now!"),
        ),
        const SizedBox(
          height: 50,
        ),
        Image.network("https://i.postimg.cc/y6SZ9YMF/Retro-Spect-Trans-BW.png", height: 300),
      ],
    );
  }
}