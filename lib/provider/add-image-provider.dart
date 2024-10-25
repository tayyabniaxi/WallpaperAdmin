// search_image_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class SearchImageProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  File? newImage;
  bool isUpdating = false;
   bool isDeleting = false;
  final ImagePicker _picker = ImagePicker();

  // Search images from Firestore
  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('images')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'name': doc['name'],
                'url': doc['url'],
                'docId': doc.id,
              })
          .toList();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error searching images: $e');
      return [];
    }
  }
    // Delete image
  Future<void> deleteImage(String docId) async {
    try {
      isDeleting = true;
      notifyListeners(); 

      await FirebaseFirestore.instance.collection('images').doc(docId).delete();

      Fluttertoast.showToast(msg: 'Image deleted successfully');
      searchQuery = searchController.text;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting image: $e');
    } finally {
      isDeleting = false;
      notifyListeners(); 
    }
  }

  // Pick new image
  Future<File?> pickNewImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      newImage = File(image.path);
      notifyListeners();
      return newImage;
    }
    return null;
  }

  // Update image
  Future<void> updateImage(String docId, String newName, String oldUrl) async {
    if (newName.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a new name.');
      return;
    }

    isUpdating = true;
    notifyListeners();

    try {
      String newUrl = oldUrl;

      if (newImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'categories/updated/$newName-${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(newImage!);
        newUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('images').doc(docId).update({
        'name': newName,
        'url': newUrl,
        'uploadTimestamp': DateTime.now().millisecondsSinceEpoch,
      });

      Fluttertoast.showToast(msg: 'Image updated successfully.');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating image: $e');
    } finally {
      isUpdating = false;
      newImage = null;
      notifyListeners();
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery = query.toLowerCase();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}