import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '/models/playlist.dart';
import '/models/song.dart';

class SQLHelper {
  static Future<void> createTables(Database database) async {
    await database.execute(
      'CREATE TABLE IF NOT EXISTS playlists_info('
      'playlist_url TEXT UNIQUE,'
      'title TEXT,'
      'description TEXT,'
      'image_url TEXT,'
      'artist TEXT,'
      'song_count INTEGER)',
    );
    database.execute(
      'CREATE TABLE IF NOT EXISTS songs('
      'song_url TEXT,'
      'title TEXT,'
      'artist TEXT,'
      'album TEXT,'
      'duration TEXT,'
      'playlist_url TEXT)',
    );
  }

  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'playlists_database.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> insertPlaylist(Playlist playlist) async {
    final db = await SQLHelper.db();

    final id = await db.insert(
      'playlists_info',
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<int> insertSong(Song song) async {
    final db = await SQLHelper.db();
    final id = await db.insert(
      'songs',
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // static Future<List<Map<String, dynamic>>> getItems() async {
  //   final db = await SQLHelper.db();
  //   return db.query('playlists_info');
  //   // return db.query('playlists_info', orderBy: "id");
  // }

  static Future<List<Map<String, dynamic>>> getPlaylists() async {
    final db = await SQLHelper.db();
    return db.query('playlists_info');
  }

  static Future<List<Map<String, dynamic>>> getSongs() async {
    final db = await SQLHelper.db();
    return db.query('songs');
  }

  static Future<bool> isPlaylistInDb(String url) async {
    final db = await SQLHelper.db();
    var query = await db.rawQuery(
        'SELECT COUNT(*) FROM playlists_info WHERE playlist_url = $url');
    int? count = Sqflite.firstIntValue(query);

    return ((count != null) && (count > 0)) ? true : false;
  }

  static Future<List<Map<String, dynamic>>> getPlaylistByUrl(String url) async {
    final db = await SQLHelper.db();

    var query = await db.rawQuery(
        "SELECT * FROM playlists_info WHERE playlist_url LIKE '%$url%'");
    return query;
  }

  static Future<List<Map<String, dynamic>>> getPlaylistSongs(
      String playlistUrl) async {
    final db = await SQLHelper.db();

    var query = await db.rawQuery(
        "SELECT * FROM songs WHERE playlist_url LIKE '%$playlistUrl%'");
    return query;
  }

  static Future<int> deletePlaylistWithSongs(String url) async {
    final db = await SQLHelper.db();

    int count = await db
        .rawDelete("DELETE FROM songs WHERE playlist_url LIKE '%$url%'");

    count = await db.rawDelete(
        "DELETE FROM playlists_info WHERE playlist_url LIKE '%$url%'");

    return count;
  }

  static Future<Playlist> getPlaylistWithSongs(String playlistUrl) async {
    final data = await SQLHelper.getPlaylistByUrl(playlistUrl);
    final songData = await SQLHelper.getPlaylistSongs(playlistUrl);

    List<Map<String, dynamic>> allPlaylists = data;
    List<Map<String, dynamic>> allSongs = songData;
    allPlaylists = data;
    Playlist currentPlaylist = Playlist(
      playlistUrl: data[0]['playlist_url'],
      title: data[0]['title'],
      description: data[0]['description'],
      imageUrl: data[0]['image_url'],
      artist: data[0]['artist'],
      songCount: data[0]['song_count'],
    );

    if ((currentPlaylist.songCount != null) &&
        (currentPlaylist.songCount! > 0)) {
      for (int i = 0; i < currentPlaylist.songCount!.toInt(); i++) {
        currentPlaylist.songsList.add(Song(
          songTitle: songData[i]['title'],
          songUrl: songData[i]['song_url'],
          artist: songData[i]['artist'],
          album: songData[i]['album'],
          duration: songData[i]['duration'],
        ));
      }
    }

    if (allPlaylists.length > 1) {
      print('Error with unique playlist url');
    }
    return currentPlaylist;
  }
}
