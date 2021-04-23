/// Thrown when a duplicate map is added.
class MapDuplicateError extends Error {
  /// Creates an instance of [MapDuplicateError].
  MapDuplicateError(this.destination, this.source);

  /// The type to map to.
  final Type destination;

  /// The type to map from.
  final Type source;

  @override
  String toString() => 'Duplicate $source -> $destination map';
}
