import 'song.dart';

class Playlist {
  Playlist(
      {required this.playlistUrl,
      this.title,
      this.description,
      this.imageUrl,
      this.artist = '',
      this.songCount});

  final String playlistUrl;
  String? title;
  String? imageUrl;
  String? description;
  String artist; /*for album playlists only*/

  int? songCount;
  List<Song> songsList = [];

  bool get isAlbum => (playlistUrl.contains('/album/')) ? true : false;

  Map<String, dynamic> toMap() {
    return {
      'playlist_url': playlistUrl,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'artist': artist,
      'song_count': songCount,
    };
  }

// https://open.spotify.com/playlist/3dpOdyAk3AVSSc0CqXQEA6
// https://open.spotify.com/album/1qwlxZTNLe1jq3b0iidlue
}
