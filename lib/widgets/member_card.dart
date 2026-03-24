import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/team_member.dart';

class MemberCard extends StatelessWidget {
  final TeamMember member;
  final VoidCallback? onTap;

  const MemberCard({Key? key, required this.member, this.onTap})
    : super(key: key);

  /// Décoder les entités HTML dans l'URL
  String _decodeHtmlEntities(String url) {
    return url
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  /// Formater et valider l'URL avant de l'ouvrir
  String? _formatUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Décoder les entités HTML
    var decoded = _decodeHtmlEntities(url);

    // Si l'URL commence déjà par http ou https, la retourner
    if (decoded.startsWith('http://') || decoded.startsWith('https://')) {
      return decoded;
    }

    // Sinon, ajouter https://
    return 'https://$decoded';
  }

  Future<void> _launchURL(BuildContext context, String? url) async {
    final formattedUrl = _formatUrl(url);
    if (formattedUrl == null || formattedUrl.isEmpty) {
      debugPrint('❌ URL invalide: $url');
      return;
    }

    try {
      final uri = Uri.parse(formattedUrl);
      debugPrint('🔗 Tentative d\'ouverture: $formattedUrl');

      // Essayer différents modes
      bool launched = false;

      // Mode 1 : Application externe (navigateur)
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        launched = true;
        debugPrint('✅ Ouvert en application externe');
      }

      // Mode 2 : Si le mode 1 échoue, essayer le mode par défaut
      if (!launched && await canLaunchUrl(uri)) {
        await launchUrl(uri);
        launched = true;
        debugPrint('✅ Ouvert en mode par défaut');
      }

      if (!launched) {
        debugPrint(
          '⚠️ Impossible d\'ouvrir, affichage fallback: $formattedUrl',
        );
        _showUrlFallback(context, formattedUrl);
      }
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      final fallbackUrl = _formatUrl(url) ?? url ?? '';
      if (fallbackUrl.isNotEmpty) {
        _showUrlFallback(context, fallbackUrl);
      }
    }
  }

  /// Afficher le lien en fallback avec option de copie
  void _showUrlFallback(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lien du profil:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  url,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: '📋 Copier',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lien copié! ✅'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔵 Photo Circulaire
              _buildProfileImage(context),
              const SizedBox(height: 10),

              // Nom
              Flexible(
                child: Text(
                  member.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),

              // Icônes Réseaux Sociaux
              _buildSocialIcons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget pour l'image profil circulaire
  Widget _buildProfileImage(BuildContext context) {
    final hasImage = member.photoUrl != null && member.photoUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 38,
        backgroundColor: Colors.grey[200],
        backgroundImage: hasImage ? NetworkImage(member.photoUrl!) : null,
        child: !hasImage
            ? Icon(
                Icons.person,
                size: 38,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              )
            : null,
      ),
    );
  }

  /// Icônes réseaux sociaux
  Widget _buildSocialIcons(BuildContext context) {
    final socialLinks = [
      (member.linkedin, FontAwesomeIcons.linkedin, 'LinkedIn'),
      (member.twitter, FontAwesomeIcons.twitter, 'Twitter'),
      (member.facebook, FontAwesomeIcons.facebook, 'Facebook'),
      (member.instagram, FontAwesomeIcons.instagram, 'Instagram'),
    ];

    final activeLinks = socialLinks
        .where((link) => link.$1 != null && link.$1!.isNotEmpty)
        .toList();

    if (activeLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      children: activeLinks.map((link) {
        return SizedBox(
          width: 28,
          height: 28,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _launchURL(context, link.$1),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Icon(
                  link.$2,
                  size: 13,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
