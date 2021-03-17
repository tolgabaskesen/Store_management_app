import 'package:flutter/material.dart';

import 'firebaseislemleri/kaporalar.dart';
import 'firebaseislemleri/kopeklistesi.dart';
import 'package:burkem_app/views/first_view.dart';
import 'package:burkem_app/views/sign_up_view.dart';
import 'package:burkem_app/widgets/provider_widget.dart';
import 'package:burkem_app/services/auth_service.dart';

import 'firebaseislemleri/satislar.dart';
import './firebaseislemleri/uyelikolustur.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: MaterialApp(
        title: "Burkem VeriTabanı",
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: HomeController(),
        routes: <String, WidgetBuilder>{
          '/signUp': (BuildContext context) =>
              SignUpView(authFormType: AuthFormType.signUp),
          '/signIn': (BuildContext context) =>
              SignUpView(authFormType: AuthFormType.signIn),
          '/signUp2': (BuildContext context) =>
              UyelikOlustur(authFormType2: AuthFormType2.signUp),
          '/signIn2': (BuildContext context) =>
              UyelikOlustur(authFormType2: AuthFormType2.signIn),
          '/home': (BuildContext context) => FirstView(),
          '/SatisSayfasi': (BuildContext context) => SatisSayfasi(),
          '/KaporaSayfasi': (BuildContext context) => KaporaSayfasi(),
          '/KopekListesi': (BuildContext context) => KopekListesi(),
         

        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? KopekListesi() : FirstView();
        }
        return CircularProgressIndicator();
      },
    );
  }
}
