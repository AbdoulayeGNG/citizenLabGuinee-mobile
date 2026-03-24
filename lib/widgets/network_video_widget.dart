import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class NetworkVideoWidget extends StatefulWidget {
  final String url;
  final String? title;

  const NetworkVideoWidget({super.key, required this.url, this.title});

  @override
  State<NetworkVideoWidget> createState() => _NetworkVideoWidgetState();
}

class _NetworkVideoWidgetState extends State<NetworkVideoWidget> {
  BetterPlayerController? _betterPlayerController;
  bool _isBuffering = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      useAsmsSubtitles: false,
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false,
        allowedScreenSleep: false,
        aspectRatio: 16 / 9,
        handleLifecycle: true,
        controlsConfiguration: const BetterPlayerControlsConfiguration(),
      ),
      betterPlayerDataSource: dataSource,
    );

    _betterPlayerController!.addEventsListener(_handleEvent);
  }

  void _handleEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      setState(() => _hasError = true);
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.bufferingStart) {
      setState(() => _isBuffering = true);
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.bufferingEnd) {
      setState(() => _isBuffering = false);
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.removeEventsListener(_handleEvent);
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _errorWidget();
    }

    if (_betterPlayerController == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              BetterPlayer(controller: _betterPlayerController!),
              if (_isBuffering)
                const Center(child: CircularProgressIndicator()),
            ],
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

  Widget _errorWidget() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            const Text('Une erreur est survenue lors de la lecture.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                });
                _betterPlayerController?.retryDataSource();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
