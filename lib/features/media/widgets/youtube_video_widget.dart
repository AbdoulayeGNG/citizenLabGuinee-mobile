import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubeVideoWidget extends StatefulWidget {
  final String url;
  final String? title;

  const YoutubeVideoWidget({super.key, required this.url, this.title});

  @override
  State<YoutubeVideoWidget> createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget> {
  late final YoutubePlayerController _controller;
  bool _isReady = false;
  bool _hasError = false;

  String? _extractId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      }
      if (uri.queryParameters.containsKey('v')) return uri.queryParameters['v'];
      final segments = uri.pathSegments;
      if (segments.contains('embed')) {
        final idx = segments.indexOf('embed');
        if (segments.length > idx + 1) return segments[idx + 1];
      }
    } catch (_) {}
    return null;
  }

  bool _launchedExternal = false;
  @override
  void initState() {
    super.initState();
    final id = _extractId(widget.url);
    _controller = YoutubePlayerController.fromVideoId(
      videoId: id ?? widget.url,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
    _controller.listen((value) {
      if (!mounted) return;
      if (value.hasError) {
        if (!_hasError) {
          setState(() => _hasError = true);
          // automatic fallback: open externally when embedding fails
          if (!_launchedExternal) {
            _launchedExternal = true;
            Future.delayed(const Duration(milliseconds: 600), () async {
              // Prefer opening in YouTube app using video id, then fallback to watch URL, then embed URL
              String? id;
              try {
                final u = Uri.parse(widget.url);
                if (u.host.contains('youtu')) {
                  final m = RegExp(
                    r'([A-Za-z0-9_-]{11})',
                  ).firstMatch(u.path + (u.query.isNotEmpty ? u.query : ''));
                  id = m?.group(1);
                }
              } catch (_) {}

              final candidates = <Uri>[];
              if (id != null) {
                candidates.add(Uri.parse('vnd.youtube:$id'));
                candidates.add(
                  Uri.parse('https://www.youtube.com/watch?v=$id'),
                );
              }
              candidates.add(Uri.parse(widget.url));

              for (final uri in candidates) {
                try {
                  if (await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  ))
                    return;
                } catch (_) {}
              }
            });
          }
        }
      }
      if (!_isReady) setState(() => _isReady = true);
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YoutubePlayerControllerProvider(
          controller: _controller,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                YoutubePlayer(controller: _controller),
                if (_hasError)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Ouvrir sur YouTube'),
                          onPressed: () async {
                            final uri = Uri.parse(widget.url);
                            if (!await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            )) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Impossible d\'ouvrir la vidéo en externe.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.title!, style: const TextStyle(fontSize: 16)),
          ),
      ],
    );
  }
}
