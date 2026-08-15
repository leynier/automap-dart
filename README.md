# automap

[![pub](https://img.shields.io/pub/v/automap.svg)](https://pub.dev/packages/automap)
[![pub points](https://img.shields.io/pub/points/automap.svg)](https://pub.dev/packages/automap/score)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://pub.dev/packages/automap/license)
[![CI](https://github.com/leynier/automap-dart/actions/workflows/ci.yml/badge.svg)](https://github.com/leynier/automap-dart/actions/workflows/ci.yml)

A lightweight object mapper for Dart. It maps objects of different classes
automatically, through JSON serialization, or manually, through custom mapping
expressions.

## Installation

Add it to your `pubspec.yaml`:

```yaml
dependencies:
  automap: ^0.1.0
```

## Usage

### Auto map

Implement `AutoMapperModel` on the source type and register an expression
that builds the target from the serialized source:

```dart
import 'package:automap/automap.dart';

class AutoSource implements AutoMapperModel {
  const AutoSource(this.x);

  final int x;

  @override
  Map<String, dynamic> toAutoJson() => {'x': x};
}

class AutoTarget {
  const AutoTarget(this.x);

  final int x;

  static AutoTarget fromAutoJson(Map<String, dynamic> json) =>
      AutoTarget(json['x'] as int);
}

void main() {
  AutoMapper.I.addAutoMap<AutoSource, AutoTarget>(AutoTarget.fromAutoJson);
  final target = AutoMapper.I.map<AutoSource, AutoTarget>(const AutoSource(5));
  print(target.x); // 5
}
```

### Manual map

For full control, register a manual map expression:

```dart
class ManualSource {
  const ManualSource(this.x);

  final int x;
}

class ManualTarget {
  const ManualTarget(this.x);

  final int x;
}

void main() {
  AutoMapper.I.addManualMap<ManualSource, ManualTarget>(
    (source, mapper, params) => ManualTarget(source.x),
  );
  final target = AutoMapper.I.map<ManualSource, ManualTarget>(
    const ManualSource(5),
  );
  print(target.x); // 5
}
```

### Mapping parameters

Manual map expressions receive an optional `params` map:

```dart
AutoMapper.I.addManualMap<Person, PersonDto>(
  (source, mapper, params) => PersonDto(
    '${source.name} ${params['suffix']}',
    source.age + (params['bonus'] as int),
  ),
);

final dto = AutoMapper.I.map<Person, PersonDto>(
  const Person('Ada', 36),
  {'suffix': 'Lovelace', 'bonus': 1},
);
```

### Nested mapping

The expression also receives the calling [AutoMapper] instance, so child
members can be mapped with registered maps:

```dart
AutoMapper.I
  ..addAutoMap<Person, PersonDto>(PersonDto.fromAutoJson)
  ..addManualMap<Team, TeamDto>(
    (source, mapper, params) =>
        TeamDto(mapper.map<Person, PersonDto>(source.leader)),
  );

final teamDto = AutoMapper.I.map<Team, TeamDto>(const Team(Person('Ada', 36)));
```

## Error handling

Every exception thrown by this package extends the sealed
`AutoMapperException` class, so you can handle all failure modes exhaustively
with pattern matching:

```dart
try {
  final dto = AutoMapper.I.map<Person, PersonDto>(person);
} on AutoMapperException catch (e) {
  switch (e) {
    case MapException(:final cause, :final stackTrace):
      print('The mapping expression failed: $cause');
    case MapDoesNotExistException(:final source, :final destination):
      print('No map registered for $source -> $destination');
    case MapDuplicateException(:final source, :final destination):
      print('A map for $source -> $destination already exists');
  }
}
```

Note that exceptions thrown inside your own mapping expressions are wrapped
in a `MapException` that keeps the original cause and stack trace, while
programming errors (`Error` instances, such as type errors) propagate
untouched so bugs are never masked.

## Limitations

This package does not use reflection or code generation. Automatic mapping
works through the `AutoMapperModel` contract (`toAutoJson` plus a
constructor-like expression), so mapping always goes through an intermediate
JSON-like map.

## License

[MIT](LICENSE)
