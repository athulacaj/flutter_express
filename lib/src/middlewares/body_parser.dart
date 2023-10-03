import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../models/req_model.dart';
import '../models/res_model.dart';

class Parser {
  static jsonParser(Req req, Res res, Function next) {
    if (req.headers.contentType?.mimeType == 'application/json' &&
        req.method != 'OPTIONS' &&
        req.method != 'GET') {
      String requestBody = "{}";
      var bytes =
          Uint8List.fromList(req.bodyStream.expand((chunk) => chunk).toList());
      requestBody = utf8.decode(bytes);
      req.body = jsonDecode(requestBody);
    }
    next();
  }
}

Future<void> writeUint8ListToFile(Uint8List uint8List, String filePath) async {
  final file = File(filePath);

  try {
    // Write the Uint8List to the file using a FileSink.
    await file.writeAsBytes(uint8List);

    print('File saved successfully: $filePath');
  } catch (e) {
    print('Error saving file: $e');
  }
}
