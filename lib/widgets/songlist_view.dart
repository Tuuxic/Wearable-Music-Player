import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

import 'sub_widgets/player_bottom_bar.dart';

class SongListView extends StatelessWidget {
  SongListView(
      {super.key,
      required this.themeColor,
      required this.playAndSetCurrentSong,
      required this.songsList,
      required this.toggleView});

  final Color themeColor;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final Function playAndSetCurrentSong;
  final List<SongModel> songsList;
  final Function toggleView;

  final String _songListViewTitle = "Music Player";

  String _durationToTxt(int duration) {
    if (duration < 0) {
      return "0:00";
    }
    int seconds = (duration ~/ 1000) % 60;
    int minutes = duration ~/ (1000 * 60);

    if (minutes >= 60) {
      return ">60 Min";
    }

    String secondsTxt = "$seconds";
    if (seconds < 10) {
      secondsTxt = "0$seconds";
    }
    return "$minutes:$secondsTxt";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Center(child: Text(_songListViewTitle)),
        elevation: 20,
      ),
      bottomNavigationBar: PlayerBottomBar(),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
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

          songsList.clear();
          for (var element in songs.data!) {
            songsList.add(element);
          }

          return ListView.builder(
            itemCount: songs.data!.length,
            itemBuilder: (context, index) {
              return Container(
                margin:
                    const EdgeInsets.only(top: 15.0, left: 12.0, right: 16.0),
                padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                decoration: BoxDecoration(color: themeColor),
                child: ListTile(
                  textColor: Colors.white,
                  title: Text(songs.data![index].title),
                  subtitle: Text(
                    songs.data![index].artist ?? "",
                    style: const TextStyle(
                      color: Colors.white30,
                    ),
                  ),
                  trailing:
                      Text(_durationToTxt(songs.data![index].duration ?? 0)),
                  leading: QueryArtworkWidget(
                    id: songs.data![index].id,
                    type: ArtworkType.AUDIO,
                  ),
                  onTap: () async {
                    playAndSetCurrentSong(index);
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
