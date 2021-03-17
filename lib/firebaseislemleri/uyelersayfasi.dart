import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UyelerSayfasi extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UyelerState();
}

class UyelerState extends State<UyelerSayfasi> {
  @override
  Widget build(BuildContext context) {
    Firestore.instance
        .collection('uyeler')
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => debugPrint(doc['isim'])));
    return Container();
  }
}
