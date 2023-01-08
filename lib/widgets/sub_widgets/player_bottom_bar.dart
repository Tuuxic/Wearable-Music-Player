import 'package:flutter/material.dart';

class PlayerBottomBar extends StatefulWidget {
  const PlayerBottomBar({super.key});

  //final Function getCurrentlyPlayingSong;
  @override
  State<PlayerBottomBar> createState() => _PlayerBottomBarState();
}

class _PlayerBottomBarState extends State<PlayerBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15.0, left: 12.0, right: 16.0),
      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
      decoration: const BoxDecoration(color: Colors.black),
      child: const ListTile(
          textColor: Colors.white,
          title: Text("Test"),
          subtitle: Text(
            "Test",
            style: TextStyle(
              color: Colors.white30,
            ),
          )),
    );
  }
}
