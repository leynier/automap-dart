/// Interface for models that can be auto mapped.
abstract interface class AutoMapperModel {
  /// Creates an instance of [AutoMapperModel].
  const AutoMapperModel();

  /// Serializes this model into a JSON-like map so an auto map expression
  /// can build the target object from it.
  Map<String, dynamic> toAutoJson();
}
