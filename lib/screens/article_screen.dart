import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../models/video_model.dart';
import '../widgets/video_player_screen.dart';
import '../widgets/youtube_video_widget.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';

String _stripHtmlTags(String? html) {
  if (html == null) return '';
  // Very small sanitizer to remove tags — for complex HTML use flutter_html package
  final withoutTags = html.replaceAll(RegExp(r'<[^>]*>', multiLine: true), '');
  return withoutTags.replaceAll('&nbsp;', ' ').trim();
}

class EmbedPlayerWidget extends StatefulWidget {
  final String url;

  const EmbedPlayerWidget({super.key, required this.url});

  @override
  State<EmbedPlayerWidget> createState() => _EmbedPlayerWidgetState();
}

class _EmbedPlayerWidgetState extends State<EmbedPlayerWidget> {
  late WebViewController _controller;
  bool _connectivityTested = false;
  bool _embedFailed = false;
  bool _triedNoCookie = false;
  String? _currentEmbedUrl;

  String _normalizeEmbedUrl(String url) {
    // Ensure URL is properly formatted for embed
    String embedUrl = url;

    // If it's a YouTube URL, normalize to embed format
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      if (!url.contains('/embed/')) {
        // Extract video ID and convert to embed URL
        final RegExp youtubeRegex = RegExp(
          r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([A-Za-z0-9_-]{11})',
        );
        final match = youtubeRegex.firstMatch(url);
        if (match != null) {
          embedUrl =
              'https://www.youtube.com/embed/${match.group(1)}?autoplay=0&rel=0&modestbranding=1';
        }
      }
    }

