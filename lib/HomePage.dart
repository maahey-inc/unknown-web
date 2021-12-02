import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  static const routeName = '/user';

  String id;
  HomePage({
    @required this.id,
  });
  //const HomePage({ Key? key }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";
  String image;
  bool saving = false;
  bool datasaved = false;
  bool datagot = false;
  gettingdata() {
    print(widget.id.replaceAll(" ", "+").toString());
    FirebaseFirestore.instance
        .collection("user")
        .doc(widget.id.replaceAll(" ", "+").toString())
        .get()
        .then((value) {
      if (value.exists) {
        name = value["name"];
        image = value["image"];
      } else {
        print("Not Found");
      }
      setState(() {
        datagot = true;
      });
    });
  }

  savingdata() {
    setState(() {
      saving = true;
    });
    FirebaseFirestore.instance.collection("messages").add({
      "id": widget.id.replaceAll(" ", "+").toString(),
      "message": message.text,
      "date": DateTime.now().toString(),
    }).then((value) {
      FirebaseFirestore.instance
          .collection("tokens")
          .doc(widget.id.replaceAll(" ", "+").toString())
          .get()
          .then((value) {
        if (value.exists) {
          sendnotification(value["token"], "New Message", message.text);
        }
      });
    });
  }

  sendnotification(
    String token,
    String title,
    String message,
  ) async {
    print("sendingnotification");
    // Replace with server token from firebase console settings.
    final String serverToken =
        'AAAAAuJWHdI:APA91bFuE7kuFtZSB0zOZteuxuulI5vhL1Bg-_Qjl5KzCqH__NXK1iSv0foIJXrZ-SJOh_K3Ra0PWQk-bXdHqEja2DA6aR4w5R-cumB_7EdvpcidCfzPdC5Uj0DzoY3qCHjeUNcCvXZm';
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': message,
            'android_channel_id': 'unknown',
          },
          // 'android': {
          //   'notification': {
          //     'channel_id': 'unknown',
          //   },
          // },
          'priority': 'HIGH',
          'to': token,
        },
      ),
    );
    datasaved = true;
    saving = false;
    setState(() {});
  }

  @override
  void initState() {
    gettingdata();
    // TODO: implement initState
    super.initState();
  }

  final message = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: datasaved
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        child: Image.asset(
                          "Assets/Images/logo.png",
                          height: 50,
                        ),
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xffF9FA34),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Start receiving anonymous messages \non SnapChat now",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await launch("https://www.unknownapp.net");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Download the app now",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        style: ButtonStyle(
                          //elevation: 5.0,

                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xffFCFE35)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              // side: BorderSide(width: 6),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : !datagot
                  ? Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                        ),
                        SpinKitDoubleBounce(
                          color: Colors.yellow,
                          size: 100,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image.asset(
                        //   "Assets/Images/logo.png",
                        //   height: 100,
                        // ),
                        Container(
                          height: 50,
                        ),
                        Text(
                          "Send a Anonymous Message to \n $name",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Stack(
                          overflow: Overflow.visible,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 5,
                                  ),
                                  child: saving
                                      ? CircularProgressIndicator()
                                      : TextButton(
                                          onPressed: () {
                                            savingdata();
                                          },
                                          child: Text(
                                            "Send",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          )),
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color(0xffF9FA34),
                              ),
                              height: 200,
                            ),
                            Container(
                              child: Center(
                                child: TextField(
                                  controller: message,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Type Your Message Here...",
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              height: 150,
                            ),
                            Positioned(
                              top: -35,
                              child: image == null
                                  ? Icon(
                                      Icons.account_circle,
                                      size: 70,
                                    )
                                  : Image.network(
                                      image,
                                      height: 70,
                                    ),
                            ),
                          ],
                        ),
                        // Text(widget.name ?? ""),
                      ],
                    ),
        ),
      ),
    );
  }
}
