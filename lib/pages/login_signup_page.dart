import 'package:flutter/material.dart';
import 'package:srl001/services/authentication.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({@required this.onLogin, @required this.onSignup});

  Function onLogin;
  Function onSignup;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;
  bool _isEmailVerified=false;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      try {
        if (_formMode == FormMode.LOGIN) {
          AuthStatus status = await widget.onLogin(
              email: _email,
              password: _password); //let rootpage try to log the user in

          switch (status) {
            case AuthStatus.SIGNED_UP:
            //user has previously signed up but email not yet verified
              _showResendVerifyEmailDialog();
              break;
            case AuthStatus.NOT_DETERMINED:
              break;
            case AuthStatus.NOT_LOGGED_IN:
              break;
            case AuthStatus.LOGGED_IN:

              break;
            default:
          }
        }
        else{
          AuthStatus status = await widget.onSignup(
              email: _email,
              password: _password); //let rootpage try to sign the user up
          switch (status) {
            case AuthStatus.SIGNED_UP:
            //user has just signed up, show confirmation dialog
              _showVerifyEmailSentDialog();
              break;
            case AuthStatus.NOT_DETERMINED:
              break;
            case AuthStatus.NOT_LOGGED_IN:
              break;
            case AuthStatus.LOGGED_IN:

              break;
            default:
          }
        }

        setState(() {
          _isLoading=false;
        });


      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }


  void _resendVerifyEmail(){
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showResendVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resend link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resendVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;

    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter login demo'),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);

  }

  Widget _showBody(){
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              _showSecondaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: FlutterLogo(size: 100.0),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return 'Email can\'t be empty';
          }
        },
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return 'Email can\'t be empty';
          }
        },
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('Create an account',
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
          : new Text('Have an account? Sign in',
              style:
                  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: _formMode == FormMode.LOGIN
                ? new Text('Login',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('Create account',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
}
