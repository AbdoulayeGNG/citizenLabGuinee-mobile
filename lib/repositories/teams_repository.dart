import 'package:hive/hive.dart';
import '../models/hive_team_member.dart';
import '../models/team_member.dart';

class TeamsRepository {
  static const String _boxName = 'teamsBox';
  static const String _lastSyncKey = 'teams_last_sync';

  /// Get the teams box
  Box<HiveTeamMember> get _box => Hive.box<HiveTeamMember>(_boxName);

  /// Get metadata box for sync timestamps
  Box get _metadataBox => Hive.box('metadataBox');

  /// Get all team members from local cache
  Future<List<HiveTeamMember>> getAllTeamMembersFromCache() async {
    try {
      return _box.values.toList();
    } catch (e) {
      print('Erreur lors de la lecture des équipes du cache: $e');
      return [];
    }
  }

  /// Debug: return a preview of stored entries (key -> toJson())
  Future<Map<String, Map<String, dynamic>>> getPreview({int limit = 10}) async {
    final out = <String, Map<String, dynamic>>{};
    try {
      final keys = _box.keys.cast<dynamic>().take(limit);
      for (final k in keys) {
        final v = _box.get(k);
        if (v != null) out[k.toString()] = v.toJson();
      }
    } catch (e) {
      print('TeamsRepository.getPreview error: $e');
    }
    return out;
  }

  /// Save team members to local cache (Hive only)
  Future<void> saveTeamMembers(List<TeamMember> members) async {
    try {
      await _box.clear();
      final hiveMembers = members
          .map((member) => HiveTeamMember.fromTeamMember(member))
          .toList();

      for (int i = 0; i < hiveMembers.length; i++) {
        await _box.put(hiveMembers[i].id, hiveMembers[i]);
      }

      // Update last sync time
      await _metadataBox.put(_lastSyncKey, DateTime.now().toIso8601String());

      // Debug log
      print(
        'TeamsRepository: saved ${hiveMembers.length} team members to Hive',
      );
    } catch (e) {
      print('Erreur lors de la sauvegarde des équipes: $e');
    }
  }

  /// Save a single team member to cache (Hive only)
  Future<void> saveTeamMember(TeamMember member) async {
    try {
      final hiveMember = HiveTeamMember.fromTeamMember(member);
      await _box.put(member.id, hiveMember);

      // Debug log
      print('TeamsRepository: saved team member ${member.id} to Hive');
    } catch (e) {
      print('Erreur lors de la sauvegarde du membre: $e');
    }
  }

  /// Get a team member by ID from cache
  Future<HiveTeamMember?> getTeamMemberById(String memberId) async {
    try {
      return _box.get(memberId);
    } catch (e) {
      print('Erreur lors de la lecture du membre: $e');
      return null;
    }
  }

  /// Get team members by team name from cache
  Future<List<HiveTeamMember>> getTeamMembersByTeam(String team) async {
    try {
      final allMembers = _box.values.toList();
      return allMembers.where((member) => member.team == team).toList();
    } catch (e) {
      print('Erreur lors du filtrage des équipes: $e');
      return [];
    }
  }

  /// Search team members by name
  Future<List<HiveTeamMember>> searchTeamMembers(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final allMembers = _box.values.toList();

      return allMembers
          .where((member) => member.name.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche de membres: $e');
      return [];
    }
  }

  /// Clear all team members from cache
  Future<void> clearAllTeamMembers() async {
    try {
      await _box.clear();
      await _metadataBox.delete(_lastSyncKey);
    } catch (e) {
      print('Erreur lors du vidage du cache des équipes: $e');
    }
  }

  /// Get the last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final syncTimeStr = _metadataBox.get(_lastSyncKey) as String?;
      if (syncTimeStr != null) {
        return DateTime.parse(syncTimeStr);
      }
    } catch (e) {
      print('Erreur lors de la lecture du timestamp de synchro: $e');
    }
    return null;
  }

  /// Check if cache needs refresh (older than X minutes)
  Future<bool> needsRefresh({int minutesThreshold = 120}) async {
    try {
      final lastSync = await getLastSyncTime();
      if (lastSync == null) return true;

      final now = DateTime.now();
      final difference = now.difference(lastSync).inMinutes;
      return difference > minutesThreshold;
    } catch (e) {
      return true;
    }
  }
}
