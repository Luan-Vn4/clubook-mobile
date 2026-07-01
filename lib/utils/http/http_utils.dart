import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mime/mime.dart';

abstract final class HttpUtils {

  static MediaType resolveMediaType(String filename) {
    final imageMimeType = lookupMimeType(filename)
        ?? 'application/octet-stream';
    final parts = imageMimeType.split('/');
    return MediaType(parts[0], parts[1]);
  }

  static bool isImage(String filename) {
    final mediaType = resolveMediaType(filename);
    return mediaType.type == 'image';
  }

}