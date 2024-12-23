part of 'tab_bloc.dart';

@immutable
class TabState extends Equatable {
  const TabState.loading() : this._(status: "loading");
  const TabState.main() : this._(status: "main");
  const TabState.friends() : this._(status: "friends");
  const TabState.group() : this._(status: "group");
  const TabState.notifications() : this._(status: "notifications");

  const TabState._({required this.status});
  final String status;

  @override
  String toString() => status;

  @override
  List<Object?> get props => [status];

  Map<String, dynamic> toMap() {
    return {
      'status': status,
    };
  }

  factory TabState.fromMap(Map<String, dynamic> map) {
    return TabState._(
      status: map['status'] ?? "main",
    );
  }
}
