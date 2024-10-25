import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class UpdateImageProvider extends ChangeNotifier {
  final List<String> categories = [
    'Wallpaper',
    'Technology',
    'Animals',
    'Sports',
    'Art',
    'Food'
  ];
  final Map<String, List<String>> subCategories = {
    'Technology': [
      'AI',
      'Gadgets',
      'Robots',
      'Coding',
      'VR',
      'AR',
      'Blockchain',
      'Drones'
    ],
    'Animals': [
      'Cats',
      'Dogs',
      'Birds',
      'Wildlife',
      'Aquatic',
      'Insects',
      'Pets',
      'Horses'
    ],
    // Add other subcategories here
  };

  String _selectedCategory = 'Technology';
  final int itemsPerPage = 3;
  int _currentPage = 0;
  List<String> _displayedSubCategories = [];

  File? newImage;
  bool isUpdating = false;
  bool isDeleting = false;
  final ImagePicker _picker = ImagePicker();

  // Getters
  String get selectedCategory => _selectedCategory;
  List<String> get displayedSubCategories => _displayedSubCategories;

  // Methods to load subcategories
  void loadSubCategories(String category) {
    _selectedCategory = category;
    _displayedSubCategories = [];
    _currentPage = 0;
    loadMoreItems();
    notifyListeners();
  }

  void loadMoreItems() {
    if (_currentPage * itemsPerPage >=
        subCategories[_selectedCategory]!.length) {
      return;
    }
    final endIndex = (_currentPage + 1) * itemsPerPage;
    _displayedSubCategories.addAll(subCategories[_selectedCategory]!.sublist(
      _currentPage * itemsPerPage,
      endIndex > subCategories[_selectedCategory]!.length
          ? subCategories[_selectedCategory]!.length
          : endIndex,
    ));
    _currentPage++;
    notifyListeners();
  }

  // Fetch images from Firestore for a subcategory
  Future<List<Map<String, dynamic>>> fetchSubcategoryImages(
      String category, String subcategory) async {
    final doc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(category)
        .collection('subcategories')
        .doc(subcategory)
        .get();

    if (doc.exists) {
      List<dynamic> imagesData = doc.data()?['images'] ?? [];
      return imagesData
          .map((imageData) => imageData as Map<String, dynamic>)
          .toList();
    }
    return [];
  }

  // Delete image
  Future<void> deleteImage(
      String category, String subcategory, String imageKey) async {
    try {
      isDeleting = true;
      notifyListeners();

      // Deleting the image document from Firestore
      final docRef = FirebaseFirestore.instance
          .collection('categories')
          .doc(category)
          .collection('subcategories')
          .doc(subcategory);

      await docRef.update({
        'images': FieldValue.arrayRemove([
          {'key': imageKey}
        ])
      });

      Fluttertoast.showToast(msg: 'Image deleted successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting image: $e');
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  // Pick a new image
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
  Future<void> updateImage(String category, String subcategory, int timeStamp,
      String newName, String oldUrl, String oldDesc) async {
    if (newName.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a new name.');
      return;
    }

    isUpdating = true;
    notifyListeners();

    try {
      String newUrl = oldUrl;
      String newDesc = oldDesc;
      // bool newStatus=oldStatus;

      // If a new image is picked, upload it to Firebase Storage
      if (newImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'categories/$category/$subcategory/$newName-${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(newImage!);
        newUrl = await storageRef.getDownloadURL();
      }

      // Update the image data in Firestore
      final docRef = FirebaseFirestore.instance
          .collection('categories')
          .doc(category)
          .collection('subcategories')
          .doc(subcategory);

      final subcategoryDoc = await docRef.get();
      if (subcategoryDoc.exists) {
        List<dynamic> images = subcategoryDoc['images'] ?? [];

        final updatedImages = images.map((image) {
          if (image['uploadTimestamp'] == timeStamp) {
            return {
              'key': newName,
              'url': newUrl,
              'description': newDesc,
              // "isPro": newStatus,
              'uploadTimestamp': DateTime.now().millisecondsSinceEpoch,
              // Add any other fields you need to update
            };
          }
          return image;
        }).toList();

        await docRef.update({'images': updatedImages});
      }

      Fluttertoast.showToast(msg: 'Image updated successfully.');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating image: $e');
    } finally {
      isUpdating = false;
      newImage = null;
      notifyListeners();
    }
  }
}
