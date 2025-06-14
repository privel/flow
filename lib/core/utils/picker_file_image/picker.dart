// import 'dart:typed_data';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_cropper/image_cropper.dart';

// class Picker {
//   Future<Uint8List?> pickImageBytes(BuildContext context) async {
//     if (kIsWeb) {
//       final result = await FilePicker.platform.pickFiles(type: FileType.image);
//       if (result?.files.first.bytes == null) return null;

//       final currentContext = context;

//       final croppedFile = await ImageCropper().cropImage(
//         sourcePath: result!.files.first.name,
//         compressFormat: ImageCompressFormat.jpg,
//         compressQuality: 85,
//         aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//         uiSettings: [
//           WebUiSettings(
//             context: currentContext,
//           ),
//         ],
//       );

//       return croppedFile == null ? null : await croppedFile.readAsBytes();
//     } else {
//       final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (pickedFile == null) return null;

//       final croppedFile = await ImageCropper().cropImage(
//         sourcePath: pickedFile.path,
//         compressFormat: ImageCompressFormat.jpg,
//         compressQuality: 85,
//         aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//         uiSettings: [
//           AndroidUiSettings(
//             toolbarTitle: 'Обрезка фото',
//             toolbarColor: const Color(0xFF2A2A2A),
//             toolbarWidgetColor: Colors.white,
//             lockAspectRatio: true,
//             initAspectRatio: CropAspectRatioPreset.square,
//           ),
//           IOSUiSettings(
//             title: 'Обрезка фото',
//             aspectRatioLockEnabled: true,
//           ),
//         ],
//       );

//       return croppedFile == null ? null : await croppedFile.readAsBytes();
//     }
//   }
// }

import 'dart:typed_data';
import 'dart:io'; // Keep for non-web platforms if needed, but not strictly for image_picker
import 'package:flow/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class Picker {
  Future<Uint8List?> pickImageBytes(BuildContext context) async {
    if (kIsWeb) {
      // Логика для веб-версии (FilePicker) остается прежней
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result?.files.first.bytes == null) return null;

      final currentContext = context;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: result!.files.first
            .name, // Для веб-версии может потребоваться локальный путь
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
      // Логика для мобильной версии (Android/iOS)
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    IconlyLight.camera,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    S.of(context).takeAPhoto,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontFamily: 'SFProText',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(
                    IconlyLight.image,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    S.of(context).chooseFromGallery,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontFamily: 'SFProText',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return null; // Пользователь отменил выбор

      final pickedFile = await ImagePicker().pickImage(source: source);
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
          // Добавьте WebUiSettings для мобильных браузеров, если это требуется
          WebUiSettings(
            context: context, // Передаем context для WebUiSettings
          ),
        ],
      );

      return croppedFile == null ? null : await croppedFile.readAsBytes();
    }
  }
}
