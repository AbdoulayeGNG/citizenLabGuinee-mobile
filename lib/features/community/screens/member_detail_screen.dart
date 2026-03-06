import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/team_member.dart';

class MemberDetailScreen extends StatelessWidget {
  final TeamMember member;

  const MemberDetailScreen({
    Key? key,
    required this.member,
  }) : super(key: key);

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

  Future<void> _launchURL(String? url) async {
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
        debugPrint('⚠️ Impossible d\'ouvrir, affichage fallback: $formattedUrl');
      }
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = member.photoUrl != null && member.photoUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔵 Photo Grande
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      hasImage ? NetworkImage(member.photoUrl!) : null,
                  child: !hasImage
                      ? Icon(
                          Icons.person,
                          size: 70,
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                        )
                      : null,
                ),
              ),
            ),

            // Nom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                member.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Rôle
            if (member.role != null && member.role!.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  member.role!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            else if (member.team != null && member.team!.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  member.team!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Icônes Réseaux Sociaux
            _buildSocialLinks(context),
            const SizedBox(height: 32),

            // Bio complète
            if (member.description != null && member.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'À propos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      member.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Icônes réseaux sociaux cliquables
  Widget _buildSocialLinks(BuildContext context) {
    final socialLinks = [
      (member.linkedin, FontAwesomeIcons.linkedin, 'LinkedIn'),
      (member.twitter, FontAwesomeIcons.twitter, 'Twitter'),
      (member.facebook, FontAwesomeIcons.facebook, 'Facebook'),
      (member.instagram, FontAwesomeIcons.instagram, 'Instagram'),
    ];

    final activeLinks = socialLinks.where((link) => link.$1 != null && link.$1!.isNotEmpty).toList();

    if (activeLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: activeLinks.map((link) {
        return _buildSocialButton(
          context: context,
          icon: link.$2,
          label: link.$3,
          url: link.$1,
        );
      }).toList(),
    );
  }

  /// Bouton réseau social
  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String? url,
  }) {
    return Tooltip(
      message: label,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => _launchURL(url),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
