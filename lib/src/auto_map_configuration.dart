import 'package:automapper/src/automapper_model.dart';
import 'package:automapper/src/map_exception.dart';

/// Configuration to auto map the [TSource] type to the [TTarget] type.
class AutoMapConfiguration<TSource extends AutoMapperModel, TTarget> {
  /// The expresion that defines how to map the types.
  final TTarget Function(Map<String, dynamic>) expression;

  /// Creates an instance of [AutoMapConfiguration].
  const AutoMapConfiguration(this.expression);

  /// Maps the [source].
  TTarget map(TSource source) {
    try {
      return expression(source.toAutoJson());
    } catch (e) {
      throw MapException(e);
    }
  }
}
