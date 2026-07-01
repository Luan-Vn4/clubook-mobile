import 'package:booklub/config/theme/theme_config.dart';
import 'package:booklub/utils/geo/types/latlng.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;

/// Default map center (Brazil centroid) used while no pin has been placed.
const latlong2.LatLng _kDefaultCenter = latlong2.LatLng(-14.2350, -51.9253);

/// Props-based location picker composed of an address text field and an
/// interactive OpenStreetMap minimap driven by [flutter_map].
///
/// The widget holds no business logic and no overlay management — the caller
/// (the host page) owns the [fieldLink] and [fieldKey] so it can position a
/// dropdown overlay via [CompositedTransformFollower], exactly like the
/// book-search pattern in `CreateReadingGoalPage`.
class LocationPicker extends StatelessWidget {
  /// Shared text controller for the address field, owned by the VM.
  final TextEditingController addressController;

  /// Fired on every change of the address text.
  final ValueChanged<String> onAddressChanged;

  /// Domain location of the marker, or `null` when no pin has been placed.
  final LatLng? pinLocation;

  /// Fired with the domain [LatLng] tapped on the minimap.
  final ValueChanged<LatLng> onMapTapped;

  /// [LayerLink] placed on the address field so the host page can anchor an
  /// overlay to it.
  final LayerLink fieldLink;

  /// [GlobalKey] placed on the address field so the host page can read its
  /// render geometry.
  final GlobalKey fieldKey;

  const LocationPicker({
    super.key,
    required this.addressController,
    required this.onAddressChanged,
    required this.onMapTapped,
    required this.fieldLink,
    required this.fieldKey,
    this.pinLocation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pinLocation = this.pinLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildAddressField(colorScheme),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: pinLocation != null
                  ? toMapLatLng(pinLocation)
                  : _kDefaultCenter,
              initialZoom: 4.0,
              onTap: (_, latlong2.LatLng point) =>
                  onMapTapped(fromMapLatLng(point)),
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'booklub',
              ),
              if (pinLocation != null)
                MarkerLayer(
                  markers: <Marker>[
                    Marker(
                      point: toMapLatLng(pinLocation),
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              RichAttributionWidget(
                attributions: <SourceAttribution>[
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(ColorScheme colorScheme) {
    const borderRadius = BorderRadius.all(Radius.circular(8));

    return CompositedTransformTarget(
      link: fieldLink,
      child: TextField(
        key: fieldKey,
        controller: addressController,
        onChanged: onAddressChanged,
        decoration: InputDecoration(
          labelText: 'Nome do lugar',
          labelStyle: TextStyle(color: colorScheme.superLightBlack),
          floatingLabelStyle: TextStyle(color: colorScheme.onSurface),
          filled: true,
          fillColor: colorScheme.surfaceContainerHigh,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: borderRadius,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary),
            borderRadius: borderRadius,
          ),
          suffixIcon: const Icon(Icons.search),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  /// Converts a domain [LatLng] to the `latlong2` type expected by
  /// `flutter_map` APIs.
  latlong2.LatLng toMapLatLng(LatLng domain) =>
      latlong2.LatLng(domain.latitude, domain.longitude);

  /// Converts a `latlong2` coordinate coming from `flutter_map` back into the
  /// canonical domain [LatLng].
  LatLng fromMapLatLng(latlong2.LatLng map) =>
      LatLng(latitude: map.latitude, longitude: map.longitude);
}
