import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ironbreeze/src/util/ui_factory.dart';

class AnimationsScreen extends StatelessWidget {
  final int count;

  const AnimationsScreen({Key key, count = 1000})
      : this.count = count ?? 1000,
        super(key: key);

  Widget _oneCoin() {
    return UiFactory.coinFlipAnimation(
      child: Container(
        width: 30,
        height: 30,
        child: UiFactory.generateLogo(tintColorHexa: "fff"),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xff3083ff),
        ),
      ),
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> allCoins = List<Widget>(count);
    for (int i = 0; i < count; i++) {
      allCoins[i] = _oneCoin();
    }

    return Scaffold(
      appBar: AppBar(
        title: _oneCoin(),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          direction: Axis.horizontal,
          children: allCoins,
        ),
      ),
    );
  }
}
