# AutoMapper for Dart

[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

An auto mapper for Dart. It allows mapping objects of different classes automatically and manually using JSON serialization.

## Example

```dart
import 'package:automap/automap.dart';

class AutoSource implements AutoMapperModel {
  final int x;

  AutoSource(this.x);

  @override
  Map<String, dynamic> toAutoJson() => {'x': x};
}

class AutoTarget {
  final int x;

  AutoTarget(this.x);

  static AutoTarget fromAutoJson(Map<String, dynamic> json) =>
      AutoTarget(json['x'] as int);
}

class ManualSource {
  final int x;

  ManualSource(this.x);
}

class ManualTarget {
  final int x;

  ManualTarget(this.x);
}

void main() {
  AutoMapper.I
    ..addMap<AutoSource, AutoTarget>(
      AutoTarget.fromAutoJson,
    )
    ..addManualMap<AutoTarget, AutoSource>(
      (source, mapper, params) => AutoSource(source.x),
    )
    ..addManualMap<ManualSource, ManualTarget>(
      (source, mapper, params) => ManualTarget(source.x),
    );
  final autoSource = AutoSource(5);
  final manualSource = ManualSource(5);
  final autoTarget = AutoMapper.I.map<AutoSource, AutoTarget>(
    autoSource,
  );
  final secondAutoSource = AutoMapper.I.map<AutoTarget, AutoSource>(
    autoTarget,
  );
  final manualTarget = AutoMapper.I.map<ManualSource, ManualTarget>(
    manualSource,
  );
  // ignore: avoid_print
  print('${autoTarget.x}, ${secondAutoSource.x}, ${manualTarget.x}');
}
```
