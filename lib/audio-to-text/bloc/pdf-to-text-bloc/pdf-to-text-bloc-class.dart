// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/pdf-to-text-bloc/pdf-to-text-event.dart';
import 'package:new_wall_paper_app/audio-to-text/bloc/pdf-to-text-bloc/pdf-to-text-state.dart';
import 'package:new_wall_paper_app/audio-to-text/model/store-pdf-sqlite-db-model.dart';
import 'package:new_wall_paper_app/widget/sqlite-helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class PDFReaderBloc extends Bloc<PDFReaderEvent, PDFReaderState> {
  PDFReaderBloc() : super(PDFReaderInitial()) {
    on<PickAndReadPDF>(_onPickAndReadPDF);
  }
  Future<void> _onPickAndReadPDF(
      PickAndReadPDF event, Emitter<PDFReaderState> emit) async {
    emit(PDFReaderLoading());
    try {
      // Step 1: Pick the PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;

        if (filePath != null) {
          // Step 2: Read the PDF text
          final reader = await ReadPdfText.getPDFtext(filePath);
          final pdfText = reader ?? "No text found in PDF";

          final fileName = result.files.single.name;
          String documentName = fileName.split('.').first;

          // Save the content and metadata to the database
          final document = Document(
            name: documentName,
            pdfContent: pdfText,
            description: DateTime.now().toIso8601String(),
            contentType: "PDF",
          );

          final dbHelper = DatabaseHelper();
          await dbHelper.insertDocument(document);

          emit(PDFReaderLoaded(pdfText));
        } else {
          emit(PDFReaderError("Failed to load PDF"));
        }
      } else {
        emit(PDFReaderInitial());
      }
    } catch (e) {
      emit(PDFReaderError("Error reading PDF: $e"));
    }
  }

  Future<String> savePdfLocally(File pdfFile, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final savedPath = "${directory.path}/$fileName";
    await pdfFile.copy(savedPath);
    return savedPath;
  }

  Future<void> addDocument(
      File pdfFile, String name, String description) async {
    final document = Document(
      name: name,
      contentType: "PDF",
      pdfContent: pdfFile.path,
      description: DateTime.now().toIso8601String(),
    );

    final dbHelper = DatabaseHelper();
    await dbHelper.insertDocument(document);

    print('Document added to the database successfully!');
  }
}
