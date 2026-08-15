# Changelog

## [0.1.0] - 2026-08-14

> Note: this release drops support for Dart 2 and contains breaking changes.

### Breaking changes

* Require Dart 3 (`sdk: ^3.0.0`).
* Rename `MapDoesNotExistError` to `MapDoesNotExistException` and
  `MapDuplicateError` to `MapDuplicateException`; every exception now extends
  the new sealed `AutoMapperException` base class.
* `AutoMapper` now has a private constructor: use the `AutoMapper.I`
  singleton, or `AutoMapper.reset()` to get a fresh instance.
* Manual map expressions now receive `Map<String, dynamic>` params instead of
  a raw `Map`.
* `MapException` now exposes `message`, `cause` and `stackTrace` fields.
* `AutoMapperModel` is now an `abstract interface class`.

### Features

* Add `AutoMapper.reset()` to replace the singleton instance, useful to
  isolate state between tests.
* Deprecate `addMap` in favor of `addAutoMap` (kept as a delegating alias).
* Wrap failures thrown by mapping expressions in `MapException`, preserving
  the original cause and stack trace; programming errors (`Error`) are no
  longer masked and propagate untouched.
* Validate the result of mapping expressions and throw a descriptive
  `MapException` instead of failing with an opaque cast error.
* Throw a descriptive `MapDoesNotExistException` when an auto map exists but
  the source does not implement `AutoMapperModel`.

### Maintenance

* Migrate from the discontinued `lint` package to `package:lints` with
  `strict-casts`, `strict-raw-types` and `strict-inference`.
* Add a full test suite and GitHub Actions CI and release workflows.
* Remove the stale Flutter `.metadata` artifact.

[0.1.0]: https://github.com/leynier/automap-dart/compare/v0.0.3...v0.1.0

## [0.0.3] - 2021-04-24

* Add lint style badge to README.md
* Update repository in pubspec.yaml

[0.0.3]: https://github.com/leynier/automap-dart/compare/v0.0.2...v0.0.3

## [0.0.2] - 2021-04-23

* Fix description

[0.0.2]: https://github.com/leynier/automap-dart/compare/v0.0.1...v0.0.2

## [0.0.1] - 2021-04-23

* Initial implementation

[0.0.1]: https://github.com/leynier/automap-dart/releases/tag/v0.0.1
