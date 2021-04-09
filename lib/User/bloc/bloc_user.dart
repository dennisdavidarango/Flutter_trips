import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/Place/model/place.dart';
import 'package:flutter_app/User/model/user.dart';
import 'package:flutter_app/User/repository/cloud_firestore_api.dart';
import 'package:flutter_app/User/repository/cloud_firestore_repository.dart';
import 'package:flutter_app/User/repository/firebase_storage_repository.dart';
import 'package:flutter_app/User/ui/widgets/profile_place.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:flutter_app/User/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class UserBloc implements Bloc{

  final _auth_repository =  AuthRepository();


  // Flujo de datos - Streams
  // Stream - Firebase
  // StreamContoller

  Stream<auth.User> streamFirebase = auth.FirebaseAuth.instance.authStateChanges();
  Stream<auth.User> get authStatus => streamFirebase;

  auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  userId(){
    auth.FirebaseAuth.instance.currentUser;
  }

  Future<String> currentUser() async {
    final auth.User user = await _auth.currentUser;
    final String uid = user.uid.toString();
    print(uid);
    return uid;
  }


  //Casos de uso

  // 1. SignIn con google
  Future<auth.User> signIn() =>  _auth_repository.signInFirebase();

  // 2. Registrar usuario en base de datos
  final _cloudFirestoreRepository = CloudFirestoreRepository();
  void updateUserData(User user) => _cloudFirestoreRepository.updateUserDataFirestore(user);
  Future<void> updatePlaceDate(Place place) => _cloudFirestoreRepository.updatePlaceDate(place);
  Stream<QuerySnapshot> placesListStream() => FirebaseFirestore.instance.collection(CloudFirestoreAPI().PLACES).snapshots();
  Stream<QuerySnapshot> get placesStream => placesListStream();
  //List<CardImageWithFabIcon> buildPlaces(List<DocumentSnapshot> placesListSnapshot) => _cloudFirestoreRepository.buildPlaces(placesListSnapshot);
  List<Place> buildPlaces(List<DocumentSnapshot> placesListSnapshot, User user) => _cloudFirestoreRepository.buildPlaces(placesListSnapshot, user);
  Future likePlace(Place place, String uid) => _cloudFirestoreRepository.likePlace(place,uid);


  Stream<QuerySnapshot> myPlacesListStream(String uid) => FirebaseFirestore.instance.collection(CloudFirestoreAPI().PLACES)
      .where("userOwner", isEqualTo: FirebaseFirestore.instance.doc("${CloudFirestoreAPI().USERS}/${uid}"))
      .snapshots();
  List<ProfilePlace> buildMyPlaces(List<DocumentSnapshot> placesListSnapshot) => _cloudFirestoreRepository.buildMyPlaces(placesListSnapshot);

  final _firebaseStorageRepository = FirebaseStorageRepository();
  Future<firebase_storage.UploadTask> uploadFile(String path, File image) => _firebaseStorageRepository.uploadFile(path, image);

  signOut(){
    _auth_repository.signOut();

  }


  @override
  void dispose() {

  }
}