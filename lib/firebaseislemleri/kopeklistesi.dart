import 'dart:core';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:burkem_app/services/search_service.dart';

import 'package:burkem_app/yanmenu/yanmenu.dart';
import 'curd.dart';

import 'package:fluttertoast/fluttertoast.dart';

class KopekListesi extends StatefulWidget {
  KopekListesi({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() => _KopekListesistate();
}

String girisyapan = "";

class _KopekListesistate extends State<KopekListesi> {
  var queryResultSet = [];
  var tempSearchStore = [];
  bool duzenleMi = false;
  String isim;
  int erkek;
  int disi;
  int minfiyat;
  String cinsiyet;
  int sartfiyat;
  String kisi = "";
  QuerySnapshot kopeks;

  final formKontrolcu = GlobalKey<FormState>();
  crudMedthods crudObj = new crudMedthods();

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['isim'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  Future<String> getNamePrefences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    kisi = prefs.getString("name");
    return kisi;
  }

  void getName() {
    getNamePrefences();
  }

  @override
  void initState() {
    crudObj.getData().then((results) {
      setState(() {
        kopeks = results;
      });
    });

    super.initState();
    getName();
  }

  Future<bool> addSatis(BuildContext context, selectedDoc) async {
    isim = kopeks.documents[selectedDoc].data["isim"];
    minfiyat = kopeks.documents[selectedDoc].data["minfiyat"];
    sartfiyat = kopeks.documents[selectedDoc].data["minfiyat"];

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
                    if (sartfiyat > this.minfiyat) {
                      Fluttertoast.showToast(
                        msg: "Satış fiyatı " +
                            sartfiyat.toString() +
                            "'dan küçük olamaz!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    } else if ((this.erkek == 0 && this.disi == 0) ||
                        ((this.erkek == null && this.disi == null))) {
                      Fluttertoast.showToast(
                        msg: "En az / En fazla 1 Satış Giriniz!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    } else if ((this.erkek == 1 && this.disi != 0) ||
                        (this.disi == 1 && this.erkek != 0)) {
                      Fluttertoast.showToast(
                        msg:
                            "1 Seferde 1 Satış Giriniz!\n    Boş kısma 0 yazınız!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    } else if (this.erkek != 1) {
                      if (this.disi != 1) {
                        Fluttertoast.showToast(
                          msg: "En az / En fazla 1 Satış Giriniz!",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                        );
                      } else {
                        Navigator.of(context).pop();
                        Map<String, dynamic> uyeBilgi = {
                          'isim': this.isim,
                          'erkek': this.erkek,
                          'disi': this.disi,
                          'minfiyat': this.minfiyat,
                          'kisi': kisi,
                        };
                        crudObj.satisData(uyeBilgi).then((result) {
                          Map<String, dynamic> uyeGuncel = {
                            'disi':
                                kopeks.documents[selectedDoc].data["disi"] - 1,
                          };
                          crudObj.girStok(
                              kopeks.documents[selectedDoc].documentID,
                              uyeGuncel);
                          dialogTrigger(context);
                        }).catchError((e) {
                          print(e);
                        });
                      }
                    } else if (this.disi != 1) {
                      if (this.erkek != 1) {
                        Fluttertoast.showToast(
                          msg: "En az / En fazla 1 Satış Giriniz!",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                        );
                      } else {
                        Navigator.of(context).pop();
                        Map<String, dynamic> uyeBilgi = {
                          'isim': this.isim,
                          'erkek': this.erkek,
                          'disi': this.disi,
                          'minfiyat': this.minfiyat,
                          'kisi': kisi,
                        };
                        crudObj.satisData(uyeBilgi).then((result) {
                          Map<String, dynamic> uyeGuncel = {
                            'erkek':
                                kopeks.documents[selectedDoc].data["erkek"] - 1,
                          };
                          crudObj.girStok(
                              kopeks.documents[selectedDoc].documentID,
                              uyeGuncel);
                          dialogTrigger(context);
                        }).catchError((e) {
                          print(e);
                        });
                      }
                    } else {
                      Navigator.of(context).pop();
                      Map<String, dynamic> uyeBilgi = {
                        'isim': this.isim,
                        'erkek': this.erkek,
                        'disi': this.disi,
                        'minfiyat': this.minfiyat,
                        'kisi': kisi,
                      };
                      crudObj.satisData(uyeBilgi).then((result) {
                        dialogTrigger(context);
                      }).catchError((e) {
                        print(e);
                      });
                    }
                    crudObj.getData().then((results) {
                      setState(() {
                        kopeks = results;
                      });
                    });
                  },
                  child: Text("Satış Ekle")),
              FlatButton(
                  onPressed: () {
                    if (100 > this.minfiyat) {
                      Fluttertoast.showToast(
                        msg: "Kapora Fiyatı 100TL den az olamaz!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    } else if ((this.erkek == 0 && this.disi == 0) ||
                        ((this.erkek == null && this.disi == null))) {
                      Fluttertoast.showToast(
                        msg: "En az / En fazla 1 Kapora Giriniz!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    } else if ((this.erkek == 1 && this.disi != 0) ||
                        (this.disi == 1 && this.erkek != 0)) {
                      Fluttertoast.showToast(
                        msg:
                            "1 Seferde 1 Kapora Giriniz!\n    Boş kısma 0 yazınız!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    } else if (this.erkek != 1) {
                      if (this.disi != 1) {
                        Fluttertoast.showToast(
                          msg: "En az / En fazla 1 Kapora Giriniz!",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                        );
                      } else {
                        Navigator.of(context).pop();
                        Map<String, dynamic> uyeBilgi = {
                          'isim': this.isim,
                          'erkek': this.erkek,
                          'disi': this.disi,
                          'minfiyat': this.minfiyat,
                          'id': kopeks.documents[selectedDoc].documentID,
                          'i': selectedDoc,
                          'kisi': kisi,
                        };
                        crudObj.kaporaData(uyeBilgi).then((result) {
                          Map<String, dynamic> uyeGuncel = {
                            'disi':
                                kopeks.documents[selectedDoc].data["disi"] - 1,
                          };
                          crudObj.girStok(
                              kopeks.documents[selectedDoc].documentID,
                              uyeGuncel);
                          dialogTrigger(context);
                        }).catchError((e) {
                          print(e);
                        });
                      }
                    } else if (this.disi != 1) {
                      if (this.erkek != 1) {
                        Fluttertoast.showToast(
                          msg: "En az / En fazla 1 Kapora Giriniz!",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                        );
                      } else {
                        Navigator.of(context).pop();
                        Map<String, dynamic> uyeBilgi = {
                          'isim': this.isim,
                          'erkek': this.erkek,
                          'disi': this.disi,
                          'minfiyat': this.minfiyat,
                          'id': kopeks.documents[selectedDoc].documentID,
                          'i': selectedDoc,
                          'kisi': kisi,
                        };
                        crudObj.kaporaData(uyeBilgi).then((result) {
                          Map<String, dynamic> uyeGuncel = {
                            'erkek':
                                kopeks.documents[selectedDoc].data["erkek"] - 1,
                          };
                          crudObj.girStok(
                              kopeks.documents[selectedDoc].documentID,
                              uyeGuncel);
                          dialogTrigger(context);
                        }).catchError((e) {
                          print(e);
                        });
                      }
                    } else {
                      Navigator.of(context).pop();
                      Map<String, dynamic> uyeBilgi = {
                        'isim': this.isim,
                        'erkek': this.erkek,
                        'disi': this.disi,
                        'minfiyat': this.minfiyat,
                        'id': kopeks.documents[selectedDoc].documentID,
                        'i': selectedDoc,
                      };
                      crudObj.kaporaData(uyeBilgi).then((result) {
                        dialogTrigger(context);
                      }).catchError((e) {
                        print(e);
                      });
                    }
                    crudObj.getData().then((results) {
                      setState(() {
                        kopeks = results;
                      });
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
                  crudObj.girStok(
                      kopeks.documents[selectedDoc].documentID, uyeBilgi);
                  crudObj.getData().then((results) {
                    setState(() {
                      kopeks = results;
                    });
                  });
                },
                child: Text("Stok Güncelle"),
              ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffd4dff8),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xFF75A2EA),
        leading: new Image.asset(
          "assets/images/icon.png",
          height: 25,
          width: 25,
        ),
        title: Text("Köpek Listesi"),
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
        ],
      ),
      //drawer: CollapsingNavigationDrawer(),
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
      ),
    );
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
                        "\nMinimum Satış Fiyatı = " +
                        kopeks.documents[i].data["minfiyat"].toString()),
                    isThreeLine: true,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                      ),
                      FlatButton(
                        color: Color(0xffd4dff8),
                        onPressed: () {
                          addStok(context, i).then((value) {
                            crudObj.getData().then((results) {
                              setState(() {
                                kopeks = results;
                              });
                            });
                          });
                        },
                        child: Text("STOK"),
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                      ),
                      FlatButton(
                        color: Color(0xffd4dff8),
                        onPressed: () {
                          addSatis(context, i);
                        },
                        child: Text("SATIŞ/KAPORA"),
                      ),
                    ],
                  ),
                  Container(
                    color: Color(0xffd4dff8),
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
