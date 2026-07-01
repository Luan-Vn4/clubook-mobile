import 'package:booklub/domain/geocoding/gateways/geocoding_gateway.dart';
import 'package:booklub/domain/geocoding/models/geocoding_result.dart';
import 'package:booklub/utils/logger/app_logger.dart';
import 'package:geocoding/geocoding.dart';

/// Infra-layer [GeocodingGateway] backed by the `geocoding` platform package.
///
/// Converts the package's [Location] (forward) and [Placemark] (reverse)
/// types into the domain [GeocodingResult], keeping the `geocoding` package
/// out of the domain/UI layers (constitution Principle II).
class GeocodingGatewayImpl implements GeocodingGateway {
  final Logger _logger = AppLogger.create();

  GeocodingGatewayImpl() {
    setLocaleIdentifier('pt_BR');
  }

  @override
  Future<List<GeocodingResult>> searchByAddress({
    required String query,
    int limit = 5,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <GeocodingResult>[];
    try {
      final locations = await locationFromAddress(trimmed);
      if (locations.isEmpty) return const <GeocodingResult>[];

      final results = await Future.wait(
        locations.take(limit).map((loc) => _enrichResult(loc, trimmed)),
      );
      return results;
    } on NoResultFoundException {
      return const <GeocodingResult>[];
    }
  }

  Future<GeocodingResult> _enrichResult(
    Location loc,
    String fallback,
  ) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(loc.latitude, loc.longitude);
      if (placemarks.isNotEmpty) {
        return GeocodingResult(
          address: _formatPlacemark(placemarks.first),
          latitude: loc.latitude,
          longitude: loc.longitude,
        );
      }
    } on NoResultFoundException {
      // fall through to coordinate fallback
    }
    return GeocodingResult(
      address:
          '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
  }

  @override
  Future<GeocodingResult?> reverse({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      return GeocodingResult(
        address: _formatPlacemark(placemarks.first),
        latitude: latitude,
        longitude: longitude,
      );
    } on NoResultFoundException {
      return null;
    } on Object catch (error, stackTrace) {
      _logger.e(
        'Reverse geocoding failed for ($latitude, $longitude)',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  String _formatPlacemark(Placemark placemark) {
    final parts = <String?>[
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.postalCode,
      placemark.country,
    ]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Sem endereço';
  }
}
