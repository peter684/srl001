import 'package:flutter/material.dart';
import 'package:srl001/pages/login_signup_page.dart';
import 'package:srl001/services/authentication.dart';
import 'package:srl001/pages/home_page.dart';
import 'package:srl001/pages/home.dart';

class RootPage extends StatefulWidget {
  RootPage({this.authenticator});

  final Authenticator authenticator;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  Authenticator auth;
  @override
  void initState() {
    super.initState();
    auth = widget.authenticator;
    auth.authStatus = AuthStatus.NOT_DETERMINED;
    auth.userId = "";
    auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
         auth.userId = user?.uid;
        }
        auth.authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
        auth.userId=user.uid.toString();
      });
    });
  }

  void _onLoggedIn() {
    auth.getCurrentUser().then((user) {
      setState(() {
        auth.userId = user.uid.toString();
        auth.authStatus = AuthStatus.LOGGED_IN;
      });
    });
  }


  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Home();
//    switch (auth.authStatus) {
//      case AuthStatus.NOT_DETERMINED:
//        return _buildWaitingScreen();
//        break;
//      case AuthStatus.NOT_LOGGED_IN:
//        return new LoginSignUpPage(
//          authenticator: auth,
//          rootPageState: this,
//        );
//        break;
//      case AuthStatus.LOGGED_IN:
//        if (auth.userId.length > 0 &&
//            auth.userId != null) {
//          //return new HomePage(
//          //  authenticator: auth,
//          //  rootPageState: this,
//          //);
//          return Home();
//        } else
//          return _buildWaitingScreen();
//        break;
//      default:
//        return _buildWaitingScreen();
//   }
  }
}
