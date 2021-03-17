import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationModel {
  String title;
  IconData icon;

  NavigationModel({this.title, this.icon});
}

List<NavigationModel> navigationItems = [
  NavigationModel(title: 'Ana Sayfa', icon: Icons.home),
  NavigationModel(title: 'Üye Ekle', icon: Icons.person_add),
  NavigationModel(title: 'Çıkış Yap', icon: Icons.exit_to_app),
];
