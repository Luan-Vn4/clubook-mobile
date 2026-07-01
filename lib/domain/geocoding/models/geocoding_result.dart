/// A single resolved geocoding result: a human-readable address paired with
/// its latitude/longitude coordinates.
///
/// Immutable value object produced by [GeocodingGateway] implementations.
/// Not serialized to JSON (lives only in VM/UI state) — kept as a plain
/// const-constructable class.
class GeocodingResult {
  final String address;
  final double latitude;
  final double longitude;

  const GeocodingResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}
