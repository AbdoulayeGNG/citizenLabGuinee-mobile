import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/team_member.dart';
import '../services/api_service.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Équipe CitizenLab Guinée')),
      body: apiService.teamMembers.isEmpty
          ? FutureBuilder(
              future: _loadTeamMembers(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildTeamList(context, apiService);
              },
            )
          : _buildTeamList(context, apiService),
    );
  }

  Future<void> _loadTeamMembers(BuildContext context) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    await apiService.refreshData();
  }

  Widget _buildTeamList(BuildContext context, ApiService apiService) {
    if (apiService.teamMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Aucun membre trouvé'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              onPressed: () {
                apiService.refreshData();
              },
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.groups, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Notre Équipe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${apiService.teamMembers.length} membres',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Liste des membres
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: apiService.teamMembers.length,
            itemBuilder: (context, index) {
              final member = apiService.teamMembers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMemberRowCard(context, member),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRowCard(BuildContext context, TeamMember member) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 140,
        child: Row(
          children: [
            // Image à gauche - occupe toute la hauteur avec coins arrondis
            Container(
              width: 130,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: member.photoUrl != null && member.photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: member.photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // Informations à droite
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nom, rôle et description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (member.role != null && member.role!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                member.role!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            )
                          else if (member.description != null && member.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                member.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                          // Email si disponible
                          if (member.description != null && member.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                member.description!.split('\n').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Icônes de contact - affichage horizontal compact
                    if (member.facebook != null ||
                        member.linkedin != null ||
                        member.twitter != null ||
                        member.instagram != null)
                      Wrap(
                        spacing: 2,
                        children: [
                          if (member.facebook != null && member.facebook!.isNotEmpty)
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.facebook,
                                  size: 16,
                                  color: Color(0xFF1877F2),
                                ),
                                onPressed: () async {
                                  final uri = Uri.parse(member.facebook!);
                                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          if (member.linkedin != null && member.linkedin!.isNotEmpty)
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.link,
                                  size: 16,
                                  color: Color(0xFF0A66C2),
                                ),
                                onPressed: () async {
                                  final uri = Uri.parse(member.linkedin!);
                                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          if (member.twitter != null && member.twitter!.isNotEmpty)
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.alternate_email,
                                  size: 16,
                                  color: Color(0xFF1DA1F2),
                                ),
                                onPressed: () async {
                                  final uri = Uri.parse(member.twitter!);
                                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          if (member.instagram != null && member.instagram!.isNotEmpty)
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Color(0xFFC32AA3),
                                ),
                                onPressed: () async {
                                  final uri = Uri.parse(member.instagram!);
                                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}
