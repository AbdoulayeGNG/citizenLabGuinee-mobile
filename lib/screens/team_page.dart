import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../models/team_member.dart';
import '../widgets/team_card.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final api = Provider.of<ApiService>(context, listen: false);
      if (!api.isLoading) api.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildIntro(context)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverToBoxAdapter(child: _buildMembersSection()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.30;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          CachedNetworkImage(
            imageUrl:
                'https://images.unsplash.com/photo-1520975911787-2c1a893f8e9b?w=1200&q=80',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[300]),
            errorWidget: (context, url, error) =>
                Container(color: Colors.grey[300]),
          ),
          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Une équipe engagée au service de la participation citoyenne',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Professionnels engagés, terrain et expertise pour accompagner la gouvernance ouverte.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Text(
            "L'humain au centre, l'impact comme horizon",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Notre équipe se construit autour de valeurs fortes : inclusion, innovation et collaboration.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Consumer<ApiService>(
      builder: (context, api, _) {
        if (api.isLoading && api.teamMembers.isEmpty) {
          return SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (api.errorMessage != null && api.teamMembers.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 24),
              Text(api.errorMessage!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => api.refreshData(),
                child: const Text('Réessayer'),
              ),
            ],
          );
        }

        final members = api.teamMembers;
        if (members.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(child: Text('Aucun membre trouvé')),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (context, index) {
            final m = members[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: HorizontalTeamCard(
                member: m,
                onTap: () => _showMemberDetail(context, m),
              ),
            );
          },
        );
      },
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
                    Text(
                      m.role ?? '',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      m.description ?? '',
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
                            onPressed: () => _launchUrl(m.facebook!),
                            icon: const Icon(
                              Icons.facebook,
                              color: Color(0xFF1877F2),
                            ),
                          ),
                        if (m.linkedin != null && m.linkedin!.isNotEmpty)
                          IconButton(
                            onPressed: () => _launchUrl(m.linkedin!),
                            icon: const Icon(
                              Icons.link,
                              color: Color(0xFF0A66C2),
                            ),
                          ),
                        if (m.twitter != null && m.twitter!.isNotEmpty)
                          IconButton(
                            onPressed: () => _launchUrl(m.twitter!),
                            icon: const Icon(
                              Icons.alternate_email,
                              color: Color(0xFF1DA1F2),
                            ),
                          ),
                        if (m.instagram != null && m.instagram!.isNotEmpty)
                          IconButton(
                            onPressed: () => _launchUrl(m.instagram!),
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

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}
