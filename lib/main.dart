import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:park_place/screens/Home.dart';
import 'package:park_place/screens/HomeUser.dart';
import 'package:park_place/screens/detailsScreen.dart';
import 'package:park_place/screens/mainPage.dart';
import 'package:park_place/screens/parkVehivleHomePage.dart';
import 'package:park_place/screens/parkvehicleDetailPage.dart';
import 'package:park_place/shared/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

const FirebaseOptions webFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyD65kXoOn8RW9i6EXRKa-4henzFUoaH36M',
  authDomain: 'car-parking-system-42fc0.firebaseapp.com',
  projectId: 'car-parking-system-42fc0',
  storageBucket: 'car-parking-system-42fc0.appspot.com',
  messagingSenderId: '698202999109',
  appId: '1:698202999109:android:db1fb1114b0ad8c60f162c',
);

bool owner = false;

Future<bool> _initAll() async {
  try {
    final pref = await SharedPreferences.getInstance();
    owner = pref.getBool('ownerRole') ?? false;
  } catch (e) {
    log('SharedPreferences error: $e');
  }

  try {
    await Firebase.initializeApp(
      options: kIsWeb ? webFirebaseOptions : null,
    ).timeout(const Duration(seconds: 10));
    log('Firebase initialized OK');
    return true;
  } on TimeoutException {
    log('Firebase init timed out — running without auth');
    return false;
  } catch (e) {
    log('Firebase init error: $e');
    return false;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initAll();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ParkPlace',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/detailsScreen': (context) => DetailsScreen(),
        '/mainPage': (context) => MainPage(),
      },
      home: FutureBuilder<bool>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Loading();
          }
          if (snapshot.data == true) {
            return _AuthGate();
          }
          return MainPage();
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        final user = userSnapshot.data;

        if (user != null && owner) {
          log('Owner logged in');
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('giveplaceusers')
                .doc(user.phoneNumber)
                .snapshots(),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting) {
                return Loading();
              }
              if (snapShot.hasData && snapShot.data!.exists) {
                return Home();
              }
              return DetailsScreen();
            },
          );
        }

        if (user != null && !owner) {
          log('User logged in');
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('parkvehicleusers')
                .doc(user.phoneNumber)
                .snapshots(),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting) {
                return Loading();
              }
              if (snapShot.hasData && snapShot.data!.exists) {
                return HomeUser();
              }
              return ParkDetailsScreen();
            },
          );
        }

        return MainPage();
      },
    );
  }
}
