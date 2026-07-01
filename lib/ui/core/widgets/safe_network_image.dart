import 'package:flutter/material.dart';

/// A drop-in replacement for [Image.network] that is resilient to
/// unreachable or malformed image URLs.
///
/// Each URL is attempted at most once. On failure the URL is recorded in an
/// in-memory cache ([_failedUrls]) and subsequent builds render the
/// [placeholder] immediately, without creating another [Image.network]. This
/// guarantees that a screen re-rendering frequently can never produce an
/// infinite stream of image-load errors (which would otherwise starve the UI
/// thread and trigger an ANR).
class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget placeholder;

  static final Set<String> _failedUrls = <String>{};

  const SafeNetworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.fit,
    required this.placeholder,
  });

  bool _isUsable() =>
      _isValidHttpUrl(url) && !_failedUrls.contains(url);

  @override
  Widget build(BuildContext context) {
    if (!_isUsable()) {
      return placeholder;
    }
    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) {
        _failedUrls.add(url!);
        return placeholder;
      },
    );
  }
}

/// `true` when [url] is a non-empty HTTP(S) string. Empty/`null`/non-http
/// values are the ones that produce the `file:///` resolution floods.
bool _isValidHttpUrl(String? url) =>
    url != null && url.isNotEmpty && url.startsWith('http');

/// Returns a network [ImageProvider] for valid HTTP(S) URLs, otherwise
/// [fallback] (default: the app logo asset).
///
/// Use this for [DecorationImage.image] / [CircleAvatar.backgroundImage] /
/// other `ImageProvider` call sites. It eliminates the `file:///` flood at
/// its source (empty/null image URLs). For `Image.network` widget sites,
/// prefer [SafeNetworkImage] which additionally caches unreachable hosts.
ImageProvider<Object> safeNetworkImageProvider(
  String? url, {
  ImageProvider<Object>? fallback,
}) {
  if (!_isValidHttpUrl(url)) {
    return fallback ?? const AssetImage('assets/images/booklub_logo_icon.png');
  }
  return NetworkImage(url!);
}
