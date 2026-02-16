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
    return InkWell(
      onTap: () => _showMemberDetail(context, member),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          height: 140,
          child: Row(
            children: [
              // Image à gauche
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
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
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

              // Droite: nom + réseaux
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        member.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Row(
                        children: [
                          if (member.facebook != null &&
                              member.facebook!.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.facebook,
                                color: Color(0xFF1877F2),
                              ),
                              onPressed: () async {
                                final uri = Uri.parse(member.facebook!);
                                if (await canLaunchUrl(uri))
                                  await launchUrl(uri);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (member.linkedin != null &&
                              member.linkedin!.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.link,
                                color: Color(0xFF0A66C2),
                              ),
                              onPressed: () async {
                                final uri = Uri.parse(member.linkedin!);
                                if (await canLaunchUrl(uri))
                                  await launchUrl(uri);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (member.twitter != null &&
                              member.twitter!.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.alternate_email,
                                color: Color(0xFF1DA1F2),
                              ),
                              onPressed: () async {
                                final uri = Uri.parse(member.twitter!);
                                if (await canLaunchUrl(uri))
                                  await launchUrl(uri);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (member.instagram != null &&
                              member.instagram!.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Color(0xFFC32AA3),
                              ),
                              onPressed: () async {
                                final uri = Uri.parse(member.instagram!);
                                if (await canLaunchUrl(uri))
                                  await launchUrl(uri);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
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

  void _showMemberDetail(BuildContext context, TeamMember m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: m.photoUrl ?? '',
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
                    const SizedBox(height: 12),
                    Text(
                      m.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    if (m.role != null && m.role!.isNotEmpty)
                      Text(
                        m.role!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    const SizedBox(height: 18),
                    if (m.description != null && m.description!.isNotEmpty)
                      Text(
                        m.description!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Socials
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (m.facebook != null && m.facebook!.isNotEmpty)
                          IconButton(
                            onPressed: () async {
                              final uri = Uri.parse(m.facebook!);
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            },
                            icon: const Icon(
                              Icons.facebook,
                              color: Color(0xFF1877F2),
                            ),
                          ),
                        if (m.linkedin != null && m.linkedin!.isNotEmpty)
                          IconButton(
                            onPressed: () async {
                              final uri = Uri.parse(m.linkedin!);
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            },
                            icon: const Icon(
                              Icons.link,
                              color: Color(0xFF0A66C2),
                            ),
                          ),
                        if (m.twitter != null && m.twitter!.isNotEmpty)
                          IconButton(
                            onPressed: () async {
                              final uri = Uri.parse(m.twitter!);
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            },
                            icon: const Icon(
                              Icons.alternate_email,
                              color: Color(0xFF1DA1F2),
                            ),
                          ),
                        if (m.instagram != null && m.instagram!.isNotEmpty)
                          IconButton(
                            onPressed: () async {
                              final uri = Uri.parse(m.instagram!);
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFFC32AA3),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}
