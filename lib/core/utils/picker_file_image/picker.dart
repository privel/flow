import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';



class Picker {

  
Future<Uint8List?> pickImageBytes() async {
  if (kIsWeb) {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    return result?.files.first.bytes;
  } else {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;
    return await pickedFile.readAsBytes();
  }
}

}