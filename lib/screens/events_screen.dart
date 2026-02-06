import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  // Mock events data
  final List<MockEvent> mockEvents = const [
    MockEvent(
      id: '1',
      title: 'Conférence sur la Démocratie',
      date: '15 février 2026',
      location: 'Centre Culturel de Conakry',
      description:
          'Une conférence interactive sur les principes de la démocratie et la participation citoyenne. Des experts partageront leurs perspectives sur le renforcement des institutions démocratiques en Guinée.',
      image: 'assets/images/events/event1.jpg',
      startTime: '10:00',
      endTime: '12:00',
    ),
    MockEvent(
      id: '2',
      title: 'Atelier de Formation Civique',
      date: '17 février 2026',
      location: 'Université de Conakry',
      description:
          'Un atelier pratique pour apprendre les droits et responsabilités des citoyens. Participation active et discussions de groupe sur les enjeux locaux.',
      image: 'assets/images/events/event2.jpg',
      startTime: '14:00',
      endTime: '16:30',
    ),
    MockEvent(
      id: '3',
      title: 'Table Ronde: Transparence Gouvernementale',
      date: '20 février 2026',
      location: 'Mairie de Conakry',
      description:
          'Une discussion avec des responsables gouvernementaux sur l\'importance de la transparence et de la responsabilité dans la gestion publique.',
      image: 'assets/images/events/event3.jpg',
      startTime: '09:00',
      endTime: '11:00',
    ),
    MockEvent(
      id: '4',
      title: 'Marche pour le Droit à l\'Éducation',
      date: '22 février 2026',
      location: 'Place du Centre',
      description:
          'Une manifestation pacifique pour sensibiliser à l\'importance de l\'éducation de qualité pour tous les enfants. Des discours, des chants et du divertissement.',
      image: 'assets/images/events/event4.jpg',
      startTime: '08:00',
      endTime: '11:00',
    ),
    MockEvent(
      id: '5',
      title: 'Débat Présidentiel Simulé',
      date: '24 février 2026',
      location: 'Amphithéâtre National',
      description:
          'Les jeunes citoyens simulent un débat présidentiel pour comprendre les enjeux politiques et développer leur esprit critique face aux propositions électorales.',
      image: 'assets/images/events/event5.jpg',
      startTime: '15:00',
      endTime: '17:00',
    ),
    MockEvent(
      id: '6',
      title: 'Exposition: Histoire de la Guinée',
      date: '26 février 2026',
      location: 'Musée National',
      description:
          'Une exposition interactive retraçant l\'histoire politique et sociale de la Guinée, de l\'indépendance à nos jours. Guidée par des historiens locaux.',
      image: 'assets/images/events/event6.jpg',
      startTime: '10:00',
      endTime: '18:00',
    ),
    MockEvent(
      id: '7',
      title: 'Séminaire: Lutte contre la Corruption',
      date: '28 février 2026',
      location: 'Hôtel Sheraton',
      description:
          'Un séminaire pour renforcer les capacités des citoyens et des fonctionnaires dans la lutte contre la corruption et la promotion de l\'intégrité.',
      image: 'assets/images/events/event7.jpg',
      startTime: '08:30',
      endTime: '12:30',
    ),
    MockEvent(
      id: '8',
      title: 'Fête de la Citoyenneté',
      date: '02 mars 2026',
      location: 'Parc du Souvenir',
      description:
          'Une grande fête célébrant la citoyenneté active. Activités pour les enfants, ateliers participatifs, musique et repas communautaire.',
      image: 'assets/images/events/event8.jpg',
      startTime: '12:00',
      endTime: '18:00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Événements'), elevation: 0),
      body: _buildEventsList(context),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    if (mockEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun événement à venir',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockEvents.length,
      itemBuilder: (context, index) {
        final event = mockEvents[index];
        return _buildEventCard(context, event);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, MockEvent event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image with padding
            Container(
              padding: const EdgeInsets.all(0),
              child: Image.asset(
                event.image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            // Event info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mock event model
class MockEvent {
  final String id;
  final String title;
  final String date;
  final String location;
  final String description;
  final String image;
  final String startTime;
  final String endTime;

  const MockEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.image,
    required this.startTime,
    required this.endTime,
  });
}

// Event Detail Screen
class EventDetailScreen extends StatelessWidget {
  final MockEvent event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event.title),
              background: Image.asset(event.image, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Time
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Date',
                    event.date,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.access_time,
                    'Heure',
                    '${event.startTime} - ${event.endTime}',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.location_on,
                    'Lieu',
                    event.location,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Vous êtes inscrit à ${event.title}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('S\'inscrire'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Événement ${event.title} ajouté au calendrier',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Ajouter au calendrier'),
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

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
