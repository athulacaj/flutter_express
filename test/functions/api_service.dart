// import 'dart:convert' as convert;

import 'dart:convert';
import 'package:http/http.dart' as http;

enum BodyType { json, formData }

class ApiService {
  static Future<http.Response> get(String url,
      {Map<String, String>? headers}) async {
    return await http.get(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> post(String url,
      {Map<String, String>? headers,
      required Map<String, String> body,
      BodyType bodyType = BodyType.json}) async {
    const optionHeaders = {
      'Content-Type': 'application/json',
    };
    if (bodyType == BodyType.formData) {
      sendFormData(Uri.parse(url), "POST", formData: body);
    }
    return await http.post(
      Uri.parse(url),
      headers: headers ?? optionHeaders,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> options(String path,
      {Map<String, String>? headers}) async {
    final url = Uri.parse(path); // Replace with the URL you want to test
    return _sendUnstreamed("OPTIONS", url, headers);
  }
}

Future<http.Response> sendFormData(Uri url, String method,
    {Map<String, String> formData = const {}}) async {
  final request = http.MultipartRequest('POST', url);

  formData.forEach((key, value) {
    request.fields[key] = value;
  });
  final response = await request.send();
  return http.Response.fromStream(response);
}

Future<http.Response> _sendUnstreamed(
    String method, Uri url, Map<String, String>? headers,
    [Object? body, Encoding? encoding]) async {
  var request = http.Request(method, url);

  if (headers != null) request.headers.addAll(headers);
  if (encoding != null) request.encoding = encoding;
  if (body != null) {
    if (body is String) {
      request.body = body;
    } else if (body is List) {
      request.bodyBytes = body.cast<int>();
    } else if (body is Map) {
      request.bodyFields = body.cast<String, String>();
    } else {
      throw ArgumentError('Invalid request body "$body".');
    }
  }

  final stream = await http.Client().send(request);

  return http.Response.fromStream(stream);
}
