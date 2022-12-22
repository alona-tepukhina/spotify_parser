import 'package:flutter/material.dart';
import 'package:spotify_parser/widgets/playlist_widget.dart';
import 'playlist_screen.dart';
import 'utilities/validators.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'db/sql_helper.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

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
      // appBar: AppBar(
      //   title: const Text('Playlists'),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 24),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _playlistURLController,
                        keyboardType: TextInputType.url,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          label: Text('Spotify playlist url'),
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          if ((value == null) || (value.isEmpty)) {
                            return 'Please enter URL';
                          }
                          // if ((value != null) && (value != '')) {
                          //   if (!value.isValidURL()) {
                          //     return 'Invalid URL';
                          //   }
                          // }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        child: const Text('Add playlist'),
                        onPressed: () {
                          String url = _playlistURLController.text;
                          // if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlaylistScreen(
                                    playlistUrl: _playlistURLController.text)),
                          );

                          // }
                        },
                      ),
                      const SizedBox(height: 16),
                      // OutlinedButton(
                      //   onPressed: () {
                      //     loadPlaylistsFromDb();
                      //     loadSongsFromDb();
                      //   },
                      //   child: const Text('Print from db'),
                      // ),
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
                            child: DecoratedBox(
                              decoration:
                                  BoxDecoration(color: Colors.grey.shade200),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: ((currentPlaylist['image_url'] !=
                                        null))
                                    ? CachedNetworkImage(
                                        width: 120,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        imageUrl: currentPlaylist['image_url'],
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      )
                                    : null,
                                title: Text(
                                  currentPlaylist['title'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                // trailing: IconButton(
                                //   icon: const Icon(Icons.close),
                                //   onPressed: () async {
                                //     setState(() {
                                //       SQLHelper.deletePlaylistWithSongs(
                                //           currentPlaylist['playlist_url']);
                                //     });
                                //   },
                                // ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Expanded(
                //   child: ListView.builder(
                //     itemCount: allPlaylists.length,
                //     itemBuilder: (context, index) {
                //       var currentPlaylist = allPlaylists[index];
                //       return GestureDetector(
                //         onTap: () {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => PlaylistScreen(
                //                 playlistUrl: currentPlaylist['playlist_url'],
                //                 isPlaylistInDb: true,
                //               ),
                //             ),
                //           );
                //         },
                //         child: Card(
                //           child: DecoratedBox(
                //             decoration:
                //                 BoxDecoration(color: Colors.grey.shade200),
                //             child: Row(
                //               children: [
                //                 if (currentPlaylist['image_url'] != null)
                //                   CachedNetworkImage(
                //                     width: 120,
                //                     height: 72,
                //                     fit: BoxFit.cover,
                //                     imageUrl: currentPlaylist['image_url'],
                //                     errorWidget: (context, url, error) =>
                //                         const Icon(Icons.error),
                //                   ),
                //                 const SizedBox(
                //                   width: 8,
                //                 ),
                //                 Expanded(
                //                   child: Text(
                //                     currentPlaylist['title'] ?? '',
                //                     style: const TextStyle(
                //                         fontSize: 20,
                //                         fontWeight: FontWeight.bold),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // ),
              ],
            )),
      ),
    );
  }
}