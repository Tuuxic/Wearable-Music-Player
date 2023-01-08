import 'dart:html';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class SongListView extends StatefulWidget {
  const SongListView(
      {super.key,
      required this.themeColor,
      required this.audioQuery,
      required this.audioPlayer,
      required this.songsList,
      required this.toggleView});
  final Color themeColor;
  final OnAudioQuery audioQuery;
  final AudioPlayer audioPlayer;
  final List<SongModel> songsList;
  final Function toggleView;

  @override
  State<SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<SongListView> {
  final String songListViewTitle = "Music Player";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeColor,
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        title: Text(songListViewTitle),
        elevation: 20,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: widget.audioQuery.querySongs(
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true),
        builder: (context, songs) {
          if (songs.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (songs.data!.isEmpty) {
            return const Center(child: Text("No Songs Found on Device"));
          }

          widget.songsList.clear();
          for (var element in songs.data!) {
            widget.songsList.add(element);
          }

          return ListView.builder(
            itemCount: songs.data!.length,
            itemBuilder: (context, index) {
              return Container(
                margin:
                    const EdgeInsets.only(top: 15.0, left: 12.0, right: 16.0),
                padding: const EdgeInsets.only(top: 30.0, bottom: 30),
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4.0,
                      offset: Offset(-4, -4),
                      color: Colors.white24,
                    ),
                    BoxShadow(
                      blurRadius: 4.0,
                      offset: Offset(4, 4),
                      color: Colors.black,
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () async {
                    List<AudioSource> sources = [];
                    for (var song in songs.data!) {
                      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
                    }
                    ConcatenatingAudioSource playlist =
                        ConcatenatingAudioSource(children: sources);
                    await widget.audioPlayer
                        .setAudioSource(playlist, initialIndex: index);
                    await widget.audioPlayer.play();
                    widget.toggleView();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
