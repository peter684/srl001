import 'package:flutter/material.dart';
import 'package:srl002/services/authentication.dart';
import 'package:srl002/pages/root_page.dart';
import 'package:srl002/pages/home.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter login demo',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        //home: new RootPage(authenticator : new Authenticator())
        home: new Home()
    );

  }
}
