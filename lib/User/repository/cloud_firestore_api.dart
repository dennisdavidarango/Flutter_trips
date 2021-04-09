import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app/Place/model/place.dart';
import 'package:flutter_app/Place/ui/widgets/card_image.dart';
import 'package:flutter_app/User/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_app/User/ui/widgets/profile_place.dart';

class CloudFirestoreAPI{

  final String USERS = "users";
  final String PLACES = "place";

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  void updateUserData(User user) async {
    DocumentReference ref = _db.collection(USERS).doc(user.uid);
    return ref.set({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'myPlaces': user.myPlaces,
      'myFavoritePlaces': user.myFavoritePlaces,
      'lastSignIn': DateTime.now()
    },);
  }

  Future<void> updatePlaceData(Place place) async {
    CollectionReference refPlaces = _db.collection(PLACES);

    auth.User user =  _auth.currentUser;
    if (user == null){
      return print("user is null");
    }else{
      refPlaces.add({
        'name': place.name,
        'description': place.description,
        'likes': place.likes,
        'urlImage': place.urlImage,
        'userOwner': _db.doc("$USERS/${user.uid}"),
      }).then((DocumentReference dr){
        dr.get().then((DocumentSnapshot snapshot){
          // ID Places Referencia Array
          DocumentReference refUsers = _db.collection(USERS).doc(user.uid);
          refUsers.update({
            'myPlaces': FieldValue.arrayUnion([_db.doc("$PLACES/${snapshot.id}")])
          });
        });
      });
    }
  }

  List<ProfilePlace> buildMyPlaces(List<DocumentSnapshot> placesListSnapshot){
    List<ProfilePlace> profilePlaces = [];
    placesListSnapshot.forEach((p) {
      profilePlaces.add(ProfilePlace(
        Place(
            name: p.data()['name'],
            description: p.data()['description'],
            urlImage: p.data()['urlImage'],
            likes: p.data()['likes'])
      ));
    });
    return profilePlaces;

  }

  List<Place> buildPlaces(List<DocumentSnapshot> placesListSnapshot, User user) {
    List<Place> places = [];

    placesListSnapshot.forEach((p)  {
      Place place = Place(id: p.id, name: p.data()["name"], description: p.data()["description"],
          urlImage: p.data()["urlImage"],likes: p.data()["likes"]
      );
      List usersLikedRefs =  p.data()["usersLiked"];
      place.liked = false;
      usersLikedRefs?.forEach((drUL){
        if(user.uid == drUL.documentID){
          place.liked = true;
        }
      });
      places.add(place);
    });
    return places;
  }

  Future likePlace(Place place, String uid) async {
    await _db.collection(PLACES).doc(place.id).get()
        .then((DocumentSnapshot ds){
      int likes = ds.data()["likes"];

      _db.collection(PLACES).document(place.id)
          .update({
        'likes': place.liked?likes+1:likes-1,
        'usersLiked':
        place.liked?
        FieldValue.arrayUnion([_db.doc("${USERS}/${uid}")]):
        FieldValue.arrayRemove([_db.doc("${USERS}/${uid}")])
      });
    });
  }

}