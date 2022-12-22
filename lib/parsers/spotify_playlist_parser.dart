import 'package:html/dom.dart' as html_dom;
import '/models/song.dart';
import '/models/playlist.dart';
import '/networking/networking.dart';
import '/db/sql_helper.dart';

String? parseElement(String elementAttribute, html_dom.Document document) {
  final parsedElement = document.getElementsByTagName('meta').firstWhere(
      (element) => element.attributes.values.contains(elementAttribute));
  return parsedElement.attributes['content'];
}

Future<Playlist?> parseSpotifyPlaylist(String playlistUrl) async {
  html_dom.Document playlistDocument =
      await NetworkRequest.getHttpData(playlistUrl);

  if (playlistDocument != null) {
    final playlist = Playlist(playlistUrl: playlistUrl);

    playlist.title = parseElement('og:title', playlistDocument);
    playlist.imageUrl = parseElement('og:image', playlistDocument);
    playlist.description = parseElement('og:description', playlistDocument);
    String? songCountStr = parseElement('music:song_count', playlistDocument);

    playlist.songCount = int.parse(songCountStr!) ?? 0;

    // if (playlist.isAlbum) {
    // doesn't work, don't know why
    if (playlistUrl.contains('album')) {
      print('Album!!!');
      String? artistURL = parseElement('music:musician', playlistDocument);

      var artistDocument = await NetworkRequest.getHttpData(artistURL!);

      if (artistDocument != null) {
        String? artist = parseElement('og:title', artistDocument);
        playlist.artist = artist!;
      }
    }

    if (playlist.songCount != 0) {
      Map artistsCollection = {};
      Map albumsCollection = {};

      var songElements = playlistDocument
          .getElementsByTagName('meta')
          .where((element) => element.attributes.containsValue('music:song'));

      for (var element in songElements) {
        var songURL = element.attributes['content'];

        var songDocument = await NetworkRequest.getHttpData(songURL!);

        if (songDocument != null) {
          String? songTitle = parseElement('og:title', songDocument);

          if ((songTitle != null) && (songTitle != '')) {
            final songInfoTmp = Song(songTitle: songTitle);
            songInfoTmp.songUrl = songURL;
            songInfoTmp.playlistUrl = playlistUrl;

            String? songDurationStr =
                parseElement('music:duration', songDocument);
            songInfoTmp.duration = songDurationStr;

            if (!playlist.isAlbum) {
              String? artistURL = parseElement('music:musician', songDocument);

              if (artistsCollection.isNotEmpty &&
                  artistsCollection.containsKey(artistURL)) {
                songInfoTmp.artist = artistsCollection[artistURL];
              } else {
                var artistDocument =
                    await NetworkRequest.getHttpData(artistURL!);

                if (artistDocument != null) {
                  String? artist = parseElement('og:title', artistDocument);
                  songInfoTmp.artist = artist;
                  artistsCollection[artistURL] = artist;
                }
              }

              String? albumURL = parseElement('music:album', songDocument);

              if (albumsCollection.isNotEmpty &&
                  albumsCollection.containsKey(albumURL)) {
                songInfoTmp.album = albumsCollection[albumURL];
              } else {
                var albumDocument = await NetworkRequest.getHttpData(albumURL!);

                if (albumDocument != null) {
                  String? album = parseElement('og:title', albumDocument);
                  songInfoTmp.album = album;
                  albumsCollection[albumURL] = album;
                }
              }
            }
            playlist.songsList.add(songInfoTmp);
            SQLHelper.insertSong(songInfoTmp!);
          }
        }
      }
    }
    SQLHelper.insertPlaylist(playlist!);
    return playlist;
  } else {
    return null;
  }
}
