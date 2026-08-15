import 'package:automap/automap.dart';
import 'package:test/test.dart';

class Person implements AutoMapperModel {
  const Person(this.name, this.age);

  final String name;
  final int age;

  @override
  Map<String, dynamic> toAutoJson() => {'name': name, 'age': age};
}

class PersonDto {
  const PersonDto(this.name, this.age);

  factory PersonDto.fromAutoJson(Map<String, dynamic> json) => PersonDto(
        json['name'] as String,
        json['age'] as int,
      );

  final String name;
  final int age;
}

class Team {
  const Team(this.leader);

  final Person leader;
}

class TeamDto {
  const TeamDto(this.leader);

  final PersonDto leader;
}

class UnregisteredSource {
  const UnregisteredSource();
}

class UnregisteredTarget {
  const UnregisteredTarget();
}

class MyExpressionException implements Exception {
  const MyExpressionException(this.message);

  final String message;

  @override
  String toString() => 'MyExpressionException: $message';
}

void main() {
  setUp(AutoMapper.reset);

  group('registration', () {
    test('addAutoMap registers a usable auto map', () {
      AutoMapper.I.addAutoMap<Person, PersonDto>(PersonDto.fromAutoJson);
      expect(AutoMapper.I.hasAutoMap(PersonDto, Person), isTrue);
      expect(AutoMapper.I.hasMap(PersonDto, Person), isTrue);
      expect(AutoMapper.I.hasManualMap(PersonDto, Person), isFalse);
    });

    test('addManualMap registers a usable manual map', () {
      AutoMapper.I.addManualMap<Person, PersonDto>(
        (source, mapper, params) => PersonDto(source.name, source.age),
      );
      expect(AutoMapper.I.hasManualMap(PersonDto, Person), isTrue);
      expect(AutoMapper.I.hasAutoMap(PersonDto, Person), isFalse);
    });

    test('adding a duplicate auto map throws MapDuplicateException', () {
      AutoMapper.I.addAutoMap<Person, PersonDto>(PersonDto.fromAutoJson);
      expect(
        () =>
            AutoMapper.I.addAutoMap<Person, PersonDto>(PersonDto.fromAutoJson),
        throwsA(
          isA<MapDuplicateException>().having(
            (e) => e.toString(),
            'toString',
            contains('Duplicate'),
          ),
        ),
      );
    });

    test('mixing auto and manual maps throws MapDuplicateException', () {
      AutoMapper.I.addAutoMap<Person, PersonDto>(PersonDto.fromAutoJson);
      expect(
        () => AutoMapper.I.addManualMap<Person, PersonDto>(
          (source, mapper, params) => PersonDto(source.name, source.age),
        ),
        throwsA(isA<MapDuplicateException>()),
      );
    });

    test('deprecated addMap delegates to addAutoMap', () {
      // ignore: deprecated_member_use_from_same_package
      AutoMapper.I.addMap<Person, PersonDto>(PersonDto.fromAutoJson);
      expect(AutoMapper.I.hasAutoMap(PersonDto, Person), isTrue);
      final dto = AutoMapper.I.map<Person, PersonDto>(const Person('Ada', 36));
      expect(dto.name, 'Ada');
    });
  });

  group('map resolution', () {
    test('mapping without a registered map throws MapDoesNotExistException',
        () {
      expect(
        () => AutoMapper.I.map<UnregisteredSource, UnregisteredTarget>(
          const UnregisteredSource(),
        ),
        throwsA(
          isA<MapDoesNotExistException>().having(
            (e) => e.toString(),
            'toString',
            contains('does not exist'),
          ),
        ),
      );
    });

    test('autoMap without registration throws MapDoesNotExistException', () {
      expect(
        () => AutoMapper.I.autoMap<Person, PersonDto>(const Person('Ada', 36)),
        throwsA(isA<MapDoesNotExistException>()),
      );
    });

    test('manualMap without registration throws MapDoesNotExistException', () {
      expect(
        () => AutoMapper.I.manualMap<Person, PersonDto>(
          const Person('Ada', 36),
        ),
        throwsA(isA<MapDoesNotExistException>()),
      );
    });
  });

  group('auto map', () {
    test('maps end-to-end through toAutoJson and fromAutoJson', () {
      AutoMapper.I.addAutoMap<Person, PersonDto>(PersonDto.fromAutoJson);
      final dto = AutoMapper.I.map<Person, PersonDto>(const Person('Ada', 36));
      expect(dto.name, 'Ada');
      expect(dto.age, 36);
    });

    test('autoMap maps end-to-end', () {
      AutoMapper.I.addAutoMap<Person, PersonDto>(PersonDto.fromAutoJson);
      final dto = AutoMapper.I.autoMap<Person, PersonDto>(
        const Person('Grace', 45),
      );
      expect(dto.name, 'Grace');
      expect(dto.age, 45);
    });
  });

  group('manual map', () {
    test('maps end-to-end', () {
      AutoMapper.I.addManualMap<Person, PersonDto>(
        (source, mapper, params) => PersonDto(source.name, source.age),
      );
      final dto = AutoMapper.I.map<Person, PersonDto>(const Person('Ada', 36));
      expect(dto.name, 'Ada');
      expect(dto.age, 36);
      final manualDto = AutoMapper.I.manualMap<Person, PersonDto>(
        const Person('Grace', 45),
      );
      expect(manualDto.name, 'Grace');
      expect(manualDto.age, 45);
    });

    test('receives custom params', () {
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
      expect(dto.name, 'Ada Lovelace');
      expect(dto.age, 37);
    });

    test('maps nested members through the provided mapper', () {
      AutoMapper.I
        ..addAutoMap<Person, PersonDto>(PersonDto.fromAutoJson)
        ..addManualMap<Team, TeamDto>(
          (source, mapper, params) =>
              TeamDto(mapper.map<Person, PersonDto>(source.leader)),
        );
      final dto = AutoMapper.I.map<Team, TeamDto>(
        const Team(Person('Ada', 36)),
      );
      expect(dto.leader.name, 'Ada');
      expect(dto.leader.age, 36);
    });
  });

  group('error handling', () {
    test('wraps exceptions thrown by expressions in MapException', () {
      AutoMapper.I.addManualMap<Person, PersonDto>(
        (source, mapper, params) => throw const MyExpressionException('boom'),
      );
      MapException? exception;
      try {
        AutoMapper.I.map<Person, PersonDto>(const Person('Ada', 36));
        fail('Expected a MapException');
      } on MapException catch (e) {
        exception = e;
      }
      expect(exception.cause, isA<MyExpressionException>());
      expect(exception.stackTrace, isNotNull);
      expect(exception.toString(), startsWith('MapException: '));
      expect(exception.toString(), contains('boom'));
    });

    test('lets Error instances thrown by expressions propagate', () {
      final error = UnimplementedError('not yet');
      AutoMapper.I.addManualMap<Person, PersonDto>(
        (source, mapper, params) => throw error,
      );
      expect(
        () => AutoMapper.I.map<Person, PersonDto>(const Person('Ada', 36)),
        throwsA(same(error)),
      );
    });

    test('rejects wrong-typed results with a descriptive MapException', () {
      expect(
        () => AutoMapper.ensureTarget<Person, PersonDto>(42),
        throwsA(
          isA<MapException>()
              .having((e) => e.message, 'message', contains('int'))
              .having((e) => e.message, 'message', contains('PersonDto')),
        ),
      );
    });

    test('accepts correct-typed results in ensureTarget', () {
      const dto = PersonDto('Ada', 36);
      expect(AutoMapper.ensureTarget<Person, PersonDto>(dto), same(dto));
    });
  });

  group('reset', () {
    test('replaces the singleton with a fresh instance', () {
      AutoMapper.I.addAutoMap<Person, PersonDto>(PersonDto.fromAutoJson);
      expect(AutoMapper.I.hasAutoMap(PersonDto, Person), isTrue);
      AutoMapper.reset();
      expect(AutoMapper.I.hasAutoMap(PersonDto, Person), isFalse);
      expect(
        () => AutoMapper.I.map<Person, PersonDto>(const Person('Ada', 36)),
        throwsA(isA<MapDoesNotExistException>()),
      );
    });
  });
}
