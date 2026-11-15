import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/receipt_parser.dart';

/// Reads text from a receipt photo with ML Kit's on-device recognizer
/// (Latin script, bundled in the app: works offline, no API key, free).
class ReceiptScanner {
  const ReceiptScanner();

  /// Returns the receipt's text as visual rows, top to bottom.
  Future<List<String>> readRows(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(imagePath));
      final lines = [
        for (final block in result.blocks)
          for (final line in block.lines)
            OcrLine(
              line.text,
              line.boundingBox.left,
              line.boundingBox.top,
              line.boundingBox.right,
              line.boundingBox.bottom,
            ),
      ];
      return ReceiptParser.groupRows(lines);
    } finally {
      await recognizer.close();
    }
  }
}

final receiptScannerProvider = Provider<ReceiptScanner>((ref) => const ReceiptScanner());
