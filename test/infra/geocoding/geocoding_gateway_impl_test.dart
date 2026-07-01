import 'package:booklub/infra/geocoding/geocoding_gateway_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';

class _FakeGeocodingPlatform extends GeocodingPlatform {
  List<Location> locations = const <Location>[];
  List<Placemark> placemarks = const <Placemark>[];
  bool throwNoResultOnForward = false;
  String? lastForwardQuery;

  @override
  Future<void> setLocaleIdentifier(String localeIdentifier) async {}

  @override
  Future<List<Location>> locationFromAddress(String address) async {
    lastForwardQuery = address;
    if (throwNoResultOnForward) {
      throw const NoResultFoundException();
    }
    return locations;
  }

  @override
  Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    return placemarks;
  }
}

void main() {
  late _FakeGeocodingPlatform fake;

  setUp(() {
    fake = _FakeGeocodingPlatform();
    GeocodingPlatform.instance = fake;
  });

  group('searchByAddress', () {
    test('empty query returns empty list without hitting the platform', () async {
      final gateway = GeocodingGatewayImpl();
      final result = await gateway.searchByAddress(query: '');
      expect(result, isEmpty);
    });

    test('whitespace-only query returns empty list', () async {
      final gateway = GeocodingGatewayImpl();
      final result = await gateway.searchByAddress(query: '   ');
      expect(result, isEmpty);
    });

    test('valid query reverse-geocodes to a formatted address and maps coordinates', () async {
      fake.locations = <Location>[
        Location(
          latitude: -8.05,
          longitude: -34.90,
          timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        ),
      ];
      fake.placemarks = <Placemark>[
        const Placemark(
          street: 'Rua do Apolo',
          locality: 'Recife',
          administrativeArea: 'PE',
          country: 'Brasil',
        ),
      ];
      final gateway = GeocodingGatewayImpl();
      final result = await gateway.searchByAddress(query: 'Recife');
      expect(result, hasLength(1));
      expect(result.first.address, 'Rua do Apolo, Recife, PE, Brasil');
      expect(result.first.latitude, -8.05);
      expect(result.first.longitude, -34.90);
    });

    test('respects the limit argument', () async {
      fake.locations = <Location>[
        Location(latitude: 1, longitude: 1, timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
        Location(latitude: 2, longitude: 2, timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
        Location(latitude: 3, longitude: 3, timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
      ];
      final gateway = GeocodingGatewayImpl();
      final result = await gateway.searchByAddress(query: 'query', limit: 2);
      expect(result, hasLength(2));
    });

    test('trims the query before forwarding to the platform', () async {
      fake.locations = <Location>[
        Location(latitude: 1, longitude: 1, timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
      ];
      fake.placemarks = <Placemark>[
        const Placemark(locality: 'Olinda', country: 'Brasil'),
      ];
      final gateway = GeocodingGatewayImpl();
      await gateway.searchByAddress(query: '  Olinda  ');
      expect(fake.lastForwardQuery, 'Olinda');
    });

    test('NoResultFoundException is swallowed into an empty list', () async {
      fake.throwNoResultOnForward = true;
      final gateway = GeocodingGatewayImpl();
      final result = await gateway.searchByAddress(query: 'nowhere');
      expect(result, isEmpty);
    });
  });

  group('reverse', () {
    test('valid coordinates return a GeocodingResult with a composed address', () async {
      fake.placemarks = <Placemark>[
        const Placemark(
          street: 'Rua do Apolo',
          locality: 'Recife',
          administrativeArea: 'PE',
          country: 'Brasil',
        ),
      ];
      final gateway = GeocodingGatewayImpl();
      final result = await gateway.reverse(latitude: -8.05, longitude: -34.90);
      expect(result, isNotNull);
      expect(result!.address, isNotEmpty);
      expect(result.address, contains('Recife'));
      expect(result.latitude, -8.05);
      expect(result.longitude, -34.90);
    });

    test('empty placemark list returns null', () async {
      fake.placemarks = const <Placemark>[];
      final gateway = GeocodingGatewayImpl();
      final result = await gateway.reverse(latitude: 0, longitude: 0);
      expect(result, isNull);
    });

    test('placemark with no populated fields still returns a non-null address', () async {
      fake.placemarks = <Placemark>[const Placemark()];
      final gateway = GeocodingGatewayImpl();
      final result = await gateway.reverse(latitude: 10, longitude: 20);
      expect(result, isNotNull);
      expect(result!.address, isNotEmpty);
    });
  });
}
