import 'package:flutter/material.dart';
import '/models/playlist.dart';
import '/utilities/str_to_time.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaylistWidget extends StatelessWidget {
  const PlaylistWidget({
    super.key,
    required this.playlist,
  });

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: Row(
            children: [
              if (playlist.imageUrl != null)
                // Image.network(
                //   playlist.imageUrl!,
                //   width: 160,
                // ),
                CachedNetworkImage(
                  width: 200,
                  imageUrl: playlist.imageUrl!,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      playlist.title ?? '',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(playlist.description ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: playlist.songsList.length,
            itemBuilder: (context, index) {
              var currentSong = playlist.songsList[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(currentSong.songTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Artist: ${currentSong.artist}'),
                        if (!playlist.isAlbum)
                          Text('Album: ${currentSong.album}'),
                        Text(
                            'Duration: ${strToTime(currentSong.duration ?? '')}'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
