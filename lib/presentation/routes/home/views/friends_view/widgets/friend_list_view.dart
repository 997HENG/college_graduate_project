import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:tutor_app/blocs/friend/friend_bloc.dart';
import 'package:tutor_app/presentation/routes/home/views/friends_view/widgets/friend_list_tile.dart';

class FriendListView extends StatelessWidget {
  const FriendListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final state = context.watch<FriendBloc>().state;
      if (state.friends.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.man_2,
                color: Colors.black45,
                size: 40, // Adjust icon size as needed
              ),
              SizedBox(height: 16), // Add space between the icon and text
              Text(
                'Nothing here',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8), // Add space between title and subtitle
              Text(
                'You can search your friend by their name!',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (_, index) => FriendListTile(
            state.user,
            state.friends[index]!,
          ),
          itemCount: state.friends.length,
        ),
      );
    });
  }
}
