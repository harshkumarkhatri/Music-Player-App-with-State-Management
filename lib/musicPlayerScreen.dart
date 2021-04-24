import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_app/customListItem_widget.dart';
import 'package:flutter_music_player_app/main.dart';
import 'package:hive/hive.dart';

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with WidgetsBindingObserver
// this will be ufor oberserving the life cycle of the app
{
  // Initializing some variables
  Duration duration;
  Duration position;
  bool isPlaying = false;
  IconData btnIcon = Icons.play_arrow;

  BaDumTss instance;
  AudioPlayer audioPlayer;

  Box box = Hive.box<String>('myBox');

  String currentSong = "";
  String currentCover = "";
  String currentTitle = "";
  String currentSinger = "";
  String url = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    instance = getIt<BaDumTss>();
    audioPlayer = instance.audio;
    duration = new Duration();
    position = new Duration();

    if (box.get('playedOnce') == "false") {
      // If the app is opened for the first time so no song has been played yet
      setState(() {
        currentCover =
            "https://i.pinimg.com/originals/25/0c/e1/250ce1e27b85c49afd1c745d8cb02ffa.png";
        currentTitle = "Choose a song to play";
      });
    } else if (box.get('playedOnce') == "true") {
      // If user is opening the app second or third time and he has already played a song
      currentCover = box.get('currentCover');
      currentSinger = box.get('currentSinger');

      currentTitle = box.get('currentTitle');
      url = box.get('url');
    }
  }

  // Adding oberver for handling the instance of audioPlayer according to the applifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      audioPlayer.pause();
      setState(() {
        btnIcon = Icons.pause;
      });
    } else if (state == AppLifecycleState.resumed) {
      if (isPlaying == true) {
        audioPlayer.resume();
        setState(() {
          btnIcon = Icons.play_arrow;
        });
      }
    } else if (state == AppLifecycleState.detached) {
      audioPlayer.stop();
      audioPlayer.release();
    }
  }

  // disposing to save memory leaks
  @override
  void dispose() {
    // TODO: implement dispose

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void playMusic(String url) async {
    if (isPlaying && currentSong != url) {
      audioPlayer.pause();
      int result = await audioPlayer.play(url);
      if (result == 1) {
        setState(() {
          currentSong = url;
        });
      }
    } else if (!isPlaying) {
      int result = await audioPlayer.play(url);
      if (result == 1) {
        setState(() {
          isPlaying = true;
          btnIcon = Icons.play_arrow;
        });
      }
    }
    // Setting the state of duration(current/end points)
    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  // Creating a list of songs.
  // You can find this list in the description or in the resource.
  // You can also create an api which will restun JSON data related to the songs
  // Checkout my other course/video for that.

  List music = [
    {
      "title": "Tech House vibes",
      "singer": "Alejandro Magaña (A. M.)",
      "url":
          "https://assets.mixkit.co/music/preview/mixkit-tech-house-vibes-130.mp3",
      "coverUrl":
          "https://res.cloudinary.com/harshkumarkhatri/image/upload/v1621057519/music%20app/download_ezpkhj.jpg"
    },
    {
      "title": "Hazy After Hours",
      "singer": "Alejandro Magaña",
      "url":
          "https://assets.mixkit.co/music/preview/mixkit-hazy-after-hours-132.mp3",
      "coverUrl":
          "https://res.cloudinary.com/harshkumarkhatri/image/upload/v1621057509/music%20app/download_1_ooio6l.jpg"
    },
    {
      "title": "Hip Hop 02",
      "singer": "Lily J",
      "url": "https://assets.mixkit.co/music/preview/mixkit-hip-hop-02-738.mp3",
      "coverUrl":
          "https://res.cloudinary.com/harshkumarkhatri/image/upload/v1621057509/music%20app/download_2_awf0yr.jpg"
    },
    {
      "title": "A Very Happy Christmas",
      "singer": "Michael Ramir C.",
      "url":
          "https://assets.mixkit.co/music/preview/mixkit-a-very-happy-christmas-897.mp3",
      "coverUrl":
          "https://res.cloudinary.com/harshkumarkhatri/image/upload/v1621057508/music%20app/download_3_gvodu0.jpg"
    },
  ];
  // These are the songs and their details which we will be using in our app

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Music Player",
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => customListItem(
                  title: music[index]['title'],
                  singer: music[index]['singer'],
                  cover: music[index]['coverUrl'],
                  onTap: () async {
                    setState(() {
                      currentTitle = music[index]['title'];
                      currentSinger = music[index]['singer'];
                      currentCover = music[index]['coverUrl'];
                      url = music[index]['url'];
                    });
                    playMusic(url);
                    // we need to create the playMusic Function
                    // TODO:Playmusic function

                    box.put('playedOnce', 'true');
                    box.put('currentCover', currentCover);
                    box.put('currentSinger', currentSinger);
                    box.put('currentTitle', currentTitle);
                    box.put('url', url);
                  }),
              itemCount: music.length,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(
                    0x55212121,
                  ),
                  blurRadius: 8,
                )
              ],
            ),
            child: Column(
              children: [
                Slider.adaptive(
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    // We will be creating this function
                    seekToSecond(value.toInt());
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        position.inSeconds.toDouble().toString(),
                      ),
                      Text(
                        duration.inSeconds.toDouble().toString(),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            currentCover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Text(currentSinger,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ))
                        ],
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          btnIcon,
                          size: 42,
                        ),
                        onPressed: () {
                          // here it needs to be string not boolean
                          // re running the app
                          if (box.get('playedOnce') == "true" &&
                              isPlaying == false) {
                            playMusic(url);
                          } else {
                            if (isPlaying) {
                              audioPlayer.pause();
                              setState(() {
                                btnIcon = Icons.pause;
                                isPlaying = false;
                              });
                            } else {
                              audioPlayer.resume();
                              setState(() {
                                btnIcon = Icons.play_arrow;
                                isPlaying = true;
                              });
                              // lets close and re run the app
                            }
                          }
                        }),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
