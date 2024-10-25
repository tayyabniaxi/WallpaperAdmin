// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_wall_paper_app/provider/add-home-content-provider.dart';
import 'package:provider/provider.dart';
// import 'image_provider.dart'; // Import your provider

class AddHomeContentDataScreen extends StatefulWidget {

  @override
  State<AddHomeContentDataScreen> createState() => _AddHomeContentDataScreenState();
}


class _AddHomeContentDataScreenState extends State<AddHomeContentDataScreen> {
  final List<String> categories = [
    'Nature',
    'Popular',
    'Random',
  ];

  File? _image;
  final _nameController = TextEditingController();
  final _desController = TextEditingController();
  bool _isUploading = false;
  bool isPro = false;
  String? selectedCategory;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
Future<void> _uploadData() async {
    if (_image == null || 
        selectedCategory == null || 
        _nameController.text.isEmpty || 
        _desController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final imageName = '${DateTime.now().millisecondsSinceEpoch}_${_nameController.text}';
      final imageUrl = await Provider.of<AddHomeContentProvider>(context, listen: false)
          .uploadImageToFirebase(_image!, selectedCategory!, imageName);

      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      Map<String, dynamic> imageData = {
        'description': _desController.text,
        'isPro': isPro,
        'name': _nameController.text,
        'title': _nameController.text, 
        'uploadTimestamp': Timestamp.now().millisecondsSinceEpoch,
        'url': imageUrl,
      
      };

      await Provider.of<AddHomeContentProvider>(context, listen: false)
          .addImagesToCategory(selectedCategory!, imageData);

      setState(() {
        _image = null;
        _nameController.clear();
        _desController.clear();
        isPro = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Home Content"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              hint: const Text('Select Category'),
              value: selectedCategory,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Image Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _desController,
              decoration: const InputDecoration(
                labelText: 'Enter Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Normal'),
                    leading: Radio<bool>(
                      value: false,
                      activeColor: Colors.blue,
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
                        activeColor: Colors.blue,
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
            const SizedBox(height: 16),
            if (_image != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.file(_image!, fit: BoxFit.contain),
              ),
            if (_image == null)
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload, size: 50),
                      SizedBox(height: 8),
                      Text('Tap to upload image'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadData,
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Uploading...'),
                      ],
                    )
                  : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}