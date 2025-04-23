// // ignore_for_file: use_build_context_synchronously

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:new_wall_paper_app/audio-to-text/model/store-pdf-sqlite-db-model.dart';
// import 'package:new_wall_paper_app/audio-to-text/page/write-past-text.dart';
// import 'package:new_wall_paper_app/widget/sqlite-helper.dart';

// import 'package:flutter/material.dart';
// // import 'package:new_wall_paper_app/audio-to-text/model/store-pdf-sqlite-db-model.dart';
// // import 'package:new_wall_paper_app/audio-to-text/db_helper.dart';

// class OpenedPdfsPage extends StatefulWidget {
//   const OpenedPdfsPage({Key? key}) : super(key: key);

//   @override
//   _OpenedPdfsPageState createState() => _OpenedPdfsPageState();
// }

// class _OpenedPdfsPageState extends State<OpenedPdfsPage> {
//   late Future<List<Document>> _savedDocuments;

//   @override
//   void initState() {
//     super.initState();
//     _savedDocuments = DatabaseHelper().getDocuments();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: const Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [],
//       ),
//       appBar: AppBar(
//         title: const Text("Saved PDF Contents"),
//       ),
//       body: FutureBuilder<List<Document>>(
//         future: _savedDocuments,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No saved content found"));
//           } else {
//             final documents = snapshot.data!;
//             return ListView.builder(
//               itemCount: documents.length,
//               itemBuilder: (context, index) {
//                 final document = documents[index];
//                 return ListTile(
//                   leading: CircleAvatar(
//                     radius: MediaQuery.of(context).size.height * 0.03,
//                     child: Text(
//                       document.contentType == "PDF"
//                           ? "PDF"
//                           : document.contentType == "Image"
//                               ? "Image"
//                               : document.contentType == "Link"
//                                   ? "Link"
//                                   : document.contentType == "DOCX"
//                                       ? "DOCX"
//                                       : document.contentType == "Email"
//                                           ? "Email"
//                                           : "",
//                       style: const TextStyle(fontSize: 11),
//                     ),
//                   ),
//                   trailing: IconButton(
//                     onPressed: () async {
//                       final confirm = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text("Delete Document"),
//                           content: Text(
//                               "Are you sure you want to delete '${document.name}'?"),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(false),
//                               child: const Text("Cancel"),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(true),
//                               child: const Text("Delete"),
//                             ),
//                           ],
//                         ),
//                       );

//                       if (confirm == true) {
//                         final dbHelper = DatabaseHelper();
//                         await dbHelper.deleteDocument(document.id!);

//                         setState(() {
//                           documents
//                               .removeAt(index); 
//                         });

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content:
//                                   Text("Document '${document.name}' deleted")),
//                         );
//                       }
//                     },
//                     icon: const Icon(
//                       Icons.delete,
//                       color: Colors.red,
//                     ),
//                   ),
//                   title: Text("${document.name}"),
//                   subtitle: Text(document.description.toString()),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => WriteAndTextPage(
//                           text: document.pdfContent,
//                           isText: false,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/show_history_bloc/show_history_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/show_history_bloc/show_history_event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/show_history_bloc/show_history_state.dart';
import 'package:new_wall_paper_app/audio-to-text/model/store-pdf-sqlite-db-model.dart';
import 'package:new_wall_paper_app/audio-to-text/page/write-past-text.dart';
import 'package:new_wall_paper_app/widget/sqlite-helper.dart';


// class OpenedPdfsPage extends StatefulWidget {
//   const OpenedPdfsPage({Key? key}) : super(key: key);

//   @override
//   _OpenedPdfsPageState createState() => _OpenedPdfsPageState();
// }

// class _OpenedPdfsPageState extends State<OpenedPdfsPage> {
//   late Future<List<Document>> _savedDocuments;
//   bool _isMultiSelectMode = false;
//   final Set<int> _selectedItems = {};

//   @override
//   void initState() {
//     super.initState();
//     _savedDocuments = DatabaseHelper().getDocuments();
//   }

//   void _toggleMultiSelectMode() {
//     setState(() {
//       _isMultiSelectMode = !_isMultiSelectMode;
//       _selectedItems.clear();
//     });
//   }

