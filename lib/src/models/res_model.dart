// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

class Res {
  final HttpResponse response;
  int _statusCode = 200;
  final HttpHeaders headers;

  Map h1 = {
    'Access-Control-Allow-Origin': '*', // Replace with your allowed origin
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Max-Age':
        '600', // Optional: specify a preflight cache time in seconds
  };

  Res({required this.response, HttpHeaders? headers})
      : headers = headers ?? response.headers;

  void send(String data) {
    response.statusCode = _statusCode;
    response
      ..headers.contentType = ContentType(
        ContentType.json.primaryType,
        ContentType.json.subType,
      )
      // ..headers.add('Access-Control-Allow-Origin', '*')
      // ..headers.add('content-type', 'application/json; charset=utf-8')
      // ..headers
      //     .add('Access-Control-Allow-Methods', 'POST,GET,DELETE,PUT,OPTIONS')
      // ..headers
      //     .add('Access-Control-Allow-Headers', 'Content-Type, Authorization')
      // ..headers.add('Access-Control-Max-Age', '600')
      ..write(data);

    response.close();
  }

  void json(Map data) {
    String resData;
    try {
      resData = jsonEncode(data);
    } catch (e) {
      resData = e.toString();
    }
    send(resData);
  }

  Res status(int statusCode) {
    _statusCode = statusCode;
    return this;
  }

  setStatusCode(int statusCode) {
    response.statusCode = statusCode;
  }

  void close() {
    response.close();
  }

  Res copyWith({
    HttpResponse? response,
    HttpHeaders? headers,
  }) {
    return Res(response: response ?? this.response, headers: headers);
  }
}
