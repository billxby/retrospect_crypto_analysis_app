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
            if (userLimitAvailable(Sort[sortBy]?[index] ?? 0)) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(
                      passedIndex: Sort[sortBy]?[index] ?? 0,
                    )),
              );
            }
            else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertDialog(
                    title: const Text('Limit Reached'),
                    content: const Text(
                        'You have reached your daily limit of cryptocurrency analysis ☹️You may use your credits or get premium to access more'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, '60 Credits');
                          if (redeemCreditsDetails(Sort[sortBy]?[index] ?? 0)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                    passedIndex: Sort[sortBy]?[index] ?? 0,
                                  )),
                            );
                          }
                          else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlertDialog(
                                  title: const Text('You don\'t have enough Credits'),
                                  content: const Text('You need at least 60 Credits to redeem that'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'OK'),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('60 Credits'),
                      ),
                    ],
                  ),
                ),
              );
            }
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