import 'package:flutter_test/flutter_test.dart';
import 'package:rdb/core/version_update/version_update.dart';

void main() {
  group('VersionUpdate.decide', () {
    final cases = <(int, int?, UpdateKind)>[
      (150, null, UpdateKind.none),
      (150, 150, UpdateKind.none),
      (150, 120, UpdateKind.none),
      (150, 151, UpdateKind.optional),
      (150, 199, UpdateKind.optional),
      (55, 76, UpdateKind.optional),
      (150, 200, UpdateKind.mandatory),
      (55, 120, UpdateKind.mandatory),
      (250, 300, UpdateKind.mandatory),
      (100, 301, UpdateKind.mandatory),
    ];

    for (final (current, min, expected) in cases) {
      test('current $current, min $min -> $expected', () {
        expect(
          VersionUpdate.decide(current: current, minVersion: min),
          expected,
        );
      });
    }

    test('current == min -> none', () {
      expect(VersionUpdate.decide(current: 30, minVersion: 30), UpdateKind.none);
    });
  });

  group('VersionUpdate.readMinVersion', () {
    Map<String, dynamic> body({Object? android, Object? ios}) => {
      'isSuccessful': true,
      'hasContent': true,
      'code': 200,
      'message': '',
      'detailed_error': null,
      'data': {
        'starting-setting': {
          'android_min_version': android,
          'ios_min_version': ios,
          'languages': [],
        },
      },
    };

    test('reads the field of the requested platform', () {
      final b = body(android: 140, ios: 160);
      expect(VersionUpdate.readMinVersion(b, isIOS: false), 140);
      expect(VersionUpdate.readMinVersion(b, isIOS: true), 160);
    });

    test('accepts int, double and numeric String', () {
      for (final raw in <Object>[150, 150.0, '150', ' 150 ']) {
        expect(
          VersionUpdate.readMinVersion(body(android: raw), isIOS: false),
          150,
          reason: 'raw: $raw (${raw.runtimeType})',
        );
      }
    });

    test('non-numeric or null value -> null', () {
      expect(
        VersionUpdate.readMinVersion(body(android: 'abc'), isIOS: false),
        isNull,
      );
      expect(
        VersionUpdate.readMinVersion(body(android: null), isIOS: false),
        isNull,
      );
      expect(
        VersionUpdate.readMinVersion(body(android: true), isIOS: false),
        isNull,
      );
    });

    test('missing data or starting-setting -> null', () {
      expect(
        VersionUpdate.readMinVersion({'isSuccessful': true}, isIOS: false),
        isNull,
      );
      expect(
        VersionUpdate.readMinVersion({
          'isSuccessful': true,
          'data': <String, dynamic>{},
        }, isIOS: false),
        isNull,
      );
      expect(
        VersionUpdate.readMinVersion({
          'data': {'starting_setting': {'android_min_version': 150}},
        }, isIOS: false),
        isNull,
      );
    });

    test('body that is not a Map -> null', () {
      expect(VersionUpdate.readMinVersion(null, isIOS: false), isNull);
      expect(VersionUpdate.readMinVersion('{}', isIOS: false), isNull);
      expect(VersionUpdate.readMinVersion([1, 2], isIOS: true), isNull);
    });

    test('isSuccessful: false -> null', () {
      final b = body(android: 150, ios: 150)..['isSuccessful'] = false;
      expect(VersionUpdate.readMinVersion(b, isIOS: false), isNull);
      expect(VersionUpdate.readMinVersion(b, isIOS: true), isNull);
    });
  });
}
