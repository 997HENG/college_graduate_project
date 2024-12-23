import 'json_model.dart';

class GenericJsonModel implements JsonModel {
  @override
  factory GenericJsonModel.fromJson(Map<String, Object?> json) =>
      GenericJsonModel(json);

  @override
  Map<String, Object?> toJson() => _field;

  @override
  String toString() => _field.toString();

  GenericJsonModel(this._field);

  final Map<String, Object?> _field;
}
