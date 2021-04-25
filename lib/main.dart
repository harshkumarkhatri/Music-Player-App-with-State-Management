import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_app/musicPlayerScreen.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // for binding all the widgets

  setUp();
  // This function will create a single instance of audioPlayer
  // throughout the app.

  Directory dir = await getApplicationDocumentsDirectory();
  // getting the directory where the app stores the data

  Hive.init(dir.path);
  await Hive.openBox<String>('myBox');

  Box box = Hive.box<String>('myBox');

  if (box.get('playedOnce') == null) {
    box.put(
      'playedOnce',
      "false",
    );
    // this will state that none of the song has been played.
  }

  runApp(MyApp());
}

final getIt = GetIt.instance;

class BaDumTss {
  AudioPlayer _audio = AudioPlayer();

  AudioPlayer get audio => _audio;
}

void setUp() {
  getIt.registerFactory(() => BaDumTss());
}

// Now we need to initialize some things and assign some values which
// will help us manage the state of the app effectively

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MusicPlayerScreen(),
    );
  }
}
