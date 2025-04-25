import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:yaumian_app/models/group.dart';
import 'package:yaumian_app/services/database_service.dart';

class GroupService {
  static const String groupBoxName = 'group_box';
  static const String invitationBoxName = 'invitation_box';
  static const String userGroupBoxName = 'user_group_box';

  static Future<void> initializeGroupBoxes() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(GroupAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(GroupAmalanAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(GroupMemberProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(GroupInvitationAdapter());
    }

    // Open boxes
    await Hive.openBox<Group>(groupBoxName);
    await Hive.openBox<GroupInvitation>(invitationBoxName);
    await Hive.openBox(
      userGroupBoxName,
    ); // Changed to regular box to store List<String>
  }

  // Group CRUD operations
  static Future<Group> createGroup({
    required String name,
    required String description,
    required String creatorId,
  }) async {
    final group = Group.create(
      name: name,
      description: description,
      creatorId: creatorId,
    );

    final box = Hive.box<Group>(groupBoxName);
    await box.put(group.id, group);

    // Add group to user's groups
    await addGroupToUser(creatorId, group.id);

    return group;
  }

  static Future<void> updateGroup(Group group) async {
    final box = Hive.box<Group>(groupBoxName);
    await box.put(group.id, group);
  }

  static Future<void> deleteGroup(String groupId) async {
    final box = Hive.box<Group>(groupBoxName);
    final group = box.get(groupId);

    if (group != null) {
      // Remove group from all members' lists
      for (final memberId in group.memberIds) {
        await removeGroupFromUser(memberId, groupId);
      }

      // Delete all pending invitations for this group
      final invitationBox = Hive.box<GroupInvitation>(invitationBoxName);
      final invitations =
          invitationBox.values.where((inv) => inv.groupId == groupId).toList();
      for (final invitation in invitations) {
        await invitationBox.delete(invitation.id);
      }

      // Delete the group
      await box.delete(groupId);
    }
  }

  static Group? getGroup(String groupId) {
    final box = Hive.box<Group>(groupBoxName);
    return box.get(groupId);
  }

  static List<Group> getAllGroups() {
    final box = Hive.box<Group>(groupBoxName);
    return box.values.toList();
  }

  static List<Group> getUserGroups(String userId) {
    final userGroupBox = Hive.box(userGroupBoxName);
    final groupIds =
        (userGroupBox.get(userId) as List?)?.cast<String>() ?? <String>[];

    final groupBox = Hive.box<Group>(groupBoxName);
    return groupIds.map((id) => groupBox.get(id)).whereType<Group>().toList();
  }

  // Group membership operations
  static Future<void> addMemberToGroup(String groupId, String userId) async {
    final box = Hive.box<Group>(groupBoxName);
    final group = box.get(groupId);

    if (group != null) {
      group.addMember(userId);
      await box.put(groupId, group);

      // Add group to user's groups
      await addGroupToUser(userId, groupId);
    }
  }

  static Future<void> removeMemberFromGroup(
    String groupId,
    String userId,
  ) async {
    final box = Hive.box<Group>(groupBoxName);
    final group = box.get(groupId);

    if (group != null) {
      group.removeMember(userId);
      await box.put(groupId, group);

      // Remove group from user's groups
      await removeGroupFromUser(userId, groupId);
    }
  }

  static Future<void> addGroupToUser(String userId, String groupId) async {
    final userGroupBox = Hive.box(userGroupBoxName);
    final groupIds =
        (userGroupBox.get(userId) as List?)?.cast<String>() ?? <String>[];

    if (!groupIds.contains(groupId)) {
      groupIds.add(groupId);
      await userGroupBox.put(userId, groupIds);
    }
  }

  static Future<void> removeGroupFromUser(String userId, String groupId) async {
    final userGroupBox = Hive.box(userGroupBoxName);
    final groupIds =
        (userGroupBox.get(userId) as List?)?.cast<String>() ?? <String>[];

    if (groupIds.contains(groupId)) {
      groupIds.remove(groupId);
      await userGroupBox.put(userId, groupIds);
    }
  }

  // Group invitation operations
  static Future<GroupInvitation> createInvitation({
    required String groupId,
    required String groupName,
    required String inviterName,
    required String inviteeEmail,
  }) async {
    final invitation = GroupInvitation(
      id: const Uuid().v4(),
      groupId: groupId,
      groupName: groupName,
      inviterName: inviterName,
      inviteeEmail: inviteeEmail,
      createdAt: DateTime.now(),
    );

    final box = Hive.box<GroupInvitation>(invitationBoxName);
    await box.put(invitation.id, invitation);

    // Add pending invite to group
    final groupBox = Hive.box<Group>(groupBoxName);
    final group = groupBox.get(groupId);
    if (group != null) {
      group.addPendingInvite(inviteeEmail);
      await groupBox.put(groupId, group);
    }

    return invitation;
  }

  static Future<void> acceptInvitation(
    String invitationId,
    String userId,
  ) async {
    final box = Hive.box<GroupInvitation>(invitationBoxName);
    final invitation = box.get(invitationId);

    if (invitation != null) {
      invitation.accepted = true;
      await box.put(invitationId, invitation);

      // Add user to group
      await addMemberToGroup(invitation.groupId, userId);

      // Remove from pending invites
      final groupBox = Hive.box<Group>(groupBoxName);
      final group = groupBox.get(invitation.groupId);
      if (group != null) {
        group.removePendingInvite(invitation.inviteeEmail);
        await groupBox.put(invitation.groupId, group);
      }
    }
  }

  static Future<void> rejectInvitation(String invitationId) async {
    final box = Hive.box<GroupInvitation>(invitationBoxName);
    final invitation = box.get(invitationId);

    if (invitation != null) {
      // Remove from pending invites
      final groupBox = Hive.box<Group>(groupBoxName);
      final group = groupBox.get(invitation.groupId);
      if (group != null) {
        group.removePendingInvite(invitation.inviteeEmail);
        await groupBox.put(invitation.groupId, group);
      }

      // Delete invitation
      await box.delete(invitationId);
    }
  }

  static List<GroupInvitation> getUserInvitations(String email) {
    final box = Hive.box<GroupInvitation>(invitationBoxName);
    return box.values
        .where((inv) => inv.inviteeEmail == email && !inv.accepted)
        .toList();
  }

  // Group amalan operations
  static Future<void> addGroupAmalan({
    required String groupId,
    required String name,
    required String description,
    required String category,
  }) async {
    final box = Hive.box<Group>(groupBoxName);
    final group = box.get(groupId);

    if (group != null) {
      final amalan = GroupAmalan.create(
        name: name,
        description: description,
        category: category,
      );

      group.addGroupAmalan(amalan);
      await box.put(groupId, group);
    }
  }

  static Future<void> removeGroupAmalan(String groupId, String amalanId) async {
    final box = Hive.box<Group>(groupBoxName);
    final group = box.get(groupId);

    if (group != null) {
      group.removeGroupAmalan(amalanId);
      await box.put(groupId, group);
    }
  }

  static Future<void> updateGroupAmalanProgress({
    required String groupId,
    required String amalanId,
    required String userId,
    required bool completed,
  }) async {
    final box = Hive.box<Group>(groupBoxName);
    final group = box.get(groupId);

    if (group != null) {
      final amalanIndex = group.groupAmalans.indexWhere(
        (a) => a.id == amalanId,
      );
      if (amalanIndex != -1) {
        group.groupAmalans[amalanIndex].updateMemberProgress(userId, completed);
        await box.put(groupId, group);
      }
    }
  }

  // Join group by access code
  static Future<Group?> joinGroupByAccessCode(
    String accessCode,
    String userId,
  ) async {
    final box = Hive.box<Group>(groupBoxName);
    final groups =
        box.values.where((group) => group.accessCode == accessCode).toList();

    if (groups.isNotEmpty) {
      final group = groups.first;
      if (!group.isMember(userId)) {
        group.addMember(userId);
        await box.put(group.id, group);
        await addGroupToUser(userId, group.id);
      }
      return group;
    }
    return null;
  }
}
