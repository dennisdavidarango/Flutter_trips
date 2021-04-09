import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/User/bloc/bloc_user.dart';

import 'package:flutter_app/User/model/user.dart'as model;
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:flutter_app/Place/model/place.dart';


class ProfilePlacesList extends StatelessWidget {
  
  UserBloc userBloc;
  model.User user;
  ProfilePlacesList(@required this.user);


  @override
  Widget build(BuildContext context) {
    
    userBloc = BlocProvider.of<UserBloc>(context);
    
    return Container(
      margin: EdgeInsets.only(
          top: 10.0,
          left: 20.0,
          right: 20.0,
          bottom: 10.0
      ),
      child: StreamBuilder(
          stream: userBloc.myPlacesListStream(user.uid),
          builder: (context, AsyncSnapshot snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.waiting:
                return CircularProgressIndicator();
              case ConnectionState.done:
                return Column(
                    children: userBloc.buildMyPlaces(snapshot.data.docs)
                );
              case ConnectionState.active:
                return Column(
                    children: userBloc.buildMyPlaces(snapshot.data.docs)
                );

              case ConnectionState.none:
                return CircularProgressIndicator();
              default: return Column(
                  children: userBloc.buildMyPlaces(snapshot.data.docs)
              );
            }
          }
      ),
    );
  }

  /*
  * Column(
        children: <Widget>[
          ProfilePlace(place),
          ProfilePlace(place2),
        ],
      ),
  * */

}