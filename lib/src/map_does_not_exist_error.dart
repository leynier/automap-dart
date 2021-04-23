/// Thrown when trying to map between two type that have not had a map added.
class MapDoesNotExistError extends Error {
  /// Creates an instance of [MapDoesNotExistError].
  MapDoesNotExistError(this.destination, this.source);

  /// The type to map to.
  final Type destination;

  /// The type to map from.
  final Type source;

  @override
  String toString() => 'Map $source -> $destination does not exist';
}
