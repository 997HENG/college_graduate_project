
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../blocs/friend/friend_bloc.dart';
import 'package:flutter/material.dart';

class FriendSearchView extends StatelessWidget {
  const FriendSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final results = context.select((FriendBloc bloc) => bloc.state.results);
        if (results.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_people,
                  color: Colors.black45,
                  size: 40, // Adjust icon size as needed
                ),
                SizedBox(height: 16), // Add space between the icon and text
                Text(
                  'Nothing Found',
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
            itemBuilder: (_, index) => Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(results[index]!
                      .photoURL), // Assuming photoURL is available
                  radius: 24, // Adjust radius as needed
                ),
                title: Text(
                  results[index]!.name,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    context.read<FriendBloc>().add(
                          FriendRequested(
                            results[index]!.uid,
                          ),
                        );
                  },
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            itemCount: results.length,
          ),
        );
      },
    );
  }
}

class FriendSearch extends SearchDelegate<String> {
  FriendSearch(this.blocContext) : super();
  BuildContext blocContext;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          blocContext.read<FriendBloc>().add(const FriendClearSearch());
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.pop();
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(
      child: Text('oops...something went wrong'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocProvider.value(
      value: blocContext.read<FriendBloc>(),
      child: Builder(
        builder: (context) {
          context.read<FriendBloc>().add(FriendSearched(query));

          return const FriendSearchView();
        },
      ),
    );
  }
}
