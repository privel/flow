import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class Picker {
  Future<Uint8List?> pickImageBytes(BuildContext context) async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result?.files.first.bytes == null) return null;

   
      final currentContext = context;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: result!.files.first.name,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          WebUiSettings(
            context: currentContext,
          ),
        ],
      );

      return croppedFile == null ? null : await croppedFile.readAsBytes();
    } else {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Обрезка фото',
            toolbarColor: const Color(0xFF2A2A2A),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(
            title: 'Обрезка фото',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      return croppedFile == null ? null : await croppedFile.readAsBytes();
    }
  }
}
