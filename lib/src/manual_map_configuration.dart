import 'package:automap/src/auto_mapper.dart';
import 'package:automap/src/exceptions.dart';
import 'package:automap/src/map_expression.dart';

/// Configuration to manual map the [TSource] type to the [TTarget] type.
class ManualMapConfiguration<TSource, TTarget> {
  /// The expression that defines how to map the types.
  final MapExpression<TSource, TTarget> expression;

  /// Creates an instance of [ManualMapConfiguration].
  const ManualMapConfiguration(this.expression);

  /// Maps the [source].
  ///
  /// Provides the calling [mapper] so child members can be mapped as well.
  ///
  /// If needed, additional parameters can be passed to [params].
  TTarget map(TSource source, AutoMapper mapper, Map<String, dynamic> params) {
    try {
      return expression(source, mapper, params);
    } on Object catch (e, stackTrace) {
      if (e is Error) rethrow;
      throw MapException(
        'The manual map expression for $TSource -> $TTarget threw: $e',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }
}
