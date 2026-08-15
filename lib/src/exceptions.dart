/// Exceptions thrown by the automap library.
library;

/// Base class for every exception thrown by AutoMapper.
///
/// Being a sealed class, consumers can exhaustively switch over all the
/// exception kinds without needing a default case:
///
/// ```dart
/// try {
///   final target = AutoMapper.I.map<Source, Target>(source);
/// } on AutoMapperException catch (e) {
///   switch (e) {
///     case MapException(:final cause):
///       print('Mapping expression failed: $cause');
///     case MapDoesNotExistException(:final source, :final destination):
///       print('No map registered for $source -> $destination');
///     case MapDuplicateException(:final source, :final destination):
///       print('A map for $source -> $destination already exists');
///   }
/// }
/// ```
sealed class AutoMapperException implements Exception {
  /// Creates an instance of [AutoMapperException].
  const AutoMapperException();
}

/// An exception caused by the failure of a mapping expression.
final class MapException extends AutoMapperException {
  /// Creates a new [MapException] with a descriptive [message], optionally
  /// wrapping the original [cause] and its [stackTrace].
  const MapException(this.message, {this.cause, this.stackTrace});

  /// A human readable description of the failure.
  final String message;

  /// The original exception that caused this one, if any.
  final Object? cause;

  /// The stack trace of the original [cause], if any.
  final StackTrace? stackTrace;

  @override
  String toString() => 'MapException: $message';
}

/// Thrown when trying to map between two types that have no registered map.
final class MapDoesNotExistException extends AutoMapperException {
  /// Creates an instance of [MapDoesNotExistException].
  const MapDoesNotExistException(this.destination, this.source, [this.message]);

  /// The type to map to.
  final Type destination;

  /// The type to map from.
  final Type source;

  /// An optional message with additional context about the failure.
  final String? message;

  @override
  String toString() => message ?? 'Map $source -> $destination does not exist';
}

/// Thrown when a duplicate map is added.
final class MapDuplicateException extends AutoMapperException {
  /// Creates an instance of [MapDuplicateException].
  const MapDuplicateException(this.destination, this.source);

  /// The type to map to.
  final Type destination;

  /// The type to map from.
  final Type source;

  @override
  String toString() => 'Duplicate $source -> $destination map';
}
