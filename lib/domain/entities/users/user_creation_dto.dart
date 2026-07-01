import 'package:booklub/domain/entities/io/picked_image.dart';
import 'package:booklub/utils/http/http_utils.dart';
import 'package:http/http.dart' as http;

class UserCreationDTO {

  final String username;

  final String email;

  final String firstName;

  final String lastName;

  final String? birthDate;

  final PickedImage? image;

  final String password;

  UserCreationDTO({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.image,
    required this.password,
  });

  Future<void> fillMultipartRequest(http.MultipartRequest request) async {
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['firstName'] = firstName;
    request.fields['lastName'] = lastName;
    request.fields['password'] = password;

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