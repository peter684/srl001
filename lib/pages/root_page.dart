import 'package:flutter/material.dart';

import 'package:srl001/pages/login_signup_page.dart';
import 'package:srl001/services/authentication.dart';
import 'package:srl001/pages/home.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  Authenticator _authenticator;

  @override
  void initState() {
    super.initState();
    _authenticator = new Authenticator();
    _authenticator.checkAuthStatus().then((status) => setState((){}));
  }

  Future<AuthStatus> _onUserLogin({String email, String password}) async {
    AuthStatus authStatus = await _authenticator.signIn(email, password);
    setState(() {
    });
    return authStatus;
  }

  Future<AuthStatus> _onUserSignUp({String email, String password}) async {
    AuthStatus authStatus = await _authenticator.signUp(email, password);
    setState(() {

    });
    return authStatus;
  }

  void _onSignOut() async {
    await _authenticator.signOut();
    setState(() {
      //authentication status has changed; rebuild screen
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
    switch (_authenticator.getStatus()) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
            onLogin: _onUserLogin,
            onSignup: _onUserSignUp
        );
        break;
      case AuthStatus.LOGGED_IN:
        return Home(onSignOut: _onSignOut);
        break;
      case AuthStatus.SIGNED_UP:
        return new LoginSignUpPage(
            onLogin: _onUserLogin,
            onSignup: _onUserSignUp
        );
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
