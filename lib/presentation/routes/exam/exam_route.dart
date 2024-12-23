import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/exam/exam_bloc.dart';
import 'package:tutor_app/presentation/routes/exam/views/student_exam_page.dart';
import 'package:tutor_app/presentation/routes/exam/views/teacher_exam_page.dart';

class ExamRoute extends StatelessWidget {
  final String groupId;
  const ExamRoute({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExamBloc(
        firestore: FirebaseFirestore.instance,
      ), // 初始化ExamBloc

      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .get()
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException('請求超時');
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            log("Firebase Error: ${snapshot.error}");
            return Center(child: Text('錯誤：${snapshot.error}'));
          }

          final group = snapshot.data;
          final createdId = group!['creatorId'];
          final currentUserId = FirebaseAuth.instance.currentUser!.uid;
          if (createdId == currentUserId) {
            return TeacherExamPage(groupId: groupId);
          } else {
            return StudentExamPage(groupId: groupId);
          }
        },
      ),
    );
  }
}
