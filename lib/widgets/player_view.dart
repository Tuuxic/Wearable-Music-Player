import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/duration_state.dart';

class PlayerView extends StatefulWidget {
  const PlayerView(
      {super.key,
      required this.themeColor,
      required this.isWearableConnected,
      required this.toggleView,
      required this.currentSong,
      required this.audioPlayer,
      required this.connectToWearable});

  final Color themeColor;
  final bool isWearableConnected;
  final Function toggleView;
  final SongModel currentSong;
  final AudioPlayer audioPlayer;
  final Function connectToWearable;

  // Get the dutation stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          audioPlayer.positionStream,
          audioPlayer.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  // Format the displayed durations displayed under progress bar
  String formatDuration(Duration duration) {
    String durationTxt = duration.toString();
    String removedMiliseconds = durationTxt.split(".")[0];

    if (duration.inHours <= 0) {
      List<String> pieces = removedMiliseconds.split(":");
      return "${pieces[1]}:${pieces[2]}";
    }

    return removedMiliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: widget.themeColor,
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.only(top: 56.0, right: 20.0, left: 20.0),
              decoration: BoxDecoration(color: widget.themeColor),
              child: Column(
                children: <Widget>[
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //Exit Button
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            widget.toggleView();
                          }, //hides the player view
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      // Wearable Connection Status
                      Flexible(
                        flex: 5,
                        child: widget.isWearableConnected
                            ? const Icon(
                                Icons.bluetooth_connected,
                                color: Colors.green,
                              )
                            : InkWell(
                                onTap: (() {
                                  widget.connectToWearable();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                    "Connecting...",
                                    textAlign: TextAlign.center,
                                  )));
                                }),
                                child: const Icon(
                                  Icons.bluetooth_disabled,
                                  color: Colors.red,
                                ),
                              ),
                      ),
                    ],
                  ),

                  // Artwork
                  Container(
                    width: 280,
                    height: 280,
                    margin: const EdgeInsets.only(top: 30, bottom: 30),
                    child: QueryArtworkWidget(
                      id: widget.currentSong.id,
                      type: ArtworkType.AUDIO,
                    ),
                  ),

                  // Song Title
                  Container(
                    width: 300,
                    margin: const EdgeInsets.only(top: 30, bottom: 30),
                    child: Center(
                      child: Text(
                        widget.currentSong.title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Progress Bar
                  Container(
                    padding: EdgeInsets.zero,
                    margin: const EdgeInsets.only(bottom: 4.0),
                    child: StreamBuilder<DurationState>(
                      stream: widget._durationStateStream,
                      builder: (context, snapshot) {
                        final durationState = snapshot.data;
                        final progress =
                            durationState?.position ?? Duration.zero;
                        final total = durationState?.total ?? Duration.zero;

                        return ProgressBar(
                          progress: progress,
                          total: total,
                          barHeight: 20.0,
                          baseBarColor: widget.themeColor,
                          progressBarColor: const Color(0xEE9E9E9E),
                          thumbColor: Colors.white60,
                          timeLabelTextStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          onSeek: (duration) {
                            widget.audioPlayer.seek(duration);
                          },
                        );
                      },
                    ),
                  ),

                  // Previous Button
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        //skip to previous
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              if (widget.audioPlayer.hasPrevious) {
                                widget.audioPlayer.seekToPrevious();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: const Icon(
                                Icons.skip_previous,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),

                        // Play/Pause Button
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              if (widget.audioPlayer.playing) {
                                widget.audioPlayer.pause();
                              } else {
                                if (widget.audioPlayer.currentIndex != null) {
                                  widget.audioPlayer.play();
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              margin: const EdgeInsets.only(
                                  right: 20.0, left: 20.0),
                              child: StreamBuilder<bool>(
                                stream: widget.audioPlayer.playingStream,
                                builder: (context, snapshot) {
                                  bool? playingState = snapshot.data;
                                  if (playingState != null && playingState) {
                                    return const Icon(
                                      Icons.pause,
                                      size: 30,
                                      color: Colors.white70,
                                    );
                                  }
                                  return const Icon(
                                    Icons.play_arrow,
                                    size: 30,
                                    color: Colors.white70,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Next Button
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              if (widget.audioPlayer.hasNext) {
                                widget.audioPlayer.seekToNext();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: const Icon(
                                Icons.skip_next,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          // Clicking Back button gets you back to the songlist view
          widget.toggleView();
          return false;
        });
  }
}
