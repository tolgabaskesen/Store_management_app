import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:burkem_app/model/navigation_model.dart';
import 'package:burkem_app/services/auth_service.dart';

import 'package:burkem_app/widgets/provider_widget.dart';
import 'package:burkem_app/yanmenu/collapsinglisttile.dart';

import '../theme.dart';

class CollapsingNavigationDrawer extends StatefulWidget {
  @override
  _CollapsingNavigationDrawerState createState() =>
      _CollapsingNavigationDrawerState();
}

class _CollapsingNavigationDrawerState extends State<CollapsingNavigationDrawer>
    with SingleTickerProviderStateMixin {
  double maxWidht = 230;
  double minWidht = 55;
  bool isCollapsed = false;
  AnimationController _animationController;
  Animation<double> widthAnimation;
  int currentSelectedIndex = 0;

  String kisi;
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
    super.initState();
    _animationController =
        AnimationController(value: this, duration: Duration(milliseconds: 300));
    widthAnimation = Tween<double>(begin: maxWidht, end: minWidht)
        .animate(_animationController);
    _animationController.forward();
    getName();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, widget) => getWidget(context, widget),
    );
  }

  Widget getWidget(context, widget) {
    return Container(
      width: widthAnimation.value,
      color: drawerBackgroundColor,
      child: Column(
        children: <Widget>[
          CollapsingListTile(
            title: (kisi.substring(0, kisi.lastIndexOf('@'))).toUpperCase(),
            icon: Icons.person_pin,
            onTap: () {},
            animationController: _animationController,
          ),
          SizedBox(height: 100.0),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, counter) {
                return Divider(
                  color: Colors.grey,
                  height: 10.0,
                );
              },
              itemBuilder: (context, counter) {
                return CollapsingListTile(
                  onTap: () async {
                    setState(() {
                      currentSelectedIndex = counter;
                    });
                    if (currentSelectedIndex == 0) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/KopekListesi');
                    } else if (currentSelectedIndex == 1) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/signUp2');
                    } else if (currentSelectedIndex == 2) {
                      try {
                        AuthService auth = Provider.of(context).auth;
                        await auth.signOut();
                        print("Signed Out!");
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/home');
                      } catch (e) {
                        print(e);
                      }
                    }
                  },
                  isSelected: currentSelectedIndex == counter,
                  title: navigationItems[counter].title,
                  icon: navigationItems[counter].icon,
                  animationController: _animationController,
                );
              },
              itemCount: navigationItems.length,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                isCollapsed = !isCollapsed;
                isCollapsed
                    ? _animationController.reverse()
                    : _animationController.forward();
              });
            },
            child: AnimatedIcon(
              icon: AnimatedIcons.close_menu,
              progress: _animationController,
              color: Colors.white,
              size: 50.0,
            ),
          ),
          SizedBox(height: 50.0),
        ],
      ),
    );
  }
}
