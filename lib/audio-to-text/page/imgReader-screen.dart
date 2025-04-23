

// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/imageReader-bloc/imgReader-bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/imageReader-bloc/imgReader-event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/imageReader-bloc/imgReader-state.dart';
import 'package:new_wall_paper_app/audio-to-text/page/write-past-text.dart';

class ImageReaderScreen extends StatelessWidget {
  final bool isCamera; 

  ImageReaderScreen({required this.isCamera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<ImageReaderBloc, ImageReaderState>(
            builder: (context, state) {
              if (state is ImageReaderLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ImageReaderImagePicked) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WriteAndTextPage(
                          text: state.extractedText, isText: false,
                        ),
                      ),
                    );
                  },
                  child: const Text("Next"),
                );
              } else {
                return const Center(child: Text("No image selected"));
              }
            },
          ),
        ],
      ),
     
     
      appBar: AppBar(
        title: const Text("Image Reader"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // Open camera or gallery based on isCamera value
                final event = PickImageAndRecognizeText(isCamera: isCamera);
                BlocProvider.of<ImageReaderBloc>(context).add(event);
              },
              child: const Text("Pick Image and Recognize Text"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<ImageReaderBloc, ImageReaderState>(
                builder: (context, state) {
                  if (state is ImageReaderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ImageReaderImagePicked) {
                    return SingleChildScrollView(
                      child: Text(
                        state.extractedText,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  } else if (state is ImageReaderError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text("No text recognized"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
