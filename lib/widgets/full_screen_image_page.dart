// ignore_for_file: use_key_in_widget_constructors, unused_element, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:new_wall_paper_app/provider/add-image-provider.dart';
import 'package:new_wall_paper_app/provider/update-image-provider.dart';
import 'package:new_wall_paper_app/views/wallpaper-manager.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:flutter/services.dart';
// import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

class FullScreenImagePage extends StatefulWidget {
  final String imageUrl;
  final String category;
  final String subcategories;
  final int timeStamp;
  final String desc;
  final String title;
  // final bool status;

  const FullScreenImagePage(
      {super.key,
      required this.imageUrl,
      required this.category,
      required this.subcategories,
      required this.timeStamp,
      required this.desc,
      required this.title,
      // required this.status
      
      });

  @override
  _FullScreenImagePageState createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  void _showEditPopup(BuildContext context, Map<String, dynamic> imageData) {
    final TextEditingController nameController =
        TextEditingController(text: imageData['name']);



    showDialog(
      context: context,
      builder: (context) {
        return Consumer<UpdateImageProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              title: const Text('Edit Image'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Image Name'),
                  ),
                  const SizedBox(height: 16),
                  provider.newImage != null
                      ? Image.file(provider.newImage!, height: 100)
                      : Image.network(imageData['url'], height: 100),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.pickNewImage(),
                    child: const Text('Change Image'),
                  ),
                ],
              ),
              actions: [
                if (provider.isUpdating)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () async {
                      await provider.updateImage(
                        // imageData['docId'],
                        // nameController.text,
                        // imageData['url'],
                        widget.category,
                        widget.subcategories,
                        widget.timeStamp,
                        widget.title,
                        widget.imageUrl,
                        widget.desc



                      );
                      if (context.mounted) Navigator.of(context).pop();
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

  TextEditingController  titleController=TextEditingController();
  TextEditingController  desController =TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    titleController.text=widget.title;
    desController.text=widget.desc;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Consumer<UpdateImageProvider>(builder: (context, provider, child) {
      return Scaffold(
        body: ListView(
          children: [
            // Main Image
            Stack(
              children: [
                SizedBox(
                  width: screenSize.width,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        Center(child: Icon(Icons.error)),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            // Button Overlay
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder()
                ),
                controller: titleController,
            
              ),
            ),
            const SizedBox(height: 10,),
            
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 15),
               child: TextFormField(
                  decoration: const InputDecoration(
                  border: OutlineInputBorder()
                ),
                controller: desController,
                
                         ),
             ),
             const SizedBox(
              height: 10,
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  MaterialButton(
  minWidth: MediaQuery.of(context).size.width * 0.4,
  color: Colors.blue,
  height: 45,
  onPressed: () async {
    print("Qaiser : category: ${widget.category} subcategory: ${widget.subcategories} timestamp: ${widget.timeStamp} title: ${titleController.text} description: ${desController.text} image: ${widget.imageUrl}");
    await provider.updateImage(
      widget.category,     
      widget.subcategories,           
      widget.timeStamp,    
      titleController.text, 
      widget.imageUrl,     
      desController.text     
    );
  },
  child: Text("Edit"),
),

                    MaterialButton(
                      color: Colors.blue,
                      // minWidth: double.,
                      minWidth: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      onPressed: () {
                      
                      },
                     
                      child: Text(
                        "Delete",
                      ),
                    ),
                  ],
                )),
          ],
        ),
      );
    });
  }

  Future<void> updateSubcategoryImage(
    String category,
    String subcategory,
    String imageKey, // the unique key of the image to update
    Map<String, dynamic> updatedData) async {
  try {
    // Get the subcategory document
    final subcategoryDoc = FirebaseFirestore.instance
        .collection('categories')
        .doc(category)
        .collection('subcategories')
        .doc(subcategory);

    // Get the current data
    final snapshot = await subcategoryDoc.get();
    if (snapshot.exists) {
      List<dynamic> imagesData = snapshot.data()?['url'] ?? [];

      // Find the index of the image to update
      int index = imagesData.indexWhere((image) => image['key'] == imageKey);
      if (index != -1) {
        // Update the specific image data
        imagesData[index] = {
          ...imagesData[index],
          ...updatedData, // merge with updated data
        };

        // Update the images field in Firestore
        await subcategoryDoc.update({'url': imagesData});
      } else {
        print('Image with key $imageKey not found.');
      }
    } else {
      print('Subcategory $subcategory does not exist.');
    }
  } catch (e) {
    print('Error updating image: $e');
  }
}

Future<void> deleteSubcategoryImage(
    String category,
    String subcategory,
    String imageKey) async {
  try {
    // Get the subcategory document
    final subcategoryDoc = FirebaseFirestore.instance
        .collection('categories')
        .doc(category)
        .collection('subcategories')
        .doc(subcategory);

    // Get the current data
    final snapshot = await subcategoryDoc.get();
    if (snapshot.exists) {
      List<dynamic> imagesData = snapshot.data()?['url'] ?? [];

      // Find the index of the image to delete
      int index = imagesData.indexWhere((image) => image['key'] == imageKey);
      if (index != -1) {
        // Remove the specific image data
        imagesData.removeAt(index);

        // Update the images field in Firestore
        await subcategoryDoc.update({'url': imagesData});
      } else {
        print('Image with key $imageKey not found.');
      }
    } else {
      print('Subcategory $subcategory does not exist.');
    }
  } catch (e) {
    print('Error deleting image: $e');
  }
}

}
