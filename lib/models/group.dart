import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'group.g.dart';

@HiveType(typeId: 5)
class Group extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String creatorId;

  @HiveField(4)
  String accessCode;

  @HiveField(5)
  List<String> memberIds;

  @HiveField(6)
  List<String> pendingInvites;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  List<GroupAmalan> groupAmalans;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.accessCode,
    this.memberIds = const [],
    this.pendingInvites = const [],
    required this.createdAt,
    this.groupAmalans = const [],
  });

  factory Group.create({
    required String name,
    required String description,
    required String creatorId,
  }) {
    final uuid = Uuid();
    // Generate a 6-digit access code
    final accessCode = (100000 + (uuid.v1().hashCode % 900000)).toString();

    return Group(
      id: uuid.v4(),
      name: name,
      description: description,
      creatorId: creatorId,
      accessCode: accessCode,
      memberIds: [creatorId],
      pendingInvites: [],
      createdAt: DateTime.now(),
      groupAmalans: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'accessCode': accessCode,
      'memberIds': memberIds,
      'pendingInvites': pendingInvites,
      'createdAt': createdAt.toIso8601String(),
      'groupAmalans': groupAmalans.map((amalan) => amalan.toMap()).toList(),
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      creatorId: map['creatorId'] as String,
      accessCode: map['accessCode'] as String,
      memberIds: List<String>.from(map['memberIds'] as List),
      pendingInvites: List<String>.from(map['pendingInvites'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
      groupAmalans: (map['groupAmalans'] as List)
          .map((amalan) => GroupAmalan.fromMap(amalan as Map<String, dynamic>))
          .toList(),
    );
  }

  bool isMember(String userId) {
    return memberIds.contains(userId);
  }

  bool isCreator(String userId) {
    return creatorId == userId;
  }

  bool hasPendingInvite(String email) {
    return pendingInvites.contains(email);
  }

  void addMember(String userId) {
    if (!memberIds.contains(userId)) {
      memberIds.add(userId);
    }
  }

  void removeMember(String userId) {
    memberIds.remove(userId);
  }

  void addPendingInvite(String email) {
    if (!pendingInvites.contains(email)) {
      pendingInvites.add(email);
    }
  }

  void removePendingInvite(String email) {
    pendingInvites.remove(email);
  }

  void addGroupAmalan(GroupAmalan amalan) {
    groupAmalans.add(amalan);
  }

  void removeGroupAmalan(String amalanId) {
    groupAmalans.removeWhere((amalan) => amalan.id == amalanId);
  }
}

@HiveType(typeId: 6)
class GroupAmalan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  Map<String, GroupMemberProgress> memberProgress;

  GroupAmalan({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.createdAt,
    this.memberProgress = const {},
  });

  factory GroupAmalan.create({
    required String name,
    required String description,
    required String category,
  }) {
    return GroupAmalan(
      id: const Uuid().v4(),
      name: name,
      description: description,
      category: category,
      createdAt: DateTime.now(),
      memberProgress: {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'memberProgress': memberProgress.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }

  factory GroupAmalan.fromMap(Map<String, dynamic> map) {
    return GroupAmalan(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      memberProgress: (map['memberProgress'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          GroupMemberProgress.fromMap(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  void updateMemberProgress(String userId, bool completed) {
    if (!memberProgress.containsKey(userId)) {
      memberProgress[userId] = GroupMemberProgress(
        userId: userId,
        completed: completed,
        lastUpdated: DateTime.now(),
      );
    } else {
      memberProgress[userId]!.completed = completed;
      memberProgress[userId]!.lastUpdated = DateTime.now();
    }
  }

  double getCompletionRate() {
    if (memberProgress.isEmpty) return 0.0;

    int completedCount = 0;
    for (var progress in memberProgress.values) {
      if (progress.completed) completedCount++;
    }

    return completedCount / memberProgress.length;
  }
}

@HiveType(typeId: 7)
class GroupMemberProgress {
  @HiveField(0)
  String userId;

  @HiveField(1)
  bool completed;

  @HiveField(2)
  DateTime lastUpdated;

  GroupMemberProgress({
    required this.userId,
    this.completed = false,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'completed': completed,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory GroupMemberProgress.fromMap(Map<String, dynamic> map) {
    return GroupMemberProgress(
      userId: map['userId'] as String,
      completed: map['completed'] as bool,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }
}

@HiveType(typeId: 8)
class GroupInvitation {
  @HiveField(0)
  String id;

  @HiveField(1)
  String groupId;

  @HiveField(2)
  String groupName;

  @HiveField(3)
  String inviterName;

  @HiveField(4)
  String inviteeEmail;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  bool accepted;

  GroupInvitation({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.inviterName,
    required this.inviteeEmail,
    required this.createdAt,
    this.accepted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'inviterName': inviterName,
      'inviteeEmail': inviteeEmail,
      'createdAt': createdAt.toIso8601String(),
      'accepted': accepted,
    };
  }

  factory GroupInvitation.fromMap(Map<String, dynamic> map) {
    return GroupInvitation(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      groupName: map['groupName'] as String,
      inviterName: map['inviterName'] as String,
      inviteeEmail: map['inviteeEmail'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      accepted: map['accepted'] as bool,
    );
  }
}
