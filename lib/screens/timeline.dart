import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/widgets/widgets.dart';

final _userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];

  @override
  void initState() {
//    getUsers();
//  getUserById();
//  createUser();
//  updateUser();
  deleteUser();
    super.initState();
  }

  getUsers() async {
    final QuerySnapshot snapshot = await _userRef.getDocuments();
    setState(() {
      this.users = snapshot.documents;
    });
  }

  getUserById() async {
    final String id = 'qfvcABJ3vmAXIbeWnFor';
    final DocumentSnapshot doc = await _userRef.document(id).get();
    print(doc.data);
    print(doc.documentID);
    print(doc.exists);
  }

  createUser() async {
    final date = FieldValue.serverTimestamp();
    _userRef.document('someUniqueString').setData({
      'username': 'futureStream',
      'age': 22,
      'first_name': 'MaryK',
      'middle_name': 'Musa',
      'last_name': 'Osa',
      'store_name': 'BellrCakes',
      'backdrop_url': 'someUrl',
      'image_url': 'someUrl',
      'date_created': date,
      'date_updated': date,
      'description': '',
      'post_count': 0,
    });
  }

  updateUser() async {
    final dateUpdated = FieldValue.serverTimestamp();
    final user = await _userRef.document('someUniqueString').get();
    if (user.exists) {
      final dateCreated = user.data['date_created'];
      user.data['date_updated'] = dateUpdated;
      user.data['username'] = 'futureStream2';
      user.reference.updateData(user.data);
    }
  }

  deleteUser() async {
    final user = await _userRef.document('someUniqueString').get();
    if (user.exists){
      user.reference.delete();
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userRef.snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return circularProgress();
          }
          final children = snapshot.data.documents.map((doc) => Text(doc['username']),).toList();
          return Container(child: ListView(
            children: children,
          ),);
        },
      ),
    );
  }
}
