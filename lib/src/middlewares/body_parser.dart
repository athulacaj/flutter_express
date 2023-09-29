import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// import 'package:http/http.dart' as http;
import 'package:dart_express/src/middlewares/functions/split_multipdart.dart';

import '../models/req_model.dart';
import '../models/res_model.dart';

class DEParser {
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

  static formUrlEncoded(Req req, Res res, Function next) {
    if (req.headers.contentType?.mimeType ==
            'application/x-www-form-urlencoded' &&
        req.method != 'OPTIONS' &&
        req.method != 'GET') {
      String requestBody = "";
      var bytes =
          Uint8List.fromList(req.bodyStream.expand((chunk) => chunk).toList());
      requestBody = utf8.decode(bytes);
      final decodedData = Uri.splitQueryString(requestBody);
      final Map result = {};
      decodedData.forEach((key, value) {
        print('$key: $value');
        result[key] = value;
      });
      req.body = result;
    }
    next();
  }

  // static formDataParser(Req req, Res res, Function next) async {
  //   if (req.method != 'OPTIONS' && req.method != 'GET') {
  //     final bodyBytes = req.bodyStream.expand((chunk) => chunk).toList();
  //     String test = String.fromCharCodes(bodyBytes);

  //     final boundary = req.headers.contentType!.parameters['boundary'];

  //     // Read the request body into bodyBytes.

  //     final startBoundaryBytes = utf8.encode('--$boundary\r\n');
  //     final endBoundaryBytes = utf8.encode('---$boundary--\r\n');
  //     // - = 45, \r = 13, \n = 10
  //     final headerEnd = utf8.encode('\r\n\r\n');

  //     final List<List<int>> parts = [];
  //     splitMultipart(bodyBytes, startBoundaryBytes, parts, 0, endBoundaryBytes);
  //     // File('logs.txt').writeAsStringSync(data.toString());

  //     for (List<int> part in parts) {
  //       // split the  key and value charcodes

  //       final List<List<int>> keyValueParts = [];
  //       splitMultipart(part, [10, 13, 10], keyValueParts, 0, [10]);
  //       String result = String.fromCharCodes(keyValueParts[0]);
  //       File('logs.txt').writeAsStringSync(result);

  //       writeUint8ListToFile(
  //           Uint8List.fromList(keyValueParts[1]), "./demo.png");
  //       print("**************        **************");
  //     }
  //   }
  //   next();
  // }

  // static Map<String, dynamic> parseMultipartForm(
  //     List<int> bodyBytes, String boundary) {
  //   // Implement a function to parse the multipart form data
  //   // You can use a library like 'mime/multipart.dart' to help with parsing
  //   // For simplicity, I'll omit the implementation here
  //   throw UnimplementedError('Multipart form parsing is not implemented');
  // }
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
