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

  //Fix playist in db coming from input on home page

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  // Future<Playlist?> getPlaylist(String playlistUrl) {
  //   return compute(parseSpotifyPlaylist, playlistUrl);
  // }

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
            // future: getPlaylist(widget.playlistUrl),
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
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final playlist = snapshot.data;
                    // SQLHelper.insertPlaylist(playlist!);
                    return PlaylistWidget(playlist: playlist!);
                  }
              }
            },
          ),

          // child: FutureBuilder<Playlist?>(
          //   future: getPlaylist(widget.playlistUrl),
          //   builder: (context, snapshot) {
          //     switch (snapshot.connectionState) {
          //       case ConnectionState.waiting:
          //         return const Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       default:
          //         if (snapshot.hasError) {
          //           return Text('Error: ${snapshot.error}');
          //         } else {
          //           final playlist = snapshot.data;
          //           SQLHelper.insertPlaylist(playlist!);
          //           return PlaylistWidget(playlist: playlist!);
          //         }
          //     }
          //   },
          // ),
        ),
      ),
    );
  }
}
