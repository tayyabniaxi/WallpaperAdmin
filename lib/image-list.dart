
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
// import 'packag
class SearchImagePage extends StatefulWidget {
  const SearchImagePage({super.key});

  @override
  _SearchImagePageState createState() => _SearchImagePageState();
}

class _SearchImagePageState extends State<SearchImagePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  File? _newImage;
  bool _isUpdating = false;

  Future<List<Map<String, dynamic>>> _searchImages(String query) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('images')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff') // Range query
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

  Future<void> _deleteImage(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('images').doc(docId).delete();
      Fluttertoast.showToast(msg: 'Image deleted successfully');
      setState(() {
        _searchQuery = _searchController.text;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting image: $e');
    }
  }

  Future<File?> _pickNewImage() async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image != null ? _newImage = File(image.path) : null;
  }

  Future<void> _updateImage(String docId, String newName, String oldUrl) async {
    if (newName.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a new name.');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      String newUrl = oldUrl;

      if (_newImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'categories/updated/$newName-${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_newImage!);
        newUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('images').doc(docId).update({
        'name': newName,
        'url': newUrl,
        'uploadTimestamp': DateTime.now().millisecondsSinceEpoch,
      });

      Fluttertoast.showToast(msg: 'Image updated successfully.');
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating image: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _showEditPopup(Map<String, dynamic> imageData) {
    final TextEditingController _nameController =
        TextEditingController(text: imageData['name']);
    File? _newImage;
    bool _isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Image'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Image Name'),
                  ),
                  const SizedBox(height: 16),
                  _newImage != null
                      ? Image.file(_newImage!, height: 100)
                      : Image.network(imageData['url'], height: 100),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      File? selectedImage = await _pickNewImage();
                      if (selectedImage != null) {
                        setState(() {
                          _newImage = selectedImage;
                        });
                      } else {
                        print("No image selected.");
                      }
                    },
                    child: const Text('Change Image'),
                  ),
                ],
              ),
              actions: [
                if (_isUpdating) 
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isUpdating = true;
                      });

                      await _updateImage(
                        imageData['docId'],
                        _nameController.text,
                        _newImage?.path ?? imageData['url'],
                      );

                      setState(() {
                        _isUpdating = false;
                      });

                      Navigator.of(context).pop();
                    },
                    child: const Text('Update'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search List'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by image name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text.toLowerCase();
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _searchImages(_searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final images = snapshot.data ?? [];
          if (images.isEmpty) {
            return const Center(child: Text('No images found.'));
          }

          return ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(
                  images[index]['url'],
                  width: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(images[index]['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _showEditPopup(images[index]);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _deleteImage(images[index]['docId']);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
