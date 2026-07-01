import 'package:booklub/domain/entities/io/picked_image.dart';
import 'package:booklub/utils/http/http_utils.dart';
import 'package:http/http.dart' as http;

class ClubCreationDTO {

  final String name;

  final String ownerId;

  final PickedImage? image;

  final bool isPrivate;

  ClubCreationDTO({
    required this.name,
    required this.isPrivate,
    required this.ownerId,
    this.image,
  });

  Future<void> fillMultipartRequest(http.MultipartRequest request) async {
    request.fields['name'] = name;
    request.fields['isPrivate'] = isPrivate.toString();
    request.fields['ownerId'] = ownerId;

    if (image != null && HttpUtils.isImage(image!.name)) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        image!.bytes,
        filename: image!.name,
        contentType: HttpUtils.resolveMediaType(image!.name)
      ));
    }
  }

}