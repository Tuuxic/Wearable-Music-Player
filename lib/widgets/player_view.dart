import 'package:flutter/material.dart';

class PlayerView extends StatefulWidget {
  const PlayerView(
      {super.key, required this.themeColor, required this.toggleView});

  final Color themeColor;
  final Function toggleView;
  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(),
        onWillPop: () async {
          widget.toggleView();
          return false;
        });
  }
}
