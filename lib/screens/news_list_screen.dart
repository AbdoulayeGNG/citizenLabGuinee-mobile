import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';

String _stripHtml(String htmlString) {
  final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
  return htmlString.replaceAll(exp, '').trim();
}

class NewsBanner extends StatelessWidget {
  const NewsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = max(screenHeight * 0.32, 280.0); // Safe minimum height

    return SizedBox(
      height: bannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          CachedNetworkImage(
            imageUrl:
                'https://example.com/civic-engagement-banner.jpg', // Replace with actual image URL
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: const Color(0xFF009460)),
            errorWidget: (context, url, error) =>
                Container(color: const Color(0xFF009460)),
          ),
          // Gradient overlay with Guinea flag colors
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFCE1126).withOpacity(0.7),
                  const Color(0xFFFCD116).withOpacity(0.5),
                  const Color(0xFF009460).withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ),
          // Text content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualités',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Découvrez les dernières actualités et initiatives',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final Post post;

  const NewsCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

    return Card(
      margin: EdgeInsets.zero, // Marges gérées par le GridView parent
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to article detail with Hero animation
          Navigator.pushNamed(
            context,
            '/article',
            arguments: {'id': post.slug},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (post.imageUrl != null)
              Hero(
                tag: 'news-image-${post.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCD116),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.article,
                      size: 60,
                      color: Color(0xFFCE1126),
                    ),
                  ),
                ),
              ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'news-title-${post.id}',
                      child: Text(
                        post.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.getScaledFontSize(
                                context,
                                18,
                              ),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateFormat.format(DateTime.parse(post.date)),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        _stripHtml(post.excerpt ?? ''),
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Assuming posts are provided via Provider or similar
    final posts = Provider.of<ApiService>(context).posts
        .where(
          (post) =>
              post.categories?.any(
                (cat) => cat.toLowerCase().contains('actualit'),
              ) ??
              false,
        )
        .toList();

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: const NewsBanner()),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.getGridColumns(
                    context,
                    mobile: 1,
                    tablet: 2,
                    largeTablet: 3,
                  ),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: Responsive.isMobile(context) ? 400 : 420,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = posts[index];
                  return NewsCard(post: post);
                }, childCount: posts.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