    return embedUrl;
  }

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final embedUrl = _normalizeEmbedUrl(widget.url);
    _currentEmbedUrl = embedUrl;
    debugPrint('[EmbedPlayerWidget] Loading YouTube embed: $embedUrl');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; SM-A125N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('[EmbedPlayerWidget] Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('[EmbedPlayerWidget] Page finished loading: $url');
            // If we just tested connectivity, now load the actual embed URL
            if (!_connectivityTested && url.contains('example.com')) {
              _connectivityTested = true;
              debugPrint(
                '[EmbedPlayerWidget] Connectivity test OK, now loading embed',
              );
              _controller.loadRequest(Uri.parse(embedUrl));
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              '[EmbedPlayerWidget] WebResource error: code=${error.errorCode} description=${error.description}',
            );

            if (_embedFailed) return;

            // If connection refused, try the privacy-enhanced nocookie domain once
            if (error.errorCode == -6 &&
                !_triedNoCookie &&
                _currentEmbedUrl != null) {
              _triedNoCookie = true;
              final nocookie = _currentEmbedUrl!.replaceFirst(
                'www.youtube.com',
                'www.youtube-nocookie.com',
              );
              debugPrint(
                '[EmbedPlayerWidget] Attempting nocookie URL: $nocookie',
              );
              _controller.loadRequest(Uri.parse(nocookie));
              return;
            }

            // Fallback: try Chrome Custom Tab on Android, otherwise open externally
            _embedFailed = true;
            final toLaunch = _currentEmbedUrl ?? widget.url;
            Future.microtask(() async {
              final uri = Uri.parse(toLaunch);
              try {
                if (!await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                )) {
                  debugPrint(
                    '[EmbedPlayerWidget] Could not launch external URL: $toLaunch',
                  );
                }
              } catch (e) {
                if (!await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                )) {
                  debugPrint(
                    '[EmbedPlayerWidget] Could not launch external URL (fallback): $toLaunch',
                  );
                }
              }
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint(
              '[EmbedPlayerWidget] Navigation request: ${request.url}',
            );
            return NavigationDecision.navigate;
          },
        ),
      )
      // First load a known reachable page to verify WebView network access,
      // then the onPageFinished handler will load the real embed URL.
      ..loadRequest(Uri.parse('https://www.example.com'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class LazyEmbedWidget extends StatefulWidget {
  final String url;
  final String? type;
  final String? thumbnailUrl;

  const LazyEmbedWidget({
    super.key,
    required this.url,
    this.type,
    this.thumbnailUrl,
  });

  @override
  State<LazyEmbedWidget> createState() => _LazyEmbedWidgetState();
}

class _LazyEmbedWidgetState extends State<LazyEmbedWidget> {
  bool _playing = false;

  String? _youtubeId(String url) {
    final m = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([A-Za-z0-9_-]{11})',
    ).firstMatch(url);
    return m?.group(1);
  }

  Widget _buildThumbnail() {
    final thumb = widget.type == 'youtube'
        ? (_youtubeId(widget.url) != null
              ? 'https://img.youtube.com/vi/${_youtubeId(widget.url)}/hqdefault.jpg'
              : widget.thumbnailUrl)
        : widget.thumbnailUrl;

    return Stack(
      children: [
        if (thumb != null && thumb.isNotEmpty)
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: thumb,
              fit: BoxFit.cover,
              placeholder: (c, u) => Container(color: Colors.grey[300]),
              errorWidget: (c, u, e) => Container(color: Colors.grey[300]),
            ),
          )
        else
          Container(height: 220, color: Colors.grey[300]),
        Positioned.fill(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 48),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[LazyEmbedWidget] type=${widget.type}, url=${widget.url}');

    if (_playing) {
      if (widget.type == 'mp4') {
        debugPrint('[LazyEmbedWidget] Playing MP4: ${widget.url}');
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayerWidget(url: widget.url),
        );
      }
      if (widget.type == 'youtube') {
        debugPrint('[LazyEmbedWidget] Playing YouTube inline: ${widget.url}');
        return YoutubeVideoWidget(url: widget.url);
      }
      debugPrint('[LazyEmbedWidget] Playing Embed: ${widget.url}');
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: EmbedPlayerWidget(url: widget.url),
      );
    }

    return GestureDetector(
      onTap: () async {
        debugPrint('[LazyEmbedWidget] Tap to play');
        if (widget.type == 'youtube') {
          setState(() {
            _playing = true;
          });
        } else {
          setState(() {
            _playing = true;
          });
        }
      },
      child: _buildThumbnail(),
    );
  }

  Future<void> _launchYouTubeExternal(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[LazyEmbedWidget] Failed to launch: $e');
    }
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _initializeFuture = _controller!.initialize().then((_) {
      setState(() {});
    });
    _controller!.setLooping(false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const SizedBox.shrink();
    return FutureBuilder(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  });
                },
                child: Center(
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ArticleScreen extends StatefulWidget {
  final String articleId;

  const ArticleScreen({super.key, required this.articleId});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  Post? _article;
  bool _isLoadingNetwork = false;

  @override
  void initState() {
    super.initState();
    _loadCachedThenNetwork();
  }

  Future<void> _loadCachedThenNetwork() async {
    final api = Provider.of<ApiService>(context, listen: false);

    // Try cached post first
    try {
      final cached = await api.getCachedPost(widget.articleId);
      if (cached != null && mounted) {
        setState(() {
          _article = cached;
        });
      }
    } catch (e) {
      debugPrint('Error reading cached post: $e');
    }

    // Always attempt network fetch to refresh (in background)
    if (mounted) {
      setState(() {
        _isLoadingNetwork = true;
      });
    }
    try {
      final fresh = await api.fetchPostById(widget.articleId);
      if (fresh != null && mounted) {
        setState(() {
          _article = fresh;
        });
      }
    } catch (e) {
      debugPrint('Network fetch for article failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNetwork = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    // Show cached immediately, or loading spinner if nothing cached yet
    if (_article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Article')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final article = _article!;

    // Build the page showing possible video + content and related posts
    final relatedPosts = apiService.posts
        .where((p) => p.slug != article.slug)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video or featured image (lazy embed)
            if (article.videoUrl != null && article.videoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LazyEmbedWidget(
                  url: article.videoUrl!,
                  type: article.videoType,
                  thumbnailUrl: article.imageUrl,
                ),
              )
            else if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    DateFormat(
                      'dd MMM yyyy',
                      'fr_FR',
                    ).format(DateTime.parse(article.date)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),

                  if (article.categories != null &&
                      article.categories!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: article.categories!
                          .map((category) => Chip(label: Text(category)))
                          .toList(),
                    ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  Text(
                    _stripHtmlTags(article.content),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            if (relatedPosts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Articles connexes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedPosts.length > 3
                            ? 3
                            : relatedPosts.length,
                        itemBuilder: (context, index) {
                          final post = relatedPosts[index];
                          return PostCard(
                            post: post,
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              '/article',
                              arguments: {'id': post.slug},
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _shareArticle(BuildContext context, Post article) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager via...'),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('WhatsApp'),
              onTap: () {
                // Implémenter le partage WhatsApp
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.facebook),
              title: const Text('Facebook'),
              onTap: () {
                // Implémenter le partage Facebook
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copier le lien'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
