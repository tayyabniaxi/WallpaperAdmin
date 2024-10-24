    // ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:new_wall_paper_app/add-image.dart';
// import 'package:my_wallpaper_app/add-image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(MyApp());

  await checkGooglePlayServicesAvailability();
}

Future<void> checkGooglePlayServicesAvailability() async {
  GoogleApiAvailability apiAvailability = GoogleApiAvailability.instance;
  final status = await apiAvailability.checkGooglePlayServicesAvailability();

  if (status == GooglePlayServicesAvailability.success) {
    print("Google Play Services is available.");
  } else {
    print("Google Play Services is not available: $status");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UploadImagePage(),
    );
  }
}


