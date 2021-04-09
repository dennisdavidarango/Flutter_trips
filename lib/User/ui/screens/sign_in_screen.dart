import 'package:flutter/material.dart';
import 'package:flutter_app/User/bloc/bloc_user.dart';
import 'package:flutter_app/User/model/user.dart';
import 'package:flutter_app/widgets/gradient_back.dart';
import 'package:flutter_app/widgets/button_green.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_app/platzi_trips_cupertino.dart';


class SignInScreen extends StatefulWidget {

  @override
  State createState() {
  return _SignInScreen();
  }
}

class _SignInScreen extends State <SignInScreen>{
  UserBloc userBloc;
  double screenWidth;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    userBloc = BlocProvider.of(context);
    return _handleCurrentSession();
  }

  Widget _handleCurrentSession(){
    return StreamBuilder(
      stream: userBloc.authStatus,
      builder: (BuildContext context, AsyncSnapshot snapshop){
        if(!snapshop.hasData || snapshop.hasError){
          return signInGoogleUI();
        }else{
          return PlatziTripsCupertino();
        }
      },
    );
  }

  Widget signInGoogleUI(){
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GradientBack(height: null),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(

                  child: Container(
                    padding: EdgeInsets.only(left: 30.0),
                    width: screenWidth,
                    child: Text("Bienvenido\nthis is your News App " ,
                      style: TextStyle(
                          fontSize: 40.0,
                          fontFamily: "Lato",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,

                      ),
                    ),

                  )

              ),

              ButtonGreen(text: "Login with Gmail",
                  onPressed: (){
                    userBloc.signOut();
                    userBloc.signIn().then((auth.User user) {
                      userBloc.updateUserData(User(
                        uid: user.uid,
                        name: user.displayName,
                        email: user.email,
                        photoUrl: user.photoURL,

                      ));
                    });
                  },
                width: 300.0,
                heigth: 50.0,
              )

            ],
          )
        ],
      ),
    );
  }
}