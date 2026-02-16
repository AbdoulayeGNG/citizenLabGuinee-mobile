import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/video_model.dart';
import 'network_video_widget.dart';
import 'youtube_video_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _openExternally(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir la vidéo en externe.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;

    Widget body;
    if (video.isYouTube) {
      // Use youtube_player_iframe for in-app playback; if device blocks it user can open externally
      body = YoutubeVideoWidget(url: video.url, title: video.title);
    } else if (video.isNetworkVideo) {
      body = NetworkVideoWidget(url: video.url, title: video.title);
    } else {
      // Unknown type — open externally
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Type de média non pris en charge en natif.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _openExternally(video.url),
                child: const Text('Ouvrir en externe'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(video.title ?? 'Lecture vidéo')),
      body: SafeArea(child: SingleChildScrollView(child: body)),
    );
  }
}
