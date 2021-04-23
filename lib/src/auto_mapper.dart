import 'package:automap/src/auto_map_configuration.dart';
import 'package:automap/src/auto_mapper_model.dart';
import 'package:automap/src/manual_map_configuration.dart';
import 'package:automap/src/map_does_not_exist_error.dart';
import 'package:automap/src/map_duplicate_error.dart';
import 'package:automap/src/map_expression.dart';

/// Handles mapping between different types.
class AutoMapper {
  static final _instance = AutoMapper();
  static AutoMapper get I => _instance;

  final _autoMaps = <Type, Map<Type, AutoMapConfiguration>>{};
  final _manualMaps = <Type, Map<Type, ManualMapConfiguration>>{};

  /// Checks if the mapper has a map for the [destination] and [source] types.
  bool hasMap(Type destination, Type source) =>
      hasAutoMap(destination, source) || hasManualMap(destination, source);

  /// Checks if the mapper has an auto map for the [destination] and [source] types.
  bool hasAutoMap(Type destination, Type source) =>
      _autoMaps.containsKey(destination) &&
      _autoMaps[destination]!.containsKey(source) &&
      _autoMaps[destination]![source] != null;

  /// Checks if the mapper has a manual map for the [destination] and [source] types.
  bool hasManualMap(Type destination, Type source) =>
      _manualMaps.containsKey(destination) &&
      _manualMaps[destination]!.containsKey(source) &&
      _manualMaps[destination]![source] != null;

  /// Adds a function that defines how to auto map from a [TSource] to a
  /// [TTarget] type.
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
      throw MapDuplicateError(TTarget, TSource);
    }
    if (!_autoMaps.containsKey(TTarget)) {
      _autoMaps[TTarget] = <Type, AutoMapConfiguration>{};
    }
    final conf = AutoMapConfiguration<TSource, TTarget>(expression);
    _autoMaps[TTarget]![TSource] = conf;
  }

  /// Adds an expression that defines how to manual map from a [TSource] to a
  /// [TTarget] type.
  void addManualMap<TSource, TTarget>(
    MapExpression<TSource, TTarget> expression,
  ) {
    if (hasMap(TTarget, TSource)) {
      throw MapDuplicateError(TTarget, TSource);
    }
    if (!_manualMaps.containsKey(TTarget)) {
      _manualMaps[TTarget] = <Type, ManualMapConfiguration<TSource, TTarget>>{};
    }
    final conf = ManualMapConfiguration<TSource, TTarget>(expression);
    _manualMaps[TTarget]![TSource] = conf;
  }

  /// Maps the [source].
  TTarget map<TSource, TTarget>(
    TSource source, [
    Map params = const {},
  ]) {
    if (hasAutoMap(TTarget, TSource) && source is AutoMapperModel) {
      return _autoMaps[TTarget]![TSource]!.map(source) as TTarget;
    } else if (hasManualMap(TTarget, TSource)) {
      return _manualMaps[TTarget]![TSource]!.map(source, this, params)
          as TTarget;
    }
    throw MapDoesNotExistError(TTarget, TSource);
  }

  /// Maps the [source] with auto map.
  TTarget autoMap<TSource extends AutoMapperModel, TTarget>(TSource source) {
    if (hasAutoMap(TTarget, TSource)) {
      return _autoMaps[TTarget]![TSource]!.map(source) as TTarget;
    }
    throw MapDoesNotExistError(TTarget, TSource);
  }

  /// Maps the [source] with manual map.
  TTarget manualMap<TSource, TTarget>(
    TSource source, [
    Map params = const {},
  ]) {
    if (hasManualMap(TTarget, TSource)) {
      return _manualMaps[TTarget]![TSource]!.map(source, this, params)
          as TTarget;
    }
    throw MapDoesNotExistError(TTarget, TSource);
  }
}
