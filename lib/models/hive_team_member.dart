import 'package:hive/hive.dart';

// part 'hive_team_member.g.dart'; // Uncomment after running: flutter pub run build_runner build

// @HiveType(typeId: 2)
class HiveTeamMember {
  // @HiveField(0)
  final String id;

  // @HiveField(1)
  final String name;

  // @HiveField(2)
  final String? imageUrl;

  // @HiveField(3)
  final String? imageAlt;

  // @HiveField(4)
  final String? team;

  // @HiveField(5)
  final String? role;

  // @HiveField(6)
  final String? facebook;

  // @HiveField(7)
  final String? instagram;

  // @HiveField(8)
  final String? linkedin;

  // @HiveField(9)
  final String? twitter;

  // @HiveField(10)
  final DateTime cachedAt;

  HiveTeamMember({
    required this.id,
    required this.name,
    this.imageUrl,
    this.imageAlt,
    this.team,
    this.role,
    this.facebook,
    this.instagram,
    this.linkedin,
    this.twitter,
    required this.cachedAt,
  });

  /// Convert from TeamMember model to HiveTeamMember
  factory HiveTeamMember.fromTeamMember(dynamic member) {
    return HiveTeamMember(
      id: member.id ?? '',
      name: member.name ?? 'Sans nom',
      imageUrl: member.imageUrl,
      imageAlt: member.imageAlt,
      team: member.team,
      role: member.role,
      facebook: member.facebook,
      instagram: member.instagram,
      linkedin: member.linkedin,
      twitter: member.twitter,
      cachedAt: DateTime.now(),
    );
  }

  /// Convert HiveTeamMember back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'imageAlt': imageAlt,
      'team': team,
      'role': role,
      'facebook': facebook,
      'instagram': instagram,
      'linkedin': linkedin,
      'twitter': twitter,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  /// Create HiveTeamMember from JSON
  factory HiveTeamMember.fromJson(Map<String, dynamic> json) {
    return HiveTeamMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Sans nom',
      imageUrl: json['imageUrl'] as String?,
      imageAlt: json['imageAlt'] as String?,
      team: json['team'] as String?,
      role: json['role'] as String?,
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      linkedin: json['linkedin'] as String?,
      twitter: json['twitter'] as String?,
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'] as String)
          : DateTime.now(),
    );
  }
}

// Manual TypeAdapter for HiveTeamMember.
class HiveTeamMemberAdapter extends TypeAdapter<HiveTeamMember> {
  @override
  final int typeId = 2;

  @override
  HiveTeamMember read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.read() as Map);
    return HiveTeamMember.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, HiveTeamMember obj) {
    writer.write(obj.toJson());
  }
}
