import 'package:booklub/domain/geocoding/models/geocoding_result.dart';

/// Contract for converting between human-readable addresses and
/// geographic coordinates.
///
/// Implementations live in the infra layer and wrap platform geocoding
/// services. The UI/VM layer depends ONLY on this abstract interface
/// (constitution Principle II).
abstract class GeocodingGateway {
  /// Forward geocoding: resolve [query] (an address string typed by the
  /// user) to candidate locations.
  ///
  /// Returns at most [limit] results. An empty list means the service
  /// could not resolve the query (NOT an error condition — errors throw).
  ///
  /// Throws on platform/service failure (caller must catch).
  Future<List<GeocodingResult>> searchByAddress({
    required String query,
    int limit = 5,
  });

  /// Reverse geocoding: resolve [latitude] / [longitude] to the nearest
  /// human-readable address.
  ///
  /// Returns null when no address can be determined for the coordinates.
  Future<GeocodingResult?> reverse({
    required double latitude,
    required double longitude,
  });
}
