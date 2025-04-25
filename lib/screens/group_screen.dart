import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/providers/group_provider.dart';
import 'package:yaumian_app/screens/group_detail_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _accessCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Inisialisasi data grup dan undangan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      // Untuk demo, kita gunakan ID dan email statis
      // Pada implementasi sebenarnya, ini akan diambil dari autentikasi pengguna
      groupProvider.initialize('user123', 'user@example.com', 'Pengguna');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Buat Grup Amalan Baru'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Grup'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama grup tidak boleh kosong';
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
                    await groupProvider.createGroup(
                      nameController.text,
                      descriptionController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Buat'),
              ),
            ],
          ),
    );
  }

  void _showJoinGroupDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Gabung Grup Amalan'),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _accessCodeController,
                decoration: const InputDecoration(labelText: 'Kode Akses Grup'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode akses tidak boleh kosong';
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
                    setState(() {
                      _isLoading = true;
                    });

                    final groupProvider = Provider.of<GroupProvider>(
                      context,
                      listen: false,
                    );
                    final success = await groupProvider.joinGroupByAccessCode(
                      _accessCodeController.text,
                    );

                    setState(() {
                      _isLoading = false;
                    });

                    Navigator.pop(context);

                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Grup tidak ditemukan atau kode akses salah',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Berhasil bergabung dengan grup'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Gabung'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grup Amalan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Grup Saya'), Tab(text: 'Undangan')],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'create') {
                _showCreateGroupDialog();
              } else if (value == 'join') {
                _showJoinGroupDialog();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'create',
                    child: Text('Buat Grup Baru'),
                  ),
                  const PopupMenuItem(
                    value: 'join',
                    child: Text('Gabung Grup'),
                  ),
                ],
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Tab Grup Saya
              _buildMyGroupsTab(groupProvider),

              // Tab Undangan
              _buildInvitationsTab(groupProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMyGroupsTab(GroupProvider groupProvider) {
    final groups = groupProvider.userGroups;

    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Anda belum memiliki grup amalan',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateGroupDialog,
              icon: const Icon(Icons.add),
              label: const Text('Buat Grup Baru'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showJoinGroupDialog,
              icon: const Icon(Icons.login),
              label: const Text('Gabung Grup'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              groupProvider.selectGroup(group.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GroupDetailScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.group, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (group.isCreator(groupProvider.userId))
                        const Chip(
                          label: Text('Admin'),
                          backgroundColor: Colors.blue,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(group.description),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${group.memberIds.length} anggota',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        'Kode: ${group.accessCode}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvitationsTab(GroupProvider groupProvider) {
    final invitations = groupProvider.userInvitations;

    if (invitations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada undangan grup',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final invitation = invitations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.groupName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Diundang oleh: ${invitation.inviterName}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await groupProvider.rejectInvitation(invitation.id);
                      },
                      child: const Text('Tolak'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await groupProvider.acceptInvitation(invitation.id);
                      },
                      child: const Text('Terima'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
