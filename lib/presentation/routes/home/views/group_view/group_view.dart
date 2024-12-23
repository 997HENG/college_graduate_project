import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_app/blocs/group/group_bloc.dart';
import 'package:tutor_app/presentation/routes/router/app_router.dart';

class GroupView extends StatefulWidget {
  const GroupView({super.key});

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  final TextEditingController _groupCodeController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupCodeController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupBloc()..add(GroupLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.amber[50],
        appBar: AppBar(
          title: const Text(
            "Group",
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 20, 
              color: Color.fromARGB(255, 119, 118, 118), 
            ),
          ),
          backgroundColor: Colors.amber[200],
          centerTitle: true, 
        ),
        body: BlocBuilder<GroupBloc, GroupState>(
          builder: (context, state) {
            if (state is GroupLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GroupError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            } else if (state is GroupLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group Join/Create Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputCard(
                            title: 'Join Group',
                            hintText: 'Enter the group code',
                            controller: _groupCodeController,
                            buttonText: 'Join',
                            onPressed: () {
                              BlocProvider.of<GroupBloc>(context).add(
                                GroupJoinRequested(_groupCodeController.text),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputCard(
                            title: 'Create Group',
                            hintText: 'Enter a new group name',
                            controller: _groupNameController,
                            buttonText: 'Create',
                            onPressed: () {
                              BlocProvider.of<GroupBloc>(context).add(
                                GroupCreateRequested(_groupNameController.text),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "My group",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Group List Section
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.groups.length,
                        itemBuilder: (context, index) {
                          final group = state.groups[index];
                          return Card(
                            color: Colors.amber[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 4.0,
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.group,
                                color: Colors.amber[100],
                              ),
                              title: Text(
                                group.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 119, 118, 118), 
                                ),
                              ),
                              trailing: GroupCodeButton(
                                groupId: group.id,
                                onPressed: (groupId) {
                                  _showGroupCodeDialog(context, groupId);
                                },
                              ),
                              onTap: () {
                                context.push(
                                  RoutePath.groupChat,
                                  extra: {'group': group},
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: Colors.amber[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 119, 118, 118), 
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupCodeDialog(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("群組代碼"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "群組代碼: $groupId",
                style: const TextStyle(fontSize: 16),
                
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[400],
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: groupId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("群組代碼已複製")),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text("複製代碼"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GroupCodeButton extends StatelessWidget {
  final String groupId;
  final Function(String groupId) onPressed;

  const GroupCodeButton({
    super.key,
    required this.groupId,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => onPressed(groupId),
    );
  }
}