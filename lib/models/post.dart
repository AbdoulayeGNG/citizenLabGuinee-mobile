/// Modèle pour un article de blog/actualité
class Post {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String? excerpt;
  final String date;
  final String? imageUrl;
  final String? imageAlt;
  final String? authorName;
  final List<String>? categories; // Noms des catégories
  final String? videoUrl; // URL vidéo (YouTube, Vimeo, etc.)
  final String? videoType; // 'mp4', 'youtube', 'vimeo', 'embed', etc.

  Post({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.excerpt,
    required this.date,
    this.imageUrl,
    this.imageAlt,
    this.authorName,
    this.categories,
    this.videoUrl,
    this.videoType,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<String>? extractCategories(dynamic categoriesData) {
      if (categoriesData == null) return null;
      if (categoriesData is List) {
        return (categoriesData)
            .map(
              (cat) =>
                  cat is Map ? cat['name']?.toString() ?? '' : cat.toString(),
            )
            .where((name) => name.isNotEmpty)
            .toList();
      }
      return null;
    }

    // Extract video URL from content or custom fields
    String? extractVideoUrl(String? content, Map<String, dynamic>? acf) {
      String? videoUrl;

      // Try to extract from ACF fields first (many WP setups use ACF)
      if (acf != null) {
        videoUrl =
            acf['video_url']?.toString() ??
            acf['video']?.toString() ??
            acf['videoUrl']?.toString();
      }

      // If no ACF video, try to extract common embed/source patterns from content
      if (videoUrl == null && content != null && content.isNotEmpty) {
        final c = content;

        // 1) Check for iframe src="..." (covers embed and oembed HTML)
        final iframeSrc = RegExp(
          r'''<iframe[^>]+src=["']([^"']+)["'][^>]*>''',
          caseSensitive: false,
        );
        final iframeMatch = iframeSrc.firstMatch(c);
        if (iframeMatch != null) {
          videoUrl = iframeMatch.group(1);
          print('[Post.fromJson] Found iframe src: $videoUrl');
        }

        // 2) YouTube watch / youtu.be / embed patterns
        if (videoUrl == null) {
          final youtubeWatch = RegExp(
            r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([A-Za-z0-9_-]{11})',
          );
          final m = youtubeWatch.firstMatch(c);
          if (m != null) {
            videoUrl = 'https://www.youtube.com/embed/${m.group(1)}';
            print('[Post.fromJson] Found YouTube watch/youtu.be: $videoUrl');
          }
        }

        // 3) YouTube embed direct (youtube.com/embed/ID)
        if (videoUrl == null) {
          final embedYt = RegExp(r'youtube\.com\/embed\/([A-Za-z0-9_-]{11})');
          final m2 = embedYt.firstMatch(c);
          if (m2 != null) {
            videoUrl = 'https://www.youtube.com/embed/${m2.group(1)}';
            print('[Post.fromJson] Found YouTube embed: $videoUrl');
          }
        }

        // 4) Vimeo embed/player patterns
        if (videoUrl == null) {
          final vimeoEmbed = RegExp(r'player\.vimeo\.com\/video\/(\d+)');
          final vm = vimeoEmbed.firstMatch(c);
          if (vm != null) {
            videoUrl = 'https://player.vimeo.com/video/${vm.group(1)}';
            print('[Post.fromJson] Found Vimeo embed: $videoUrl');
          }
        }

        // 5) Vimeo standard links vimeo.com/ID
        if (videoUrl == null) {
          final vimeoStd = RegExp(r'vimeo\.com\/(\d+)');
          final vm2 = vimeoStd.firstMatch(c);
          if (vm2 != null) {
            videoUrl = 'https://player.vimeo.com/video/${vm2.group(1)}';
            print('[Post.fromJson] Found Vimeo standard: $videoUrl');
          }
        }

        // 6) Direct mp4 links
        if (videoUrl == null) {
          final mp4 = RegExp(r'''https?:\/\/[^\s"']+\.mp4(\?[^\s"']*)?''');
          final m3 = mp4.firstMatch(c);
          if (m3 != null) {
            videoUrl = m3.group(0);
            print('[Post.fromJson] Found MP4: $videoUrl');
          }
        }
      }

      return videoUrl;
    }

    final videoUrl = extractVideoUrl(json['content']?.toString(), json['acf']);
    final videoType = (() {
      if (videoUrl == null) return null;
      final low = videoUrl.toLowerCase();
      if (low.contains('.mp4')) return 'mp4';
      if (low.contains('youtube') || low.contains('youtu.be')) return 'youtube';
      if (low.contains('vimeo')) return 'vimeo';
      return 'embed';
    })();

    if (videoUrl != null) {
      print(
        '[Post.fromJson] Post ${json['slug'] ?? json['id']}: videoUrl=$videoUrl, videoType=$videoType',
      );
    }

    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'],
      date: json['date'] ?? '',
      imageUrl: json['featuredImage']?['node']?['sourceUrl'],
      imageAlt: json['featuredImage']?['node']?['altText'],
      authorName: json['author']?['node']?['name'],
      categories: extractCategories(json['categories']?['edges']),
      videoUrl: videoUrl,
      videoType: videoType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'date': date,
      'imageUrl': imageUrl,
      'imageAlt': imageAlt,
      'authorName': authorName,
      'categories': categories,
      'videoUrl': videoUrl,
      'videoType': videoType,
    };
  }
}
