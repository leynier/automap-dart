import 'package:automap/src/auto_map_configuration.dart';
import 'package:automap/src/auto_mapper_model.dart';
import 'package:automap/src/exceptions.dart';
import 'package:automap/src/manual_map_configuration.dart';
import 'package:automap/src/map_expression.dart';

/// Handles mapping between different types.
///
/// Usage:
///
/// ```dart
/// AutoMapper.I.addAutoMap<Source, Target>(Target.fromAutoJson);
/// final target = AutoMapper.I.map<Source, Target>(source);
/// ```
class AutoMapper {
  /// The singleton instance of [AutoMapper].
  static AutoMapper I = AutoMapper._();

  AutoMapper._();

  final _autoMaps = <Type, Map<Type, AutoMapConfiguration<dynamic, dynamic>>>{};
  final _manualMaps =
      <Type, Map<Type, ManualMapConfiguration<dynamic, dynamic>>>{};

  /// Replaces the [AutoMapper.I] singleton with a fresh instance.
  ///
  /// Useful to isolate state between tests.
  static void reset() {
    I = AutoMapper._();
  }

  /// Checks if the mapper has a map for the [destination] and [source] types.
  bool hasMap(Type destination, Type source) =>
      hasAutoMap(destination, source) || hasManualMap(destination, source);

  /// Checks if the mapper has an auto map for the [destination] and [source]
  /// types.
  bool hasAutoMap(Type destination, Type source) =>
      _autoMaps[destination]?.containsKey(source) ?? false;

  /// Checks if the mapper has a manual map for the [destination] and [source]
  /// types.
  bool hasManualMap(Type destination, Type source) =>
      _manualMaps[destination]?.containsKey(source) ?? false;

  /// Adds a function that defines how to auto map from a [TSource] to a
  /// [TTarget] type.
  @Deprecated('Use addAutoMap instead')
  void addMap<TSource extends AutoMapperModel, TTarget>(
    TTarget Function(Map<String, dynamic>) expression,
  ) {
    addAutoMap<TSource, TTarget>(expression);
  }

  /// Adds a function that defines how to auto map from a [TSource] to a
  /// [TTarget] type.
  void addAutoMap<TSource extends AutoMapperModel, TTarget>(
    TTarget Function(Map<String, dynamic>) expression,
  ) {
    if (hasMap(TTarget, TSource)) {
      throw MapDuplicateException(TTarget, TSource);
    }
    (_autoMaps[TTarget] ??=
            <Type, AutoMapConfiguration<dynamic, dynamic>>{})[TSource] =
        AutoMapConfiguration<TSource, TTarget>(expression);
  }

  /// Adds an expression that defines how to manual map from a [TSource] to a
  /// [TTarget] type.
  void addManualMap<TSource, TTarget>(
    MapExpression<TSource, TTarget> expression,
  ) {
    if (hasMap(TTarget, TSource)) {
      throw MapDuplicateException(TTarget, TSource);
    }
    (_manualMaps[TTarget] ??=
            <Type, ManualMapConfiguration<dynamic, dynamic>>{})[TSource] =
        ManualMapConfiguration<TSource, TTarget>(expression);
  }

  /// Maps the [source] using the registered auto or manual map.
  ///
  /// If needed, additional parameters can be passed to [params], which are
  /// forwarded to manual map expressions.
  TTarget map<TSource, TTarget>(
    TSource source, [
    Map<String, dynamic> params = const {},
  ]) {
    final autoMap = _autoMaps[TTarget]?[TSource];
    if (autoMap != null) {
      if (source is! AutoMapperModel) {
        throw MapDoesNotExistException(
          TTarget,
          TSource,
          'An auto map for $TSource -> $TTarget exists, but $TSource does not '
          'implement AutoMapperModel, so it cannot be serialized. Register a '
          'manual map instead.',
        );
      }
      return ensureTarget<TSource, TTarget>(autoMap.map(source));
    }
    final manualMap = _manualMaps[TTarget]?[TSource];
    if (manualMap != null) {
      return ensureTarget<TSource, TTarget>(
        manualMap.map(source, this, params),
      );
    }
    throw MapDoesNotExistException(TTarget, TSource);
  }

  /// Maps the [source] with auto map.
  TTarget autoMap<TSource extends AutoMapperModel, TTarget>(TSource source) {
    final autoMap = _autoMaps[TTarget]?[TSource];
    if (autoMap == null) {
      throw MapDoesNotExistException(TTarget, TSource);
    }
    return ensureTarget<TSource, TTarget>(autoMap.map(source));
  }

  /// Maps the [source] with manual map.
  ///
  /// If needed, additional parameters can be passed to [params].
  TTarget manualMap<TSource, TTarget>(
    TSource source, [
    Map<String, dynamic> params = const {},
  ]) {
    final manualMap = _manualMaps[TTarget]?[TSource];
    if (manualMap == null) {
      throw MapDoesNotExistException(TTarget, TSource);
    }
    return ensureTarget<TSource, TTarget>(manualMap.map(source, this, params));
  }

  /// Ensures the [value] returned by a mapping expression for a
  /// [TSource] -> [TTarget] map is actually a [TTarget].
  ///
  /// Throws a [MapException] describing the mismatch otherwise. This is used
  /// by [map], [autoMap] and [manualMap] instead of blindly casting, and it is
  /// exposed so wrapper libraries can reuse the same validation.
  static TTarget ensureTarget<TSource, TTarget>(Object? value) {
    if (value is! TTarget) {
      throw MapException(
        'The mapping expression for $TSource -> $TTarget returned a value of '
        'type ${value.runtimeType}, which is not a $TTarget.',
      );
    }
    return value;
  }
}
