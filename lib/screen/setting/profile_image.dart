import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageService {
  // Function to pick, compress, and save the profile image
  Future<File?> updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/profile_image.jpg';

      // Convert XFile to File
      final imageFile = File(pickedFile.path);

      // Compress the image
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        path,
        quality: 90,
      );

      // Cast compressed image to File?
      final File? finalImage = compressedImage as File?;

      // Return the compressed image if available, otherwise return the original image
      return finalImage ?? imageFile;
    }

    return null; // Return null if no image is selected
  }

  // Function to save the profile image path in SharedPreferences
  Future<void> saveProfileImagePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImage', path);
  }

  // Function to retrieve the saved profile image path
  Future<String?> getProfileImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImage');
  }
}
