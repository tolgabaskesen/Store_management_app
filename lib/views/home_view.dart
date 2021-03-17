import 'dart:core';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:burkem_app/firebaseislemleri/curd.dart';

class KopekListesi extends StatefulWidget {
  KopekListesi({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() => _KopekListesistate();
}

class _KopekListesistate extends State<KopekListesi> {
  bool duzenleMi = false;
  String isim;
  int erkek;
  int disi;
  int minfiyat;
  String cinsiyet;

  QuerySnapshot kopeks;

  final formKontrolcu = GlobalKey<FormState>();
  crudMedthods crudObj = new crudMedthods();

  Future<bool> addSatis(BuildContext context, selectedDoc) async {
    isim = kopeks.documents[selectedDoc].data["isim"];
    minfiyat = kopeks.documents[selectedDoc].data["minfiyat"];
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("SATIŞ/KAPORA GİR"),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Form(
                    key: formKontrolcu,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          initialValue:
                              kopeks.documents[selectedDoc].data["isim"],
                          onChanged: (value) {
                            this.isim = value;
                          },
                          readOnly: true,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              hintText: "Erkek sayısını girin:"),
                          onChanged: (value) {
                            this.erkek = int.parse(value);
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: "Dişi sayısını girin:"),
                          onChanged: (value) {
                            this.disi = int.parse(value);
                          },
                        ),
                        TextFormField(
                          initialValue: kopeks
                              .documents[selectedDoc].data["minfiyat"]
                              .toString(),
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: "Minimum fiyat girin:"),
                          onChanged: (value) {
                            this.minfiyat = int.parse(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Map<String, dynamic> uyeBilgi = {
                      'isim': this.isim,
                      'erkek': this.erkek,
                      'disi': this.disi,
                      'minfiyat': this.minfiyat,
                    };
                    crudObj.satisData(uyeBilgi).then((result) {
                      dialogTrigger(context);
                    }).catchError((e) {
                      print(e);
                    });
                  },
                  child: Text("Satış Ekle")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Map<String, dynamic> uyeBilgi = {
                      'isim': this.isim,
                      'erkek': this.erkek,
                      'disi': this.disi,
                      'minfiyat': this.minfiyat,
                    };
                    crudObj.kaporaData(uyeBilgi).then((result) {
                      dialogTrigger(context);
                    }).catchError((e) {
                      print(e);
                    });
                  },
                  child: Text("Kapora Ekle")),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("İptal"),
              ),
            ],
          );
        });
  }

  Future<bool> addDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Köpek Ekle"),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Form(
                    key: formKontrolcu,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration:
                              InputDecoration(hintText: "Köpek ismini girin:"),
                          onChanged: (value) {
                            this.isim = value;
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              hintText: "Erkek sayısını girin:"),
                          onChanged: (value) {
                            this.erkek = int.parse(value);
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: "Dişi sayısını girin:"),
                          onChanged: (value) {
                            this.disi = int.parse(value);
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: "Minimum fiyat girin:"),
                          onChanged: (value) {
                            this.minfiyat = int.parse(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Map<String, dynamic> uyeBilgi = {
                      'isim': this.isim,
                      'erkek': this.erkek,
                      'disi': this.disi,
                      'minfiyat': this.minfiyat,
                    };
                    crudObj.addData(uyeBilgi).then((result) {
                      dialogTrigger(context);
                      initState();
                    }).catchError((e) {
                      print(e);
                    });
                  },
                  child: Text("Köpek Ekle")),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("İptal"),
              ),
            ],
          );
        });
  }

  Future<bool> dialogTrigger(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Başarılı", style: TextStyle(fontSize: 15.0)),
            content: Text("Eklendi"),
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

  Future<bool> addStok(BuildContext context, selectedDoc) async {
    isim = kopeks.documents[selectedDoc].data["isim"];
    minfiyat = kopeks.documents[selectedDoc].data["minfiyat"];
    erkek = kopeks.documents[selectedDoc].data["erkek"];
    disi = kopeks.documents[selectedDoc].data["disi"];
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("STOK GİR"),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Form(
                    key: formKontrolcu,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          initialValue:
                              kopeks.documents[selectedDoc].data["isim"],
                          onChanged: (value) {
                            this.isim = value;
                          },
                          readOnly: true,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              hintText: "Erkek sayısını girin:"),
                          onChanged: (value) {
                            this.erkek = int.parse(value);
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: "Dişi sayısını girin:"),
                          onChanged: (value) {
                            this.disi = int.parse(value);
                          },
                        ),
                        TextFormField(
                          initialValue: kopeks
                              .documents[selectedDoc].data["minfiyat"]
                              .toString(),
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: "Minimum fiyat girin:"),
                          onChanged: (value) {
                            this.minfiyat = int.parse(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Map<String, dynamic> uyeBilgi = {
                      'isim': this.isim,
                      'erkek': this.erkek,
                      'disi': this.disi,
                      'minfiyat': this.minfiyat,
                    };
                    crudObj
                        .girStok(
                            kopeks.documents[selectedDoc].documentID, uyeBilgi)
                        .then((results) {
                      dialogTrigger(results);
                    }).catchError((e) {
                      print(e);
                    });
                  },
                  child: Text("Stok Güncelle")),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("İptal"),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    crudObj.getData().then((results) {
      setState(() {
        kopeks = results;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amberAccent[100],
        appBar: AppBar(
          backgroundColor: Color(0xFFDFC607),
          title: new Text("Kopek Listesi"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                addDialog(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                crudObj.getData().then((results) {
                  setState(() {
                    kopeks = results;
                  });
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
        bottomNavigationBar: new BottomNavigationBar(
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
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            onTap: (int i) {
              switch (i) {
                case 0:
                  return;
                case 1:
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/SatisSayfasi');

                  return;
                case 2:
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/KaporaSayfasi');

                  return;
              }
            }),
        body: _kopekList());
  }

  Widget _kopekList() {
    if (kopeks != null) {
      return ListView.builder(
          itemCount: kopeks.documents.length,
          padding: EdgeInsets.all(8.0),
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
                        "\nMinimum Satış Fiyatı = " +
                        kopeks.documents[i].data["minfiyat"].toString()),
                    isThreeLine: true,
                  ),
                  FlatButton(
                    onPressed: () {
                      addStok(context, i);
                    },
                    child: Text("STOK GÜNCELLE"),
                  ),
                  FlatButton(
                    onPressed: () {
                      addSatis(context, i);
                    },
                    child: Text("SATIŞ/KAPORA EKLE"),
                  ),
                  Container(
                    color: Colors.amberAccent[100],
                    padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                  ),
                ],
              ),
            );
          });
    } else {
      return Text("Yükleniyor, Lütfen Bekleyiniz..");
    }
  }
}
