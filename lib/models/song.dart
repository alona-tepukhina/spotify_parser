class Song {
  Song(
      {required this.songTitle,
      this.songUrl,
      this.artist,
      this.album,
      this.duration,
      this.playlistUrl});

  String songTitle;
  String? songUrl;
  String? artist;
  String? album;
  String? duration;
  String? playlistUrl;

  Map<String, dynamic> toMap() {
    return {
      'song_url': songUrl,
      'title': songTitle,
      'album': album,
      'artist': artist,
      'duration': duration,
      'playlist_url': playlistUrl,
    };
  }
}
