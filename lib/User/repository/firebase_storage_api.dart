import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseStorageAPI {
  final firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref();

  Future<firebase_storage.UploadTask> uploadFile(String path, File image) async {
    return Future.value(ref.child(path).putFile(image));
  }
}