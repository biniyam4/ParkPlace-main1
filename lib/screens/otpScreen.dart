import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:park_place/screens/Home.dart';
import 'package:park_place/screens/HomeUser.dart';
import 'package:park_place/screens/detailsScreen.dart';
import 'package:park_place/screens/loginScreen.dart';
import 'package:park_place/screens/parkVehivleHomePage.dart';
import 'package:park_place/screens/parkvehicleDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool owner = false;

class OTPScreen extends StatefulWidget {
  final phone = LoginScreen.phone;

  OTPScreen({Key? key}) : super(key: key);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  late String _verificationCode, userCode;
  bool codeSent = false, verifying = false;

  void showSnackBar(String msg, Color color) {
    var snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> checkRole() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    owner = (pref.getBool('ownerRole') ?? false);
  }

  String get fullPhone => '+251${widget.phone}';

  _phoneVerified() async {
    if (owner) {
      await FirebaseFirestore.instance
          .collection("giveplaceusers")
          .doc(fullPhone)
          .get()
          .then((value) {
        if (value.exists) {
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => Home()),
          );
        } else {
          FirebaseFirestore.instance
              .collection("giveplaceusers")
              .doc(fullPhone)
              .set({
            'fullName': 'Name',
            'mobileNumber': fullPhone,
          });
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new DetailsScreen()),
          );
        }
      });
    } else {
      await FirebaseFirestore.instance
          .collection("parkvehicleusers")
          .doc(fullPhone)
          .get()
          .then((value) {
        if (value.exists) {
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => HomeUser()),
          );
        } else {
          FirebaseFirestore.instance
              .collection("parkvehicleusers")
              .doc(fullPhone)
              .set({
            'fullName': 'Name',
            'mobileNumber': fullPhone,
          });
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => ParkDetailsScreen()),
          );
        }
      });
    }
  }

  _verifyPhone(phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+251$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) async {
          if (value.user != null) {
            log('# Auto-verified #');
            _phoneVerified();
          }
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        log('Verification failed: ${e.message}');
        showSnackBar(
            'Verification failed: ${e.message ?? "Unknown error"}', Colors.red);
        setState(() {
          codeSent = false;
        });
      },
      codeSent: (String? verficationID, int? resendToken) {
        setState(() {
          _verificationCode = verficationID!;
          codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        log('OTP timeout');
      },
      timeout: Duration(seconds: 60),
    );
  }

  _verifyOTP() async {
    _formkey.currentState!.validate();
    if (userCode.isNotEmpty && userCode.length == 6) {
      try {
        await FirebaseAuth.instance
            .signInWithCredential(PhoneAuthProvider.credential(
                verificationId: _verificationCode, smsCode: userCode))
            .then((value) async {
          if (value.user != null) {
            _phoneVerified();
          }
        });
      } catch (e) {
        log(e.toString());
        FocusScope.of(context).unfocus();
        showSnackBar('Invalid OTP! Try again', Colors.red);
        setState(() {
          verifying = false;
        });
      }
    } else {
      showSnackBar('Please enter the 6-digit OTP', Colors.red);
      setState(() {
        verifying = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkRole();
    _verifyPhone(widget.phone);
    log('Verifying phone: +251${widget.phone}');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: owner ? Colors.blue[200] : Colors.purple[300],
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: !codeSent
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitFadingCircle(
                          color: Colors.white60,
                          size: 30,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Sending OTP to\n+251 ${widget.phone}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "OTP sent.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Enter the OTP sent to  +251 ${widget.phone}  to continue...",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _formModule(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _formModule() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 100, 30, 0),
      child: Form(
        key: _formkey,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.white.withOpacity(.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "ParkPlace.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white.withOpacity(.05),
                          ),
                          padding: EdgeInsets.fromLTRB(20, 5, 15, 5),
                          child: TextFormField(
                            maxLength: 6,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 8,
                              fontSize: 20,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              hintText: '------',
                              hintStyle: TextStyle(
                                color: Colors.white60.withOpacity(.35),
                                letterSpacing: 8,
                              ),
                            ),
                            obscureText: false,
                            validator: (val) {
                              setState(() {
                                userCode = val ?? '';
                              });
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 35),
              ],
            ),
            Positioned(
              bottom: 10,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 10,
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (!verifying) {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      verifying = true;
                    });
                    _verifyOTP();
                  }
                },
                child: Container(
                  width: 120,
                  height: 18,
                  child: Center(
                    child: verifying
                        ? SpinKitFadingCircle(
                            color: Colors.black54,
                            size: 20,
                          )
                        : Text(
                            "Log in",
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
