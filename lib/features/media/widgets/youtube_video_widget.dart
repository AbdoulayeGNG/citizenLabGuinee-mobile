import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class YoutubeVideoWidget extends StatefulWidget {
  final String url;
  final String? title;

  const YoutubeVideoWidget({super.key, required this.url, this.title});

  @override
  State<YoutubeVideoWidget> createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget> {
  late YoutubePlayerController _controller;
  bool _hasError = false;
  Timer? _timeoutTimer;
  bool _launchedExternal = false;
  bool _showReplay = false;

  String? _extractId(String url) {
    // supports watch?v=, youtu.be, embed/ and strips query params
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

  @override
  void initState() {
    super.initState();
    final id = _extractId(widget.url) ?? YoutubePlayer.convertUrlToId(widget.url) ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        forceHD: false,
        enableCaption: true,
        showLiveFullscreenButton: true,
        controlsVisibleAtStart: false,
      ),
    )..addListener(_listener);

    // Timeout after 15 seconds if not ready
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (!_controller.value.isReady && !_launchedExternal) {
        _launchedExternal = true;
        _openExternal();
      }
    });
  }

  void _listener() {
    if (_controller.value.isReady && _timeoutTimer != null) {
      _timeoutTimer!.cancel();
      _timeoutTimer = null;
    }
    if (_controller.value.hasError && !_hasError) {
      setState(() => _hasError = true);
      if (!_launchedExternal) {
        _launchedExternal = true;
        _timeoutTimer?.cancel();
        _timeoutTimer = null;
        Future.delayed(const Duration(milliseconds: 600), () async {
          await _openExternal();
        });
      }
    }
    // Show replay button when video ends
    if (_controller.value.playerState == PlayerState.ended && !_showReplay) {
      setState(() => _showReplay = true);
    }
    // Hide replay button when playing
    if (_controller.value.playerState == PlayerState.playing && _showReplay) {
      setState(() => _showReplay = false);
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // nothing
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: false,
              progressIndicatorColor: Colors.redAccent,
              bottomActions: [
                CurrentPosition(),
                ProgressBar(isExpanded: true),
                RemainingDuration(),
                FullScreenButton(),
              ],
            ),
            if (_showReplay)
              Container(
                color: Colors.black54,
                child: IconButton(
                  iconSize: 64,
                  icon: const Icon(Icons.replay, color: Colors.white),
                  onPressed: () {
                    _controller.seekTo(const Duration(seconds: 0));
                    _controller.play();
                  },
                ),
              ),
          ],
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
