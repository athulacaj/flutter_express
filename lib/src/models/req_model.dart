import 'dart:io';
import 'dart:typed_data';

class Req {
  final HttpHeaders headers;
  Map body;
  final Map<dynamic, String> params;
  final Map query;
  final String type;
  final String method;
  final Map data = {};
  final List<Uint8List> bodyStream;
  final HttpRequest request;

  Req(
      {required this.headers,
      required this.body,
      required this.params,
      required this.query,
      required this.type,
      required this.method,
      required this.bodyStream,
      required this.request});

  static fromHttpRequest(HttpRequest request,
      {required Map<dynamic, String> params}) async {
    print(request.requestedUri.queryParameters);

    return Req(
        type: request.method,
        headers: request.headers,
        body: {},
        bodyStream: await request.toList(),
        params: params,
        query: request.requestedUri.queryParameters,
        method: request.method,
        request: request);
  }

  // static fromHttpRequest(HttpRequest request,
  //     {required Map<dynamic, String> params}) async {
  //   String requestBody = "{}";
  //   print(request.requestedUri.queryParameters);
  //   try {
  //     if (request.headers.contentType?.mimeType == 'application/json' &&
  //         request.method != 'OPTIONS' &&
  //         request.method != 'GET') {
  //       await request.toList().then((chunks) {
  //         // Concatenate the list of chunks into a single Uint8List
  //         var bytes =
  //             Uint8List.fromList(chunks.expand((chunk) => chunk).toList());

  //         // Decode the bytes using UTF-8 to get the request body as a string
  //         requestBody = utf8.decode(bytes);
  //       });
  //     }
  //   } catch (e) {
  //     print(e);
  //   }

  //   return Req(
  //     type: request.method,
  //     headers: request.headers,
  //     body: jsonDecode(requestBody),
  //     params: params,
  //     query: request.requestedUri.queryParameters,
  //     method: request.method,
  //     request: request,
  //   );
  // }

  @override
  String toString() {
    return 'Req(headers: ${headers.toString()}, body: $body, params: $params, query: $query)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'headers': headers.toString(),
      'body': body,
      'params': params,
      'query': query,
      'type': type,
    };
  }

  Req copyWith(
      {HttpHeaders? headers,
      Map? body,
      Map<dynamic, String>? params,
      Map? query,
      String? type,
      String? method,
      HttpRequest? request}) {
    return Req(
        headers: headers ?? this.headers,
        body: body ?? this.body,
        params: params ?? this.params,
        query: query ?? this.query,
        type: type ?? this.type,
        method: method ?? this.method,
        bodyStream: bodyStream,
        request: request ?? this.request);
  }
}
