// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_wall_paper_app/image-list.dart';

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  String? selectedCategory;
  String? selectedSubCategory;

  final List<String> categories = [
    'Wallpaper',
    'Technology',
    'Animals',
    'Sports',
    'Art',
    'Food',
    'Qaiser',
  ];

  final Map<String, List<String>> subCategories = {
    "Wallpaper": [],
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
    'Qaiser': ['Farooq'],
    'Sports': [
      'Football',
      'Basketball',
      'Tennis',
      'Swimming',
      'Running',
      'Cycling',
      'Baseball',
      'Boxing'
    ],
    'Art': [
      'Painting',
      'Photography',
      'Design',
      'Fashion',
      'Digital Art',
      'Calligraphy',
      'Illustration',
      'Typography'
    ],
    'Food': [
      'Fruits',
      'Fast Food',
      'Desserts',
      'Drinks',
      'Seafood',
      'Meat',
      'Baking',
      'Dairy'
    ],
  };

  File? _image;
  final _nameController = TextEditingController();
  final _desController = TextEditingController();
  bool _isUploading = false;
  bool isPro=false;
  

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null ||
        _nameController.text.isEmpty ||
        selectedCategory == null ||
        selectedSubCategory == null) {
      Fluttertoast.showToast(msg: 'Please fill all fields and pick an image.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image to Firebase Storage with category and subcategory
      final storageRef = FirebaseStorage.instance.ref().child(
          'categories/$selectedCategory/$selectedSubCategory/${_nameController.text}.jpg');
      await storageRef.putFile(_image!);

      // Get the image URL
      final url = await storageRef.getDownloadURL();

      // Save image data in Firestore under category and subcategory
      final docRef = FirebaseFirestore.instance
          .collection('categories')
          .doc(selectedCategory)
          .collection('subcategories')
          .doc(selectedSubCategory);

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.update({
          'images': FieldValue.arrayUnion([
            {'url': url, 'key': _nameController.text, 'isPro': isPro,"description":_desController.text}
          ]),
        });
      } else {
        await docRef.set({
          'images': [
            {'url': url, 'key': _nameController.text,'isPro': isPro,"description":_desController.text}
          ],
        });
      }

      final imagesCollectionRef =
          FirebaseFirestore.instance.collection('images');
      await imagesCollectionRef.add({
        'name': _nameController.text,
        'url': url,
        'category': selectedCategory,
        'subcategory': selectedSubCategory,
        'uploadTimestamp':
            Timestamp.now().millisecondsSinceEpoch, // Save timestamp
            'isPro': isPro,"description":_desController.text
      });

      setState(() {
        _image = null;
        _nameController.clear();
        selectedCategory = null;
        selectedSubCategory = null;
      });

      Fluttertoast.showToast(msg: 'Image uploaded successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Upload failed: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Image Name'),
              ),
                TextField(
                controller: _desController,
                decoration: const InputDecoration(labelText: 'Enter Description'),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                hint: const Text('Select Category'),
                value: selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue;
                    selectedSubCategory = null; // Reset subcategory
                  });
                },
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
              if (selectedCategory !=
                  null)
                DropdownButton<String>(
                  hint: const Text('Select Subcategory'),
                  value: selectedSubCategory,
                  onChanged: (newValue) {
                    setState(() {
                      selectedSubCategory = newValue;
                    });
                  },
                  items: subCategories[selectedCategory]!.map((subCategory) {
                    return DropdownMenuItem<String>(
                      value: subCategory,
                      child: Text(subCategory),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
                const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Normal'),
                      leading: Radio<bool>(
                        value: false,
                        groupValue: isPro,
                        onChanged: (bool? value) {
                          setState(() {
                            isPro = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Pro'),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: isPro,
                        onChanged: (bool? value) {
                          setState(() {
                            isPro = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 16),
_image != null ? Image.file(_image!) : Container(),
const SizedBox(height: 16),


ElevatedButton(
  onPressed: _isUploading
      ? null
      : _uploadImage,
  child: const Text('Upload Image'),
),
if (_isUploading)
  const CircularProgressIndicator(),
const SizedBox(height: 16),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchImagePage()),
    );
  },
  child: const Text('Search Page'),
),
            ],
          ),
        ),
      ),
    );
  }
}
