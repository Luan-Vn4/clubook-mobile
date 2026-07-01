import 'package:booklub/domain/entities/io/picked_image.dart';
import 'package:booklub/utils/http/http_utils.dart';
import 'package:http/http.dart' as http;

class UserUpdateDTO {

  final String id;

  final String? firstName;

  final String? lastName;

  final String? birthDate;

  final PickedImage? image;

  UserUpdateDTO({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.image,
  });

  Future<void> fillMultipartRequest(http.MultipartRequest request) async {
    request.fields['id'] = id;
    request.fields['firstName'] = firstName!;
    request.fields['lastName'] = lastName!;

    if (birthDate != null) {
      request.fields['birthDate'] = birthDate!;
    }

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