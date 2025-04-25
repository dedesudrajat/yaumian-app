import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/models/group.dart';
import 'package:yaumian_app/providers/group_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({Key? key}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inviteEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inviteEmailController.dispose();
    super.dispose();
  }

  void _showAddAmalanDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = '1'; // Default category
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tambah Amalan Grup'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Amalan'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama amalan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('Ibadah Wajib')),
                      DropdownMenuItem(value: '2', child: Text('Sunnah')),
                      DropdownMenuItem(value: '3', child: Text('Dzikir')),
                      DropdownMenuItem(value: '4', child: Text('Membaca')),
                      DropdownMenuItem(value: '5', child: Text('Lainnya')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory = value;
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final groupProvider = Provider.of<GroupProvider>(
                      context,
                      listen: false,
                    );
                    await groupProvider.addGroupAmalan(
                      name: nameController.text,
                      description: descriptionController.text,
                      category: selectedCategory,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Tambah'),
              ),
            ],
          ),
    );
  }

  void _showInviteMemberDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Undang Anggota'),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _inviteEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final groupProvider = Provider.of<GroupProvider>(
                      context,
                      listen: false,
                    );
                    await groupProvider.inviteToGroup(
                      _inviteEmailController.text,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Undangan telah dikirim')),
                    );
                  }
                },
                child: const Text('Undang'),
              ),
            ],
          ),
    );
  }

  void _confirmLeaveGroup(
    BuildContext context,
    String groupId,
    String groupName,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Keluar dari Grup'),
            content: Text(
              'Apakah Anda yakin ingin keluar dari grup "$groupName"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  final groupProvider = Provider.of<GroupProvider>(
                    context,
                    listen: false,
                  );
                  await groupProvider.leaveGroup(groupId);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to group list
                },
                child: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case '1': // Ibadah Wajib
        return Colors.blue;
      case '2': // Ibadah Sunnah
        return Colors.green;
      case '3': // Dzikir
        return Colors.purple;
      case '4': // Membaca
        return Colors.orange;
      case '5': // Sedekah
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case '1':
        return 'Ibadah Wajib';
      case '2':
        return 'Sunnah';
      case '3':
        return 'Dzikir';
      case '4':
        return 'Membaca';
      case '5':
        return 'Lainnya';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final group = groupProvider.selectedGroup;

        if (group == null) {
          return const Scaffold(
            body: Center(child: Text('Grup tidak ditemukan')),
          );
        }

        final isAdmin = group.isCreator(groupProvider.userId);

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Amalan'),
                Tab(text: 'Anggota'),
                Tab(text: 'Info'),
              ],
            ),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: _showInviteMemberDialog,
                  tooltip: 'Undang Anggota',
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'leave') {
                    _confirmLeaveGroup(context, group.id, group.name);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'leave',
                        child: Text('Keluar dari Grup'),
                      ),
                    ],
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab Amalan
              _buildAmalanTab(group, groupProvider, isAdmin),

              // Tab Anggota
              _buildMembersTab(group, groupProvider, isAdmin),

              // Tab Info
              _buildInfoTab(group),
            ],
          ),
          floatingActionButton:
              _tabController.index == 0 && isAdmin
                  ? FloatingActionButton(
                    onPressed: _showAddAmalanDialog,
                    child: const Icon(Icons.add),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildAmalanTab(
    Group group,
    GroupProvider groupProvider,
    bool isAdmin,
  ) {
    final amalans = group.groupAmalans;

    if (amalans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Belum ada amalan dalam grup ini',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (isAdmin) const SizedBox(height: 24),
            if (isAdmin)
              ElevatedButton.icon(
                onPressed: _showAddAmalanDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Amalan'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: amalans.length,
      itemBuilder: (context, index) {
        final amalan = amalans[index];
        final userProgress = amalan.memberProgress[groupProvider.userId];
        final isCompleted = userProgress?.completed ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(amalan.category),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCategoryName(amalan.category),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        amalan.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: isCompleted,
                      onChanged: (value) {
                        if (value != null) {
                          groupProvider.updateGroupAmalanProgress(
                            amalan.id,
                            value,
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(amalan.description),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: amalan.getCompletionRate(),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getCategoryColor(amalan.category),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(amalan.getCompletionRate() * 100).toStringAsFixed(0)}% anggota telah menyelesaikan',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembersTab(
    Group group,
    GroupProvider groupProvider,
    bool isAdmin,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount:
          group.memberIds.length + (group.pendingInvites.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // Header untuk undangan tertunda
        if (group.pendingInvites.isNotEmpty && index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Undangan Tertunda',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...group.pendingInvites.map(
                (email) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.email)),
                  title: Text(email),
                  subtitle: const Text('Menunggu konfirmasi'),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Anggota',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }

        // Adjust index for member list if we have pending invites section
        final memberIndex = group.pendingInvites.isNotEmpty ? index - 1 : index;
        final memberId = group.memberIds[memberIndex];
        final isCreator = group.creatorId == memberId;

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(
            memberId == groupProvider.userId ? 'Anda' : 'Anggota $memberId',
          ),
          subtitle: Text(isCreator ? 'Admin Grup' : 'Anggota'),
          trailing:
              isAdmin && !isCreator && memberId != groupProvider.userId
                  ? IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      // Konfirmasi hapus anggota
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Hapus Anggota'),
                              content: const Text(
                                'Apakah Anda yakin ingin menghapus anggota ini dari grup?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        final group = groupProvider.selectedGroup;
                        if (group != null) {
                          group.removeMember(memberId);
                          await groupProvider.updateGroup(group);
                        }
                      }
                    },
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildInfoTab(Group group) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Grup',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Nama Grup', group.name),
                  const SizedBox(height: 8),
                  _buildInfoRow('Deskripsi', group.description),
                  const SizedBox(height: 8),
                  _buildInfoRow('Kode Akses', group.accessCode),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Tanggal Dibuat',
                    '${group.createdAt.day}/${group.createdAt.month}/${group.createdAt.year}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Jumlah Anggota', '${group.memberIds.length}'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Jumlah Amalan',
                    '${group.groupAmalans.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cara Mengundang Anggota',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Bagikan kode akses grup kepada teman Anda:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.accessCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            // Copy to clipboard functionality would go here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kode akses disalin ke clipboard',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '2. Atau undang langsung melalui email:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showInviteMemberDialog,
                    icon: const Icon(Icons.email),
                    label: const Text('Undang via Email'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: TextStyle(color: Colors.grey[600])),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
