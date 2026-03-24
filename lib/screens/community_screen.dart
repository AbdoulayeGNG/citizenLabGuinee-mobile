import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/team_member.dart';
import '../widgets/member_card.dart';
import 'member_detail_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  /// Détermine le nombre de colonnes en fonction de la largeur d'écran
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Petit écran mobile (< 400px) : 1 colonne
    if (width < 400) {
      return 1;
    }
    // Mobile large (400-600px) : 2 colonnes
    else if (width < 600) {
      return 2;
    }
    // Tablette (600-900px) : 2 colonnes
    else if (width < 900) {
      return 2;
    }
    // Desktop et grand écran : 3 colonnes
    else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final members = apiService.teamMembers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communauté'),
        centerTitle: false,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(child: _buildHeaderSection(context)),

          // Grid Members
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = _getCrossAxisCount(context);

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    // Hauteur dynamique pour les cards
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return MemberCard(
                      member: members[index],
                      onTap: () => _handleMemberTap(context, members[index]),
                    );
                  }, childCount: members.length),
                );
              },
            ),
          ),

          // Espacement bas
          const SliverSafeArea(
            top: false,
            sliver: SliverToBoxAdapter(child: SizedBox(height: 24)),
          ),
        ],
      ),
    );
  }

  /// Section header avec titre et description
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notre Équipe',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rencontrez les acteurs qui façonnent CitizenLab Guinée. '
            'Des profils engagés, passionnés et dédiés à l\'amélioration '
            'de la démocratie participative.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Action au tap sur une carte membre - Naviguer vers la page détail
  void _handleMemberTap(BuildContext context, TeamMember member) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberDetailScreen(member: member),
      ),
    );
  }
}