//   Future<void> _deleteSelectedItems() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Selected Documents"),
//         content: Text(
//             "Are you sure you want to delete ${_selectedItems.length} selected documents?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text("Delete"),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       for (var id in _selectedItems) {
//         await DatabaseHelper().deleteDocument(id);
//       }
//       setState(() {
//         _selectedItems.clear();
//         _isMultiSelectMode = false;
//         _savedDocuments = DatabaseHelper().getDocuments();
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Selected documents deleted")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Saved PDF Contents"),
//         actions: [
//           IconButton(
//             icon: Icon(_isMultiSelectMode ? Icons.close : Icons.checklist),
//             onPressed: _toggleMultiSelectMode,
//             tooltip: _isMultiSelectMode ? 'Cancel Selection' : 'Select Multiple',
//           ),
//           if (_isMultiSelectMode && _selectedItems.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: _deleteSelectedItems,
//               tooltip: 'Delete Selected',
//             ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {
//                 _savedDocuments = DatabaseHelper().getDocuments();
//               });
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<Document>>(
//         future: _savedDocuments,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No saved content found"));
//           } else {
//             final documents = snapshot.data!;
//             return ListView.builder(
//               itemCount: documents.length,
//               itemBuilder: (context, index) {
//                 final document = documents[index];
//                 final isSelected = _selectedItems.contains(document.id);

//                 return ListTile(
//                   leading: _isMultiSelectMode
//                       ? Checkbox(
//                           value: isSelected,
//                           onChanged: (bool? value) {
//                             setState(() {
//                               if (value == true) {
//                                 _selectedItems.add(document.id!);
//                               } else {
//                                 _selectedItems.remove(document.id!);
//                               }
//                             });
//                           },
//                         )
//                       : CircleAvatar(
//                           radius: MediaQuery.of(context).size.height * 0.03,
//                           child: Text(
//                             document.contentType ?? "File",
//                             style: const TextStyle(fontSize: 11),
//                           ),
//                         ),
//                   trailing: _isMultiSelectMode
//                       ? null
//                       : IconButton(
//                           onPressed: () async {
//                             final confirm = await showDialog<bool>(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 title: const Text("Delete Document"),
//                                 content: Text(
//                                     "Are you sure you want to delete '${document.name}'?"),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(false),
//                                     child: const Text("Cancel"),
//                                   ),
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(true),
//                                     child: const Text("Delete"),
//                                   ),
//                                 ],
//                               ),
//                             );

//                             if (confirm == true) {
//                               await DatabaseHelper().deleteDocument(document.id!);
//                               setState(() {
//                                 _savedDocuments = DatabaseHelper().getDocuments();
//                               });

//                               if (mounted) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                         "Document '${document.name}' deleted"),
//                                   ),
//                                 );
//                               }
//                             }
//                           },
//                           icon: const Icon(
//                             Icons.delete,
//                             color: Colors.red,
//                           ),
//                         ),
//                   title: Text(document.name ?? "No Name"),
//                   subtitle: Text(document.description ?? ""),
//                   onTap: _isMultiSelectMode
//                       ? () {
//                           setState(() {
//                             if (isSelected) {
//                               _selectedItems.remove(document.id!);
//                             } else {
//                               _selectedItems.add(document.id!);
//                             }
//                           });
//                         }
//                       : () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => WriteAndTextPage(
//                                 text: document.pdfContent,
//                                 isText: false,
//                               ),
//                             ),
//                           );
//                         },
//                   selected: isSelected,
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

class OpenedPdfsPage extends StatefulWidget {
  const OpenedPdfsPage({Key? key}) : super(key: key);

  @override
  _OpenedPdfsPageState createState() => _OpenedPdfsPageState();
}

class _OpenedPdfsPageState extends State<OpenedPdfsPage> {
  late Future<List<Document>> _savedDocuments;
  bool _isMultiSelectMode = false;
  final Set<int> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _savedDocuments = DatabaseHelper().getDocuments();
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      _selectedItems.clear();
    });
  }

  Future<void> _deleteSelectedItems() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Selected Documents"),
        content: Text(
            "Are you sure you want to delete ${_selectedItems.length} selected documents?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete"),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (var id in _selectedItems) {
        await DatabaseHelper().deleteDocument(id);
      }
      setState(() {
        _selectedItems.clear();
        _isMultiSelectMode = false;
        _savedDocuments = DatabaseHelper().getDocuments();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selected documents deleted")),
        );
      }
    }
  }

  Future<void> _renameDocument(Document document) async {
    final TextEditingController nameController = TextEditingController(text: document.name);
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Document"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "New Name",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text("Rename"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != document.name) {
      // Update the document name in the database
      final updatedDocument = Document(
        id: document.id,
        name: newName,
        description: document.description,
        pdfContent: document.pdfContent,
        contentType: document.contentType,
      );
      
      await DatabaseHelper().updateDocument(updatedDocument);
      
      setState(() {
        _savedDocuments = DatabaseHelper().getDocuments();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Document renamed to '$newName'")),
        );
      }
    }
  }

  Future<void> _deleteDocument(Document document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Document"),
        content: Text(
            "Are you sure you want to delete '${document.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete"),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper().deleteDocument(document.id!);
      setState(() {
        _savedDocuments = DatabaseHelper().getDocuments();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Document '${document.name}' deleted")),
        );
      }
    }
  }

  String selectedOption = 'None';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved PDF Contents"),
        actions: [
            IconButton(
          icon: const Icon(Icons.schedule),
          onPressed:   (){
            showScheduleBottomSheet(context);
          }
        ),
          IconButton(
            icon: Icon(_isMultiSelectMode ? Icons.close : Icons.checklist),
            onPressed: _toggleMultiSelectMode,
            tooltip: _isMultiSelectMode ? 'Cancel Selection' : 'Select Multiple',
          ),
          if (_isMultiSelectMode && _selectedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedItems,
              tooltip: 'Delete Selected',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _savedDocuments = DatabaseHelper().getDocuments();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Document>>(
        future: _savedDocuments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No saved content found"));
          } else {
            final documents = snapshot.data!;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                final isSelected = _selectedItems.contains(document.id);

                return ListTile(
                  leading: _isMultiSelectMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedItems.add(document.id!);
                              } else {
                                _selectedItems.remove(document.id!);
                              }
                            });
                          },
                        )
                      : CircleAvatar(
                          radius: MediaQuery.of(context).size.height * 0.03,
                          child: Text(
                            document.contentType ?? "File",
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                  trailing: _isMultiSelectMode
                      ? null
                      : PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'rename':
                                _renameDocument(document);
                                break;
                              case 'delete':
                                _deleteDocument(document);
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Rename'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                  title: Text(document.name ?? "No Name"),
                  subtitle: Text(document.description ?? ""),
                  onTap: _isMultiSelectMode
                      ? () {
                          setState(() {
                            if (isSelected) {
                              _selectedItems.remove(document.id!);
                            } else {
                              _selectedItems.add(document.id!);
                            }
                          });
                        }
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WriteAndTextPage(
                                text: document.pdfContent,
                                isText: false,
                              ),
                            ),
                          );
                        },
                  selected: isSelected,
                );
              },
            );
          }
        },
      ),
    );
  }
    void showScheduleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Schedule Duration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  scheduleOption('1 Hour'),
                  scheduleOption('2 Hours'),
                  scheduleOption('3 Hours'),
                  scheduleOption('24 Hours'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
Widget scheduleOption(String option) {
    bool isSelected = option == selectedOption;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
        Navigator.pop(context); // Close the bottom sheet
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}



/*
import 'package:flutter_bloc/flutter_bloc.dart';

class OpenedPdfsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OpenedPdfsBloc(DatabaseHelper())..add(LoadDocumentsEvent()),
      child: 
      
      BlocBuilder<OpenedPdfsBloc, OpenedPdfsState>(
        builder: (context, state) {
          final bloc = context.read<OpenedPdfsBloc>();

          return Scaffold(
            appBar: AppBar(
              title: const Text("Saved PDF Contents"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.schedule),
                  onPressed: () => _showScheduleBottomSheet(context, bloc),
                ),
                if (state is MultiSelectModeState && state.isMultiSelectMode)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      if (state.selectedItems.isNotEmpty) {
                        bloc.add(DeleteSelectedItemsEvent(state.selectedItems));
                      }
                    },
                    tooltip: 'Delete Selected',
                  ),
                IconButton(
                  icon: state is MultiSelectModeState && state.isMultiSelectMode
                      ? const Icon(Icons.close)
                      : const Icon(Icons.checklist),
                  onPressed: () => bloc.add(ToggleMultiSelectModeEvent()),
                  tooltip: state is MultiSelectModeState && state.isMultiSelectMode
                      ? 'Cancel Selection'
                      : 'Select Multiple',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => bloc.add(LoadDocumentsEvent()),
                ),
              ],
            ),
            body: _buildBody(state, bloc),
          );
        },
      ),
  
  
    );
  }

  Widget _buildBody(OpenedPdfsState state, OpenedPdfsBloc bloc) {
    if (state is InitialOpenedPdfsState) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is DocumentsLoadedState) {
      return _buildDocumentsList(state.documents, bloc, state);
    } else if (state is OptionSelectedState) {
      return Center(
        child: Text("Selected Option: ${state.selectedOption}"),
      );
    } else if (state is MultiSelectModeState) {
      return _buildDocumentsList(state.documents, bloc, state);
    } else if (state is ErrorState) {
      return Center(child: Text("Error: ${state.message}"));
    }

    return const Center(child: Text("No Data Available"));
  }
Widget _buildDocumentsList(List<Document> documents, OpenedPdfsBloc bloc, OpenedPdfsState state) {
  // Extract selectedItems safely from MultiSelectModeState
  final isMultiSelectMode = state is MultiSelectModeState && state.isMultiSelectMode;
  final selectedItems = state is MultiSelectModeState ? state.selectedItems : {};

  return ListView.builder(
    itemCount: documents.length,
    itemBuilder: (context, index) {
      final document = documents[index];
      final isSelected = selectedItems.contains(document.id); // Safely access selectedItems

      return ListTile(
        leading: isMultiSelectMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) {
                  if (isSelected) {
                    bloc.add(RemoveSelectedItemEvent(document.id!));
                  } else {
                    bloc.add(AddSelectedItemEvent(document.id!));
                  }
                },
              )
            : CircleAvatar(
                radius: MediaQuery.of(context).size.height * 0.03,
                child: Text(
                  document.contentType ?? "File",
                  style: const TextStyle(fontSize: 11),
                ),
              ),
        trailing: isMultiSelectMode
            ? null
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      _renameDocument(context, bloc, document);
                      break;
                    case 'delete':
                      bloc.add(DeleteDocumentEvent(document.id!));
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
        title: Text(document.name ?? "No Name"),
        subtitle: Text(document.description ?? ""),
        onTap: isMultiSelectMode
            ? () {
                if (isSelected) {
                  bloc.add(RemoveSelectedItemEvent(document.id!));
                } else {
                  bloc.add(AddSelectedItemEvent(document.id!));
                }
              }
            : null,
        selected: isSelected,
      );
    },
  );
}

  void _showScheduleBottomSheet(BuildContext context, OpenedPdfsBloc bloc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Schedule Duration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _scheduleOption(context, bloc, '1 Hour'),
                  _scheduleOption(context, bloc, '2 Hours'),
                  _scheduleOption(context, bloc, '3 Hours'),
                  _scheduleOption(context, bloc, '24 Hours'),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  bloc.add(ResetOptionEvent());
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _scheduleOption(BuildContext context, OpenedPdfsBloc bloc, String option) {
    return BlocBuilder<OpenedPdfsBloc, OpenedPdfsState>(
      builder: (context, state) {
        final isSelected = state is OptionSelectedState && state.selectedOption == option;

        return GestureDetector(
          onTap: () {
            bloc.add(SelectOptionEvent(option));
            Navigator.pop(context); // Close the bottom sheet
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _renameDocument(BuildContext context, OpenedPdfsBloc bloc, Document document) async {
    final TextEditingController nameController =
        TextEditingController(text: document.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Document"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "New Name",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text("Rename"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != document.name) {
      bloc.add(RenameDocumentEvent(document, newName));
    }
  }
}
*/

