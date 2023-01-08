import 'package:bleapp/widgets/songlist_view.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'utils/duration_state.dart';
import 'widgets/player_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // The theme color of the application
  Color themeColor = const Color(0X1a1a1aFF);
  // List of all songs
  List<SongModel> songsList = [];
  int currentSongIndex = 0;
  bool inPlayerView = false;

  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Get the dutation stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _audioPlayer.positionStream,
          _audioPlayer.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

  @override
  void initState() {
    super.initState();

    // Setup listener for currently playing song stream
    _audioPlayer.currentIndexStream.listen((index) {
      // Update currently playing song when not null
      if (index != null) {
        setState(() {
          if (songsList.isNotEmpty) {
            currentSongIndex = index;
          }
        });
      }
    });
  }

  // Dispose of audio player
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (inPlayerView) {
      return PlayerView(
        themeColor: themeColor,
      );
    } else {
      return SongListView(
          themeColor: themeColor,
          audioPlayer: _audioPlayer,
          audioQuery: _audioQuery,
          songsList: songsList,
          toggleView: _toggleView);
    }
  }

  void _toggleView() {
    setState(() {
      inPlayerView = !inPlayerView;
    });
  }
}
