import 'dart:core';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

import 'package:burkem_app/yanmenu/yanmenu.dart';
import 'curd.dart';

class KaporaSayfasi extends StatefulWidget {
  KaporaSayfasi({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() => _KaporaSayfasistate();
}

class _KaporaSayfasistate extends State<KaporaSayfasi> {
  bool duzenleMi = false;
  String isim;
  String erkek;
  String disi;
  String satisfiyat;
  String documentid;
  String id;

  QuerySnapshot kopeks;
  QuerySnapshot kopeks2;

  final formKontrolcu = GlobalKey<FormState>();
  crudMedthods crudObj = new crudMedthods();

  @override
  void initState() {
    crudObj.getKapora().then((results) {
      setState(() {
        kopeks = results;
      });
    });
    crudObj.getData().then((results2) {
      setState(() {
        kopeks2 = results2;
      });
    });
    super.initState();
  }

  Future<bool> dialogTrigger(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Başarılı", style: TextStyle(fontSize: 15.0)),
            content: Text("Silindi"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Tamam"),
                textColor: Colors.blue,
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffd4dff8),
        appBar: AppBar(
          backgroundColor: Color(0xFF75A2EA),
          title: new Text("Kapora Listesi"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                crudObj.getKapora().then((results) {
                  setState(() {
                    kopeks = results;
                  });
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: new BottomNavigationBar(
            elevation: 0.0,
            backgroundColor: Color(0xFF75A2EA),
            items: [
              new BottomNavigationBarItem(
                icon: new Icon(Icons.view_list),
                title: new Text("Köpek Listesi"),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.attach_money),
                title: new Text("Satış Listesi"),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.access_time),
                title: new Text("Kapora Listesi"),
              ),
            ],
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            onTap: (int i) {
              switch (i) {
                case 0:
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/KopekListesi');
                  return;
                case 1:
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/SatisSayfasi');

                  return;
                case 2:
                  return;
              }
            }),
        body: Stack(
          children: <Widget>[
             WillPopScope(
              child: Container(),
              onWillPop: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/KopekListesi');
              }),
            _kopekList(),
            CollapsingNavigationDrawer(),
          ],
        ));
  }

  Widget _kopekList() {
    if (kopeks != null) {
      return ListView.builder(
        itemCount: kopeks.documents.length,
        padding: EdgeInsets.fromLTRB(62.0, 8, 8, 8),
        itemBuilder: (context, i) {
          return Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                      "Köpek Cinsi =  " + kopeks.documents[i].data["isim"]),
                  subtitle: Text("Erkek Adeti = " +
                      kopeks.documents[i].data["erkek"].toString() +
                      "\nDişi Adeti = " +
                      kopeks.documents[i].data["disi"].toString() +
                      "\nKapora Fiyatı = " +
                      kopeks.documents[i].data["minfiyat"].toString() +
                      "\nKapora Alan Kişi = " +
                      kopeks.documents[i].data["kisi"]),
                  isThreeLine: true,
                ),
                FlatButton(
                  onPressed: () {
                    id = kopeks.documents[i].data["id"];
                    int doc = kopeks.documents[i].data["i"];

                    id = kopeks.documents[i].data["id"];
                    if (kopeks.documents[i].data["erkek"] == 1) {
                      Map<String, dynamic> uyeBilgi2 = {
                        'erkek': kopeks2.documents[doc].data["erkek"] + 1,
                      };
                      crudObj.girStok(id, uyeBilgi2);
                      uyeBilgi2 = null;
                    } else {
                      Map<String, dynamic> uyeBilgi2 = {
                        'disi': kopeks2.documents[doc].data["disi"] + 1,
                      };
                      crudObj.girStok(id, uyeBilgi2);
                      uyeBilgi2 = null;
                    }
                    crudObj.deleteKapora(kopeks.documents[i].documentID);
                    crudObj.getKapora().then((results) {
                      setState(() {
                        kopeks = results;
                      });
                    });
                    crudObj.getData().then((results2) {
                      setState(() {
                        kopeks2 = results2;
                      });
                    });
                  },
                  child: Text("KAPORAYI SİL"),
                ),
                Container(
                  color: Color(0xffd4dff8),
                  padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Text("Yükleniyor, Lütfen Bekleyiniz..");
    }
  }
}
