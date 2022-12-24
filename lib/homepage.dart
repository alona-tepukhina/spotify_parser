import 'package:flutter/material.dart';
import 'playlist_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'db/sql_helper.dart';
import 'utilities/validators.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _playlistURLController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> allPlaylists = [];
  List<Map<String, dynamic>> allSongs = [];

  bool isLoading = true;

  void loadPlaylistsFromDb() async {
    final data = await SQLHelper.getPlaylists();
    setState(() {
      allPlaylists = data;
      isLoading = false;
    });
  }

  void loadSongsFromDb() async {
    final data = await SQLHelper.getSongs();
    setState(() {
      allSongs = data;
      isLoading = false;
    });
  }

  void deletePlaylist(String url) async {
    await SQLHelper.deletePlaylistWithSongs(url);
    loadPlaylistsFromDb();
  }

  @override
  void initState() {
    _playlistURLController.clear();
    loadPlaylistsFromDb();
    super.initState();
  }

  @override
  void dispose() {
    _playlistURLController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 24),
          child: Column(children: [
            const Text('My playlists',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 16,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _playlistURLController,
                    keyboardType: TextInputType.url,
                    showCursor: true,
                    decoration: InputDecoration(
                        label: const Text('Spotify playlist url'),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                            onPressed: () {
                              _playlistURLController.clear();
                            },
                            icon: const Icon(Icons.clear))),
                    validator: (String? value) {
                      if ((value == null) ||
                          (value == '') ||
                          !((value.contains('playlist')) ||
                              (value.contains('album'))) ||
                          (!value.isValidURL())) {
                        return 'Invalid URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Add playlist',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlaylistScreen(
                                    playlistUrl: _playlistURLController.text,
                                  )),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (allPlaylists.isNotEmpty)
              Expanded(
                child: ListView.builder(
                    itemCount: allPlaylists.length,
                    itemBuilder: (context, index) {
                      var currentPlaylist = allPlaylists[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaylistScreen(
                                playlistUrl: currentPlaylist['playlist_url'],
                                isPlaylistInDb: true,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (currentPlaylist['image_url'] != null)
                                  CachedNetworkImage(
                                    width: 100,
                                    height: 100,
                                    // height: 72,
                                    fit: BoxFit.cover,
                                    imageUrl: currentPlaylist['image_url'],
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    currentPlaylist['title'] ?? '',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                PopupMenuButton(
                                    icon: const Icon(Icons.more_vert),
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          child: const Text('Delete playlist'),
                                          onTap: () {
                                            deletePlaylist(currentPlaylist[
                                                'playlist_url']);
                                          },
                                        )
                                      ];
                                    }),
                              ]),
                        ),
                      );
                    }),
              ),
          ]),
        ),
      ),
    );
  }
}
