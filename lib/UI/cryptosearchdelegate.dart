import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numeral/numeral.dart';
import 'package:flutter/cupertino.dart';

import '../Functions/premium.dart';
import '../main.dart';
import 'detailspage.dart';

class CryptosSearchDelegate extends SearchDelegate<String> {
  final List<String> cryptos;
  String result = '';

  CryptosSearchDelegate(this.cryptos);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, result);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestions = cryptos.where((crypto) {
      return crypto.toLowerCase().contains(query.toLowerCase());
    });

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            suggestions.elementAt(index),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailsPage(
                    passedIndex: Sort[sortBy]?[index] ?? 0,
                  )),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = cryptos.where((crypto) {
      return crypto.toLowerCase().contains(query.toLowerCase());
    });

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            suggestions.elementAt(index),
          ),
          onTap: () {
            if (query != suggestions.elementAt(index)) {query = suggestions.elementAt(index);}
            else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(
                      passedIndex: CryptosIndex[suggestions.elementAt(index).toString()] ?? 0,
                    )),
              );
            }
          },
        );
      },
    );
  }
}

class CryptosSearchDelegateStars extends SearchDelegate<String> {
  final List<String> cryptos;
  String result = '';
  List<String> stars = [];

  CryptosSearchDelegateStars(this.cryptos);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, result);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestions = cryptos.where((crypto) {
      return crypto.toLowerCase().contains(query.toLowerCase());
    });

    return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              suggestions.elementAt(index),
            ),
            trailing: Icon(
              stars.contains(suggestions.elementAt(index)) ? Icons.star : Icons.star_border_outlined,
            ),
            onTap: () {
              stars = localStorage.read("starred_coins")?.cast<String>() ?? [];
              if (stars.contains(suggestions.elementAt(index))) {
                stars.remove(suggestions.elementAt(index));
                Sort["Starred"]?.remove(CryptosIndex[suggestions.elementAt(index)]);
              }
              else {
                stars.add(suggestions.elementAt(index));
                Sort["Starred"]?.add(CryptosIndex[suggestions.elementAt(index)] ?? 0);
              }
              localStorage.write("starred_coins", stars);
              setState(() {});
            },
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = cryptos.where((crypto) {
      return crypto.toLowerCase().contains(query.toLowerCase());
    });

    return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              suggestions.elementAt(index),
            ),
            trailing: Icon(
              stars.contains(suggestions.elementAt(index)) ? Icons.star : Icons.star_border_outlined,
            ),
            onTap: () {
              stars = localStorage.read("starred_coins")?.cast<String>() ?? [];
              if (stars.contains(suggestions.elementAt(index))) {
                stars.remove(suggestions.elementAt(index));
                Sort["Starred"]?.remove(CryptosIndex[suggestions.elementAt(index)]);
              }
              else {
                stars.add(suggestions.elementAt(index));
                Sort["Starred"]?.add(CryptosIndex[suggestions.elementAt(index)] ?? 0);
              }
              localStorage.write("starred_coins", stars);
              setState(() {});
            },
          );
        },
      );
    });
  }
}