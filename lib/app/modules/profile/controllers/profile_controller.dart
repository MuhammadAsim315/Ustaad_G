import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  var name = 'Jakob'.obs;
  var email = 'jakob@example.com'.obs;
  var phone = '+92 300 1234567'.obs;
  var profileImage = Rx<File?>(null);
  var profileImageBytes = Rx<Uint8List?>(null);
  var profileImagePath = Rx<String?>(null);

  void updateProfile({
    String? newName,
    String? newEmail,
    String? newPhone,
    File? newImage,
    Uint8List? newImageBytes,
    String? newImagePath,
  }) {
    if (newName != null) name.value = newName;
    if (newEmail != null) email.value = newEmail;
    if (newPhone != null) phone.value = newPhone;
    if (newImage != null) profileImage.value = newImage;
    if (newImageBytes != null) profileImageBytes.value = newImageBytes;
    if (newImagePath != null) profileImagePath.value = newImagePath;
  }
}

