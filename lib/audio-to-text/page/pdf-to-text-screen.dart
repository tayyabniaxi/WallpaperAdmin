import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/pdf-to-text-bloc/pdf-to-text-bloc-class.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/pdf-to-text-bloc/pdf-to-text-event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/pdf-to-text-bloc/pdf-to-text-state.dart';
import 'package:new_wall_paper_app/audio-to-text/page/write-past-text.dart';

class PDFToTextScreen extends StatefulWidget {
  const PDFToTextScreen({super.key});

  @override
  State<PDFToTextScreen> createState() => _PDFToTextScreenState();
}

class _PDFToTextScreenState extends State<PDFToTextScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Text Reader"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<PDFReaderBloc>(context).add(PickAndReadPDF());
              },
              child: const Text("Pick and Read PDF"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<PDFReaderBloc, PDFReaderState>(
                builder: (context, state) {
                  if (state is PDFReaderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PDFReaderLoaded) {
                    return SingleChildScrollView(
                      child: Text(
                        state.pdfText,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  } else if (state is PDFReaderError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text("No PDF selected"));
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<PDFReaderBloc, PDFReaderState>(
            builder: (context, state) {
              if (state is PDFReaderLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PDFReaderLoaded) {
                return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WriteAndTextPage(
                                  text: state.pdfText,
                                  isText: false,
                                )),
                      );
                    },
                    child: Text("Next"));
              } else {
                return const Center(child: Text("No PDF selected"));
              }
            },
          )
        ],
      ),
   
   
    );
  }
}
