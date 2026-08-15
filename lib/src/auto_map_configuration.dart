import 'package:automap/src/auto_mapper_model.dart';
import 'package:automap/src/exceptions.dart';

/// Configuration to auto map the [TSource] type to the [TTarget] type.
class AutoMapConfiguration<TSource extends AutoMapperModel, TTarget> {
  /// The expression that defines how to map the types.
  final TTarget Function(Map<String, dynamic>) expression;

  /// Creates an instance of [AutoMapConfiguration].
  const AutoMapConfiguration(this.expression);

  /// Maps the [source].
  TTarget map(TSource source) {
    try {
      return expression(source.toAutoJson());
    } on Object catch (e, stackTrace) {
      if (e is Error) rethrow;
      throw MapException(
        'The auto map expression for $TSource -> $TTarget threw: $e',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }
}
