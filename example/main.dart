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

class ManualSource {
  const ManualSource(this.x);

  final int x;
}

class ManualTarget {
  const ManualTarget(this.x);

  final int x;
}

void main() {
  AutoMapper.I
    ..addAutoMap<AutoSource, AutoTarget>(
      AutoTarget.fromAutoJson,
    )
    ..addManualMap<AutoTarget, AutoSource>(
      (source, mapper, params) => AutoSource(source.x),
    )
    ..addManualMap<ManualSource, ManualTarget>(
      (source, mapper, params) => ManualTarget(source.x),
    );
  final autoSource = const AutoSource(5);
  final manualSource = const ManualSource(5);
  final autoTarget = AutoMapper.I.map<AutoSource, AutoTarget>(
    autoSource,
  );
  final secondAutoSource = AutoMapper.I.map<AutoTarget, AutoSource>(
    autoTarget,
  );
  final manualTarget = AutoMapper.I.map<ManualSource, ManualTarget>(
    manualSource,
  );
  print('${autoTarget.x}, ${secondAutoSource.x}, ${manualTarget.x}');
}
