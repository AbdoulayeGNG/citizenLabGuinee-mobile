class VideoModel {
  final String url;
  final String? thumbnailUrl;
  final String? title;

  const VideoModel({required this.url, this.thumbnailUrl, this.title});

  bool get isYouTube {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  bool get isNetworkVideo {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.contains('.m3u8') || lower.startsWith('http');
  }
}
