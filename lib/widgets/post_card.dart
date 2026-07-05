import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import 'package:intl/intl.dart';
import '../utils/responsive.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Largeur dynamique : occupe ~60% de l'écran sur mobile, 30% sur tablette
    final cardWidth = Responsive.isMobile(context)
        ? Responsive.width(context) * 0.6
        : Responsive.width(context) * 0.3;

    final imageHeight = cardWidth * 0.45; // Aspect ratio dynamique

    final card = Card(
      margin: const EdgeInsets.only(left: 16, right: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox.shrink(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    if (post.videoUrl != null)
                      Container(
                        width: Responsive.getScaledFontSize(context, 42),
                        height: Responsive.getScaledFontSize(context, 42),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              )
            else
              Container(
                height: imageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            const SizedBox(height: 6),
            // Use FittedBox to scale down content when vertical space is very tight
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: TextStyle(
                        fontSize: Responsive.getScaledFontSize(context, 14),
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'dd MMM yyyy',
                      'fr_FR',
                    ).format(DateTime.parse(post.date)),
                    style: TextStyle(
                      fontSize: Responsive.getScaledFontSize(context, 11),
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: card);
    }
    return card;
  }
}
