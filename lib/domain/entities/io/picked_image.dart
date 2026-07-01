import 'dart:typed_data';

/// A cross-platform picked image. We carry the raw bytes (plus the original
/// filename) instead of a `dart:io` File so the same code works on web, where
/// `File`/`FileImage`/`MultipartFile.fromPath` are unsupported.
class PickedImage {
  final Uint8List bytes;

  final String name;

  const PickedImage({
    required this.bytes,
    required this.name,
  });
}