// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/imageReader-bloc/imgReader-bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/imageReader-bloc/imgReader-state.dart';

import 'package:new_wall_paper_app/audio-to-text/bloc/link_reader_bloc/link_reader_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/link_reader_bloc/link_reader_event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/link_reader_bloc/link_reader_state.dart';
import 'package:new_wall_paper_app/audio-to-text/page/write-past-text.dart';

class LinkReaderScreen extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController();

  var data = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<LinkReaderBloc, LinkReaderState>(
            builder: (context, state) {
              if (state is ImageReaderLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LinkReaderLoaded) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WriteAndTextPage(
                          text: 
                               state.extractedText,
                          isText: false,
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
    
    
      appBar: AppBar(title: const Text('Link Reader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final url = _urlController.text.trim();
                // Emit FetchWebsiteTextEvent when button is pressed
                context.read<LinkReaderBloc>().add(FetchWebsiteTextEvent(url));
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => Scaffold(
                //       appBar: AppBar(title: Text('Extracted Text')),
                //       body: Padding(
                //         padding: const EdgeInsets.all(16.0),
                //         child: SingleChildScrollView(
                //           child: Text(
                //             data,
                //             style: TextStyle(fontSize: 16),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // );
              },
              child: const Text('Fetch Text'),
            ),
            const SizedBox(height: 16),
            BlocBuilder<LinkReaderBloc, LinkReaderState>(
              builder: (context, state) {
                if (state is LinkReaderLoading) {
                  return const CircularProgressIndicator();
                } else if (state is LinkReaderError) {
                  return Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  );
                } else if (state is LinkReaderLoaded) {
                  data = state.extractedText.isNotEmpty
                      ? state.extractedText
                      : 'No text extracted.';

                  return Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        state.extractedText.isNotEmpty
                            ? state.extractedText
                            : 'No text extracted.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }
                return Container(); // Initial state
              },
            ),
          ],
        ),
      ),
    );
  }
}
