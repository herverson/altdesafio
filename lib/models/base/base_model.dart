/// Base model abstrato para type safety com genéricos
abstract class BaseModel {
  String get id;
  String get name;

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
