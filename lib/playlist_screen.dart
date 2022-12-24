import 'package:flutter/material.dart';
import 'homepage.dart';
import 'models/playlist.dart';
import 'parsers/spotify_playlist_parser.dart';
import 'dart:async';
import 'widgets/playlist_widget.dart';
import 'db/sql_helper.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen(
      {Key? key, required this.playlistUrl, this.isPlaylistInDb = false})
      : super(key: key);

  final String playlistUrl;
  final bool isPlaylistInDb;
  
  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
 
  Playlist? currentPlaylist;

  Future<Playlist> loadPlaylistFromDb() async {
    final playist = await SQLHelper.getPlaylistWithSongs(widget.playlistUrl);
    return playist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MyHomePage()));
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 24),
          child: FutureBuilder<Playlist?>(
            future: (widget.isPlaylistInDb)
                ? loadPlaylistFromDb()
                : parseSpotifyPlaylist(widget.playlistUrl),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'An error has occured.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                              'Please check your internet connection and URL you\'ve entered.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyHomePage()),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 8),
                              child: Text(
                                'Back to main screen',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final playlist = snapshot.data;
                    return PlaylistWidget(playlist: playlist!);
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
