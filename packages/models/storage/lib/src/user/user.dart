import 'package:meta/meta.dart' show immutable;
import '../json_model.dart';

part 'constants.dart';

@immutable
class User implements JsonModel {
  @override
  Map<String, Object?> toJson() => toMap();

  @override
  factory User.fromJson(Map<String, Object?> json) => User(
        json[UserField.uid] as String,
        json[UserField.name] as String,
        json[UserField.photoURL] as String,
        List<String>.from(json[UserField.friends] as Iterable<Object?>),
      );

  static const empty = User('none', 'none', 'none', []);

  const User(this.uid, this.name, this.photoURL, this.friends);

  const User.fromFirebase({
    required this.uid,
    required this.name,
    required this.photoURL,
  }) : friends = const [];

  final String uid;
  final String name;
  final String photoURL;
  final List<String> friends;

  Map<String, dynamic> toMap() {
    return {
      UserField.uid: uid,
      UserField.name: name,
      UserField.photoURL: photoURL,
      UserField.friends: friends,
    };
  }
}
