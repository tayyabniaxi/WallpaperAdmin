

// search_image_page.dart
import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/provider/add-image-provider.dart';
import 'package:provider/provider.dart';
class SearchImagePage extends StatelessWidget {
  const SearchImagePage({super.key});

  void _showEditPopup(BuildContext context, Map<String, dynamic> imageData) {
    final TextEditingController nameController =
        TextEditingController(text: imageData['name']);

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<SearchImageProvider>(
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
                        imageData['docId'],
                        nameController.text,
                        imageData['url'],
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

  

  

  @override
  Widget build(BuildContext context) {
      // final provider = Provider.of<SearchImageProvider>(context);

    
    return Consumer<SearchImageProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Search List'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: provider.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by image name',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => provider
                          .updateSearchQuery(provider.searchController.text),
                    ),
                  ),
                  onChanged: provider.updateSearchQuery,
                ),
              ),
            ),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: provider.searchImages(provider.searchQuery),
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

              return ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        images[index]['url'],
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(images[index]['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditPopup(context, images[index]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog on cancel
              },
              child: const Text('Cancel'),
            ),
            Consumer<SearchImageProvider>(
              builder: (context, provider, _) {
                return provider.isDeleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: () {
                          provider.deleteImage(images[index]['docId']).then((_) {
                            Navigator.pop(context); // Close the dialog when done
                          });
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      );
              },
            ),
          ],
        );
      
        },
      );
                          }
                        
                        ),
                    
                    
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
  
}