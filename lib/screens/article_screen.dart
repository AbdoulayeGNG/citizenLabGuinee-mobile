import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.delayed(Duration.zero),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return WebViewWidget(controller: _controller);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
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
            // Video or featured image
            if (article.videoUrl != null && article.videoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    if (article.videoType == 'mp4') {
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPlayerWidget(url: article.videoUrl!),
                      );
                    }
                    // Fallback to WebView for embed links (YouTube/Vimeo)
                    return SizedBox(
                      height: 220,
                      child: EmbedPlayerWidget(url: article.videoUrl!),
                    );
                  },
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
