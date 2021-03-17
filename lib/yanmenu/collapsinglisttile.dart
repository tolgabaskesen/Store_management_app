import 'package:flutter/material.dart';
import 'package:burkem_app/theme.dart';

class CollapsingListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final AnimationController animationController;
  final bool isSelected;
  final Function onTap;

  CollapsingListTile({
    @required this.title,
    @required this.icon,
    @required this.animationController,
    this.isSelected = false,
    this.onTap,
  });

  @override
  _CollapsingListTileState createState() => _CollapsingListTileState();
}

class _CollapsingListTileState extends State<CollapsingListTile> {
  Animation<double> widhtAnimation, sizedBoxAnimation;

  @override
  void initState() {
    super.initState();
    widhtAnimation =
        Tween<double>(begin: 230, end: 50).animate(widget.animationController);
    sizedBoxAnimation =
        Tween<double>(begin: 10, end: 0).animate(widget.animationController);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          color: widget.isSelected
              ? Colors.transparent.withOpacity(0.3)
              : Colors.transparent,
        ),
        width: widhtAnimation.value,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: <Widget>[
            Icon(widget.icon,
                color: widget.isSelected ? selectedColor : Colors.white70,
                size: 38.0),
            SizedBox(
              width: sizedBoxAnimation.value,
            ),
            (widhtAnimation.value >= 220)
                ? Text(
                    widget.title,
                    style: widget.isSelected
                        ? listTitleSelectedTextStyle
                        : listTitleDefaultTextStyle,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
