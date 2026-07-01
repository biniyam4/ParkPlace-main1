import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:park_place/screens/mainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool owner = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    owner = (pref.getBool('ownerRole') ?? false);
  } catch (e) {
    log('SharedPreferences error: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ParkPlace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/mainPage': (context) => MainPage(),
      },
      home: MainPage(),
    );
  }
}
