// package
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class
import './views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.blue,
      statusBarIconBrightness: Brightness.light,
    )
  );
  runApp(
    new MaterialApp(
      title: 'Test application',
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => new HomePage(),
      },
    )
  );
}