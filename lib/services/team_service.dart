import 'dart:async';
import '../models/team_member.dart';

class TeamService {
  // In production replace this with your GraphQL client request
  static Future<List<TeamMember>> fetchMembers({Duration? delay}) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 700));
    // Return mock data for now
    return TeamMember.mocks();
  }
}
