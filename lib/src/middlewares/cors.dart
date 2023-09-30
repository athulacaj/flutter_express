import 'dart:io';

import '../models/req_model.dart';
import '../models/res_model.dart';
import '../constants/function_types.dart';

class CorsOptions {
  final List<String> origin;
  final List<String> methods;
  static const List<String> allMethods = [
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "OPTIONS"
  ];

  CorsOptions({this.origin = const ["*"], this.methods = allMethods});
}

void setCorsHeaders(Res res) {
  res.headers.add('Access-Control-Allow-Origin', '*');
  res.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.headers.add('Access-Control-Allow-Headers', 'Content-Type');
}

FECallBackWithNext cors([CorsOptions? options]) {
  options ??= CorsOptions();
  return (Req req, Res res, Function next) {
    if (req.method == 'OPTIONS') {
      // Handle CORS preflight request
      setCorsHeaders(res);
      res.setStatusCode(HttpStatus.ok);
      res.close();
      return;
    } else {
      next();
    }
  };
}
