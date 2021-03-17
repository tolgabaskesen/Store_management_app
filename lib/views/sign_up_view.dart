import 'package:flutter/material.dart';
import 'package:burkem_app/services/auth_service.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:burkem_app/widgets/provider_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

final primaryColor = const Color(0xFFDFC607);

enum AuthFormType { signIn, signUp }

class SignUpView extends StatefulWidget {
  final AuthFormType authFormType;

  SignUpView({Key key, @required this.authFormType}) : super(key: key);

  @override
  _SignUpViewState createState() =>
      _SignUpViewState(authFormType: this.authFormType);
}

class _SignUpViewState extends State<SignUpView> {
  AuthFormType authFormType;

  _SignUpViewState({this.authFormType});

  final formKey = GlobalKey<FormState>();
  String _email, _password, _name, _error;
  String kisi;

  Future<bool> saveNamePrefences(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("name", name);
    return true;
  }

  Future<String> getNamePrefences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    kisi = prefs.getString("name");
    return kisi;
  }

  void saveMail() {
    String name = kisi;
    saveNamePrefences(name).catchError((e) => debugPrint(e));
  }

  void switchFormState(String state) {
    formKey.currentState.reset();
    if (state == "signUp") {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }

  bool validate() {
    final form = formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      try {
        final auth = Provider.of(context).auth;
        if (authFormType == AuthFormType.signIn) {
          String uid = await auth.signInWithEmailAndPassword(_email, _password);
          print("Signed In with ID $uid");

          kisi = _email;
          saveMail();

          Navigator.of(context).pushReplacementNamed('/KopekListesi');
        } else {
          String uid = await auth.createUserWithEmailAndPassword(
              _email, _password, _name);
          print("Signed up with New ID $uid");

          Navigator.of(context).pushReplacementNamed('/KopekListesi');
        }
      } catch (e) {
        print(e);
        setState(() {
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: Color(0xFF9FA8DA),
        height: _height,
        width: _width,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                WillPopScope(
                    child: Container(),
                    onWillPop: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/home');
                    }),
                SizedBox(height: _height * 0.055),
                showAlert(),
                SizedBox(height: _height * 0.025),
                buildHeaderText(),
                SizedBox(height: _height * 0.05),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: buildInputs() + buildButtons(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showAlert() {
    if (_error != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: AutoSizeText(
                _error,
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }

  AutoSizeText buildHeaderText() {
    String _headerText;
    if (authFormType == AuthFormType.signUp) {
      _headerText = "Üyelik Oluştur";
    } else {
      _headerText = "Giriş Yap";
    }
    return AutoSizeText(
      _headerText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 35,
        color: Colors.white,
      ),
    );
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];

    // if were in the sign up state add name
    if (authFormType == AuthFormType.signUp) {
      textFields.add(
        TextFormField(
          validator: NameValidator.validate,
          style: TextStyle(fontSize: 22.0),
          decoration: buildSignUpInputDecoration("İsim"),
          onSaved: (value) => _name = value,
        ),
      );
      textFields.add(SizedBox(height: 20));
    }

    // add email & password
    textFields.add(
      TextFormField(
        validator: EmailValidator.validate,
        style: TextStyle(fontSize: 22.0),
        decoration: buildSignUpInputDecoration("Email"),
        onSaved: (value) => _email = value,
      ),
    );
    textFields.add(SizedBox(height: 20));
    textFields.add(
      TextFormField(
        validator: PasswordValidator.validate,
        style: TextStyle(fontSize: 22.0),
        decoration: buildSignUpInputDecoration("Şifre"),
        obscureText: true,
        onSaved: (value) => _password = value,
      ),
    );
    textFields.add(SizedBox(height: 20));

    return textFields;
  }

  InputDecoration buildSignUpInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.white,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.0)),
      contentPadding:
          const EdgeInsets.only(left: 14.0, bottom: 10.0, top: 10.0),
    );
  }

  List<Widget> buildButtons() {
    String _switchButtonText, _newFormState, _submitButtonText;

    if (authFormType == AuthFormType.signIn) {
      _switchButtonText = "Yeni Üyelik Oluştur";
      _newFormState = "signUp";
      _submitButtonText = "Giriş Yap";
    } else {
      _switchButtonText = "Hesabın var mı? Giriş Yap!";
      _newFormState = "signIn";
      _submitButtonText = "Üye Ol";
    }

    return [
      Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.white,
          textColor: primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _submitButtonText,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
            ),
          ),
          onPressed: submit,
        ),
      ),
      /*FlatButton(
        child: Text(
          _switchButtonText,
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          switchFormState(_newFormState);
        },
      )*/
    ];
  }
}
