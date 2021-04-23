import 'package:automap/src/auto_mapper.dart';

/// An expression that defines how to map the [TTarget] type to the
/// [TSource] type.
///
/// The calling [mapper] can be used to map child members.
///
/// If additional parameters can be passed as a [Map] to [params] if needed.
typedef MapExpression<TSource, TTarget> = TTarget Function(
  TSource source,
  AutoMapper mapper,
  Map params,
);
