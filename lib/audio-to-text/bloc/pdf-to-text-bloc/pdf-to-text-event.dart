import 'package:equatable/equatable.dart';

abstract class PDFReaderEvent extends Equatable {
  const PDFReaderEvent();


  @override
  List<Object> get props=>[];



}
class PickAndReadPDF extends PDFReaderEvent {}