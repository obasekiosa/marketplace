import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/screens/screens.dart';

void main() {
//  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
//    print("Timestamps enabled in snapshots\n");
//  }, onError: (_) {
//    print("Error enabling Timestamps in snapshots\n");
//  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarketPlace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.teal,
      ),
      home: Home(),
    );
  }
}
