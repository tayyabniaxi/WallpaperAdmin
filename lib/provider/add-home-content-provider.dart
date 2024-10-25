import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHomeContentProvider with ChangeNotifier {
  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> get images => _images;

  Future<void> fetchImagesFromCategory(String category) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(category)
          .get();
      List<dynamic> images = snapshot.get('images');
      _images = images.map((image) => image as Map<String, dynamic>).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<String?> uploadImageToFirebase(File imageFile, String category, String imageName) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('categories/$category/$imageName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> addImagesToCategory(String category, Map<String, dynamic> imageData) async {
    try {
      await FirebaseFirestore.instance.collection('categories').doc(category).set({
        'images': FieldValue.arrayUnion([imageData]),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('images').add({
        ...imageData,
        'category': category,
      
      });

      _images.add(imageData);
      notifyListeners();
    } catch (e) {
      print('Error adding images to Firestore: $e');
      throw e;
    }
  }


}