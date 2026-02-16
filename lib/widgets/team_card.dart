import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/team_member.dart';

/// Vertical card for grid layout (2-3 columns)
class TeamCard extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onTap;

  const TeamCard({super.key, required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: member.photoUrl != null
                  ? CachedNetworkImageProvider(member.photoUrl!)
                  : null,
              child: member.photoUrl == null
                  ? const Icon(Icons.person, size: 36, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              member.name,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            // Role
            Text(
              member.role ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            // Team badge
            if (member.team != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCD116).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCD116)),
                ),
                child: Text(
                  member.team!,
                  style: const TextStyle(
                    color: Color(0xFFCE1126),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            // Social icons
            _buildSocialRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialRow(BuildContext context) {
    final icons = <Widget>[];

    void addIcon(String? url, IconData icon, Color color) {
      if (url == null || url.isEmpty) return;
      icons.add(
        IconButton(
          onPressed: () => _launchUrl(url),
          icon: FaIcon(icon, color: color, size: 18),
          tooltip: url,
        ),
      );
    }

    addIcon(
      member.facebook,
      FontAwesomeIcons.facebook,
      const Color(0xFF1877F2),
    );
    addIcon(
      member.linkedin,
      FontAwesomeIcons.linkedin,
      const Color(0xFF0A66C2),
    );
    addIcon(member.twitter, FontAwesomeIcons.x, const Color(0xFF1DA1F2));
    addIcon(
      member.instagram,
      FontAwesomeIcons.instagram,
      const Color(0xFFC32AA3),
    );

    if (icons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: icons);
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

/// Horizontal card for single-row layout (image left, info right)
class HorizontalTeamCard extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onTap;

  const HorizontalTeamCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 180,
          child: Row(
            children: [
              // Left: Image (occupies full height)
              SizedBox(
                width: 160,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: member.photoUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              // Right: Information
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Text(
                        member.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Role
                      Text(
                        member.role ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Team badge
                      if (member.team != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCD116).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFCD116),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            member.team!,
                            style: const TextStyle(
                              color: Color(0xFFCE1126),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      // Social icons
                      _buildSocialRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialRow() {
    final icons = <Widget>[];

    void addIcon(String? url, IconData icon, Color color) {
      if (url == null || url.isEmpty) return;
      icons.add(
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            onPressed: () => _launchUrl(url),
            icon: FaIcon(icon, color: color, size: 18),
            padding: EdgeInsets.zero,
          ),
        ),
      );
    }

    addIcon(
      member.facebook,
      FontAwesomeIcons.facebook,
      const Color(0xFF1877F2),
    );
    addIcon(
      member.linkedin,
      FontAwesomeIcons.linkedin,
      const Color(0xFF0A66C2),
    );
    addIcon(member.twitter, FontAwesomeIcons.x, const Color(0xFF1DA1F2));
    addIcon(
      member.instagram,
      FontAwesomeIcons.instagram,
      const Color(0xFFC32AA3),
    );

    if (icons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: icons);
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}
