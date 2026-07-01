import 'package:booklub/domain/entities/io/picked_image.dart';
import 'package:file_picker/file_picker.dart';

class IORepository {

  Future<PickedImage?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      // Required so we get the bytes on every platform (web always loads them,
      // native only does when withData is true).
      withData: true,
    );

    final file = result?.files.single;
    if (file?.bytes != null) {
      return PickedImage(bytes: file!.bytes!, name: file.name);
    }

    return null;
  }

}