import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerBottomBar extends StatelessWidget {
  const PlayerBottomBar(
      {super.key, required this.displayPlayingSong, required this.toggleView});

  final SongModel? displayPlayingSong;
  final Function toggleView;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (displayPlayingSong != null) {
          toggleView();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(
            top: 15.0, left: 12.0, right: 16.0, bottom: 15.0),
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        decoration: const BoxDecoration(color: Colors.black),
        child: ListTile(
          textColor: Colors.white,
          title: Text(displayPlayingSong?.title ?? ""),
          subtitle: Text(
            displayPlayingSong?.artist ?? "",
            style: const TextStyle(
              color: Colors.white30,
            ),
          ),
          leading: QueryArtworkWidget(
            id: displayPlayingSong?.id ?? -1,
            type: ArtworkType.AUDIO,
          ),
        ),
      ),
    );
  }
}
