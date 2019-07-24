import 'package:flutter/material.dart';
import 'package:srl001/services/authentication.dart';
import 'package:srl001/pages/root_page.dart';
//
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
        home: new RootPage()
    );
  }
}
