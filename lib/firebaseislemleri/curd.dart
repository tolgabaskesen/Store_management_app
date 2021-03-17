import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class crudMedthods {
  bool isLogged() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addData(uyebilgi) async {
    if (isLogged()) {
      Firestore.instance.collection('/kopekler').add(uyebilgi).catchError((e) {
        print(e);
      });
    } else
      print("Üye Girişi Yapınız!");
  }

  getData() async {
    return await Firestore.instance.collection('kopekler').getDocuments();
  }

  getSatis() async {
    return await Firestore.instance.collection('satislar').getDocuments();
  }

  getKapora() async {
    return await Firestore.instance.collection('kapora').getDocuments();
  }

  Future<void> deleteData(uyebilgi) async {
    if (isLogged()) {
      Firestore.instance
          .collection('/kopekler')
          .document(uyebilgi)
          .delete()
          .catchError((e) {
        print(e);
      });
    } else
      print("Üye Girişi Yapınız!");
  }

  deleteSatis(docID) async {
    Firestore.instance
        .collection('satislar')
        .document(docID)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  deleteKapora(docID) async {
    Firestore.instance
        .collection('kapora')
        .document(docID)
        .delete()
        .catchError((e) {
      print(e);
    });
  }
  
  girStok(selectedDoc, newValues) {
    Firestore.instance
        .collection('/kopekler')
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> satisData(uyebilgi) async {
    if (isLogged()) {
      Firestore.instance.collection('/satislar').add(uyebilgi).catchError((e) {
        print(e);
      });
    } else
      print("Üye Girişi Yapınız!");
  }

  Future<void> kaporaData(uyebilgi) async {
    if (isLogged()) {
      Firestore.instance.collection('/kapora').add(uyebilgi).catchError((e) {
        print(e);
      });
    } else
      print("Üye Girişi Yapınız!");
  }
}
