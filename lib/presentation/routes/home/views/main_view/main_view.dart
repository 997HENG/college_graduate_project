import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/authentication/authentication_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_router.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthenticationBloc>().state.user;

    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        title: const Text(
          "Main",
          style: TextStyle(
            fontWeight: FontWeight.w600, // 略粗字体
            fontSize: 20, // 字体大小
            color: Color.fromARGB(255, 114, 114, 114), // 标题颜色
          ),
        ),
        backgroundColor: Colors.amber[200], // 背景颜色
        centerTitle: true, // 标题居中
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Card(
                  color: Colors.amber[100],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(user.photoURL),
                          onBackgroundImageError: (_, __) =>
                              const Icon(Icons.person, size: 50),
                        ),
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'LV: 1',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'points: 0',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Mood Board',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 10, left: 10, bottom: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'What’s on your mind?',
                                  hintText: 'Share your thoughts...',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Forum',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(5.0),
                        children: [
                          _buildListItem('Coursework Forum', Icons.book),
                          _buildListItem('Teaching Forum', Icons.school),
                          _buildListItem(
                              'Casual Chat', Icons.emoji_people_outlined),
                          _buildListItem('Bug report', Icons.bug_report),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          onPressed: () => context.push(RoutePath.config),
          icon: const Icon(Icons.settings),
        ),
      ),
    );
  }
}

Widget _buildListItem(String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Container(
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle navigation or action
            },
            child: ListTile(
              leading: Icon(
                icon,
                color: Colors.grey[500],
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        )),
  );
}