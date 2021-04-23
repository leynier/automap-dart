import 'package:automapper/automapper.dart';
import 'package:automapper/src/map_exception.dart';
import 'package:automapper/src/map_expression.dart';

/// Configuration to manual map the [TSource] type to the [TTarget] type.
class ManualMapConfiguration<TSource, TTarget> {
  /// The expresion that defines how to map the types.
  final MapExpression<TSource, TTarget> expression;

  /// Creates an instance of [ManualMapConfiguration].
  const ManualMapConfiguration(this.expression);

  /// Maps the [source].
  ///
  /// Provides the calling [mapper] so child members can be mapped as well.
  ///
  /// If needed, additional parameters can be passed to [params].
  TTarget map(TSource source, AutoMapper mapper, Map params) {
    try {
      return expression(source, mapper, params);
    } catch (exception) {
      throw MapException(exception);
    }
  }
}
