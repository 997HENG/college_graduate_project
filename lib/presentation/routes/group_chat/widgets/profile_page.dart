import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/authentication/authentication_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthenticationBloc>().state.status ==
            AuthenticationStatus.authenticated
        ? context.read<AuthenticationBloc>().state.user.uid
        : ''; // 獲取當前用戶ID
    return Scaffold(
      appBar: AppBar(title: const Text('修改名稱')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '新名稱'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = _nameController.text;
                try {
                  if (userId.isNotEmpty) {
                    FirebaseFirestore.instance
                        .collection('user')
                        .doc(userId)
                        .update({'name': newName});
                  }
                } catch (e) {
                  log(e.toString());
                }
              },
              child: const Text('更新名稱'),
            ),
            BlocListener<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                // if (state is AuthNameUpdated) {
                //   //顯示更新成功
                //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //     content: Text('名稱更新成功!'),
                //     backgroundColor: Colors.green,
                //   ));
                // } else if (state is AuthError) {
                //   //錯誤
                //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //     content: Text(state.message),
                //     backgroundColor: Colors.red,
                //   ));
                // }
              },
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}
