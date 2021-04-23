/// An exception caused by a mapping failure.
class MapException implements Exception {
  /// Creates a new [MapException].
  MapException([this.message]);

  /// Details why the exception occurred.
  final dynamic message;

  @override
  String toString() =>
      message == null ? 'AutoMapperException' : 'AutoMapperException: $message';
}
