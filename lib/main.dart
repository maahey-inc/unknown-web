import 'dart:html';

import 'package:flutter/material.dart';
import 'package:unknown_web/HomePage.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';

void getParams() {
  var uri = Uri.dataFromString(window.location.href);
  Map<String, String> params = uri.queryParameters;
  //var id = params['id'];
//print(origin);
}

Future<void> main() async {
  getParams();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setPathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unknown',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color(0xffEDEDED)),
      //routes: {HomePage.routeName:(context)=> const HomePage(id: id, image: image, name: name)},
      home: HomePage(
        id: Uri.base.queryParameters["id"].toString() ?? "",
      ),
    );
  }
}
