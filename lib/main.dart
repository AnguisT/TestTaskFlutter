// package
import 'package:flutter/material.dart';

// class
import './views/home.dart';

void main() {
  runApp(
    new MaterialApp(
      title: 'Test application',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => new HomePage(),
      },
    )
  );
}