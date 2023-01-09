import 'package:bleapp/wearables/esense_controller.dart';
import 'package:bleapp/widgets/songlist_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'widgets/player_view.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wearable\'s Music Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // The theme color of the application
  Color themeColor = const Color.fromARGB(26, 71, 71, 71);
  // List of all songs
  List<SongModel> songsList = [];
  int currentSongIndex = -1;
  bool inPlayerView = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  late ESenseController? wearable;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
    _requestBluetoothAndLocationPermission();

    // Setup listener for currently playing song stream
    _audioPlayer.currentIndexStream.listen((index) {
      // Update currently playing song when not null
      if (index != null) {
        //playAndSetCurrentSong(index);
        setState((() => currentSongIndex = index));
      }
    });
    _audioPlayer.setLoopMode(LoopMode.all);

    wearable = ESenseController(
        deviceName: "eSence-012",
        onRightShake: onRightShake,
        onLeftShake: onLeftShake);
    wearable?.connect();
    wearable?.startListening();
  }

  // Dispose of audio player
  @override
  void dispose() {
    _audioPlayer.dispose();
    wearable?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (inPlayerView) {
      return PlayerView(
        themeColor: themeColor,
        toggleView: toggleView,
        currentSong: songsList[currentSongIndex],
        audioPlayer: _audioPlayer,
      );
    } else {
      return SongListView(
          themeColor: themeColor,
          playAndSetCurrentSong: playAndSetCurrentSong,
          songsList: songsList,
          displayPlayingSong: _getSongToDisplay(),
          toggleView: toggleView);
    }
  }

  SongModel? _getSongToDisplay() {
    if (currentSongIndex >= 0 && currentSongIndex < songsList.length) {
      return songsList[currentSongIndex];
    }

    return null;
  }

  void toggleView() {
    setState(() {
      inPlayerView = !inPlayerView;
    });
  }

  void playAndSetCurrentSong(int index) async {
    List<AudioSource> sources = [];

    for (var song in songsList) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    ConcatenatingAudioSource playlist =
        ConcatenatingAudioSource(children: sources);

    await _audioPlayer.setAudioSource(playlist, initialIndex: index);
    await _audioPlayer.play();

    setState(() {
      if (songsList.isNotEmpty) {
        currentSongIndex = index;
      }
    });
  }

  // Setup wearable actions

  void onRightShake() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
      await _audioPlayer.play();
    }
  }

  void onLeftShake() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
      await _audioPlayer.play();
    }
  }

  // Setup permissions

  final OnAudioQuery _audioQuery = OnAudioQuery();
  void _requestStoragePermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  void _requestBluetoothAndLocationPermission() async {
    await Permission.bluetooth.request();
    await Permission.locationWhenInUse.request();
    await Permission.bluetoothScan.request();

    setState(() {});
  }
}
