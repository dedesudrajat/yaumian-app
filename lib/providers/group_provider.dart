import 'package:flutter/foundation.dart';
import 'package:yaumian_app/models/group.dart';
import 'package:yaumian_app/services/group_service.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _userGroups = [];
  List<GroupInvitation> _userInvitations = [];
  Group? _selectedGroup;
  String _userId = ''; // Akan diisi dari user yang login
  String _userEmail = ''; // Email user yang login
  String _userName = 'Pengguna'; // Nama user yang login

  List<Group> get userGroups => _userGroups;
  List<GroupInvitation> get userInvitations => _userInvitations;
  Group? get selectedGroup => _selectedGroup;
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get userName => _userName;

  // Inisialisasi provider
  Future<void> initialize(
    String userId,
    String userEmail,
    String userName,
  ) async {
    _userId = userId;
    _userEmail = userEmail;
    _userName = userName;
    await loadUserGroups();
    await loadUserInvitations();
  }

  // Load grup yang dimiliki user
  Future<void> loadUserGroups() async {
    if (_userId.isEmpty) return;
    _userGroups = GroupService.getUserGroups(_userId);
    notifyListeners();
  }

  // Load undangan grup untuk user
  Future<void> loadUserInvitations() async {
    if (_userEmail.isEmpty) return;
    _userInvitations = GroupService.getUserInvitations(_userEmail);
    notifyListeners();
  }

  // Pilih grup yang aktif
  void selectGroup(String groupId) {
    _selectedGroup = _userGroups.firstWhere(
      (group) => group.id == groupId,
      orElse: () => null as Group,
    );
    notifyListeners();
  }

  // Buat grup baru
  Future<Group> createGroup(String name, String description) async {
    final group = await GroupService.createGroup(
      name: name,
      description: description,
      creatorId: _userId,
    );

    await loadUserGroups();
    _selectedGroup = group;
    return group;
  }

  // Update grup
  Future<void> updateGroup(Group group) async {
    await GroupService.updateGroup(group);
    await loadUserGroups();
    if (_selectedGroup?.id == group.id) {
      _selectedGroup = group;
    }
    notifyListeners();
  }

  // Hapus grup
  Future<void> deleteGroup(String groupId) async {
    await GroupService.deleteGroup(groupId);
    if (_selectedGroup?.id == groupId) {
      _selectedGroup = null;
    }
    await loadUserGroups();
  }

  // Tambah amalan ke grup
  Future<void> addGroupAmalan({
    required String name,
    required String description,
    required String category,
  }) async {
    if (_selectedGroup == null) return;

    await GroupService.addGroupAmalan(
      groupId: _selectedGroup!.id,
      name: name,
      description: description,
      category: category,
    );

    // Refresh selected group
    _selectedGroup = GroupService.getGroup(_selectedGroup!.id);
    await loadUserGroups();
  }

  // Hapus amalan dari grup
  Future<void> removeGroupAmalan(String amalanId) async {
    if (_selectedGroup == null) return;

    await GroupService.removeGroupAmalan(_selectedGroup!.id, amalanId);

    // Refresh selected group
    _selectedGroup = GroupService.getGroup(_selectedGroup!.id);
    await loadUserGroups();
  }

  // Update progress amalan grup
  Future<void> updateGroupAmalanProgress(
    String amalanId,
    bool completed,
  ) async {
    if (_selectedGroup == null) return;

    await GroupService.updateGroupAmalanProgress(
      groupId: _selectedGroup!.id,
      amalanId: amalanId,
      userId: _userId,
      completed: completed,
    );

    // Refresh selected group
    _selectedGroup = GroupService.getGroup(_selectedGroup!.id);
    await loadUserGroups();
  }

  // Kirim undangan ke grup
  Future<void> inviteToGroup(String email) async {
    if (_selectedGroup == null) return;

    await GroupService.createInvitation(
      groupId: _selectedGroup!.id,
      groupName: _selectedGroup!.name,
      inviterName: _userName,
      inviteeEmail: email,
    );

    // Refresh selected group
    _selectedGroup = GroupService.getGroup(_selectedGroup!.id);
    notifyListeners();
  }

  // Terima undangan grup
  Future<void> acceptInvitation(String invitationId) async {
    await GroupService.acceptInvitation(invitationId, _userId);
    await loadUserGroups();
    await loadUserInvitations();
  }

  // Tolak undangan grup
  Future<void> rejectInvitation(String invitationId) async {
    await GroupService.rejectInvitation(invitationId);
    await loadUserInvitations();
  }

  // Gabung grup dengan kode akses
  Future<bool> joinGroupByAccessCode(String accessCode) async {
    final group = await GroupService.joinGroupByAccessCode(accessCode, _userId);
    if (group != null) {
      await loadUserGroups();
      _selectedGroup = group;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Keluar dari grup
  Future<void> leaveGroup(String groupId) async {
    await GroupService.removeMemberFromGroup(groupId, _userId);
    if (_selectedGroup?.id == groupId) {
      _selectedGroup = null;
    }
    await loadUserGroups();
  }
}
