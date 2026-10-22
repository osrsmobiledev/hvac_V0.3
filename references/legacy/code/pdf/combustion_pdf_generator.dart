// ignore_for_file: avoid_print
// File: lib/services/pdf/combustion_pdf_generator.dart
// Responsibility: Master PDF orchestrator

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Core Models
import 'package:hvac_field_service/core/models/start_profile.dart';
import 'package:hvac_field_service/core/models/firm_profile.dart';
import 'package:hvac_field_service/core/models/klant_profile.dart';
import 'package:hvac_field_service/core/models/toestel_profile.dart';
import 'package:hvac_field_service/core/models/meting_profile.dart';
import 'package:hvac_field_service/core/models/besluit_profile.dart';

// Lego Blocks
import 'package:hvac_field_service/services/pdf/builders/pdf_header_builder.dart';
import 'package:hvac_field_service/services/pdf/builders/pdf_firma_builder.dart';
import 'package:hvac_field_service/services/pdf/builders/pdf_klant_builder.dart';
import 'package:hvac_field_service/services/pdf/builders/pdf_toestel_kenmerken_builder.dart';
import 'package:hvac_field_service/services/pdf/builders/pdf_toestel_apparaat_builder.dart';
import 'package:hvac_field_service/services/pdf/builders/pdf_meting_builder.dart';

import 'package:flutter/services.dart' show rootBundle;

class CombustionPdfGenerator {
  static Future<Uint8List> generateCertificate({
    required StartProfile start,
    required FirmProfile firma,
    required KlantProfile klant,
    required ToestelProfile toestel,
    required MetingProfile meting,
    required BesluitProfile besluit,
  }) async {
    
    // 1. Load the Libron fonts securely from the Flutter asset bundle
    final libronData = await rootBundle.load('assets/fonts/libron-regular.ttf');
    final libronBoldData = await rootBundle.load('assets/fonts/libron-bold.ttf');

    // rootBundle returns ByteData, which pw.Font.ttf accepts directly
    final libronFont = pw.Font.ttf(libronData);
    final libronBoldFont = pw.Font.ttf(libronBoldData);

    // 2. Base Document setup with Global Libron Theme
    final pdf = pw.Document(
      title: 'Verbrandingsattest',
      theme: pw.ThemeData.withFont(
        base: libronFont,
        bold: libronBoldFont,
      ),
    );

    // 3. Page Structure
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, 
        // Using exact government point measurements for pixel-perfect alignment
        margin: const pw.EdgeInsets.only(
          top: 13.6,
          left: 24.9, 
          right: 17.3,
          bottom: 15.0,
        ), 
        
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              PdfHeaderBuilder.buildHeader(start),
              pw.SizedBox(height: 1.6), // Gap 1
              PdfFirmaBuilder.buildFirmaSection(start, firma),

              pw.SizedBox(height: 1.6), // Gap 2
              PdfKlantBuilder.buildKlantSection(klant),

              pw.SizedBox(height: 1.6), // Gap 3
              PdfToestelKenmerkenBuilder.buildKenmerkenSection(toestel),
              
              pw.SizedBox(height: 1.6), // Gap 4
              PdfToestelApparaatBuilder.buildApparaatSection(toestel),

              pw.SizedBox(height: 1.6), // Gap 5
              PdfMetingBuilder.buildMetingSection(meting),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<String> saveRawPdf(Uint8List bytes) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'Verbrandingsattest_$timestamp.pdf';

    // Direct save to the physical Android Downloads folder
    final directory = Directory('/storage/emulated/0/Download');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    
    final finalPath = '${directory.path}/$fileName';
    final file = File(finalPath);
    
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}