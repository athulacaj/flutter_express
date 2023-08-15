import 'dart:io';
import 'package:dart_express/src/constants/types.dart';
import 'package:dart_express/src/support/functions.dart';
import 'package:dart_express/src/support/route_tree.dart';
import 'package:dart_express/src/support/types.dart';

import 'models/req_model.dart';
import 'models/res_model.dart';

class DartExpress {
  // HttpRequest request;
  // Map listendedRequests = {};
  late HttpServer _requests;
  final RequestManager _requestManager = RequestManager();
  final MiddlewareManager _middlewareManager = MiddlewareManager();

  Future<void> listen(int port, Function callback) async {
    // close all connections the server is listening to port 8888

    _requests = await HttpServer.bind(InternetAddress.anyIPv4, port);
    callback();

    await _requests.forEach((request) async {
      if (request.method == 'OPTIONS') {
        // Handle CORS preflight request
        setCorsHeaders(request.response);
        request.response.statusCode = HttpStatus.ok;
        request.response.close();
        return;
      }

      final RouteTreeNode? listenedRequest =
          _requestManager.getRequest(request.uri.path, request.method);

      final Res res = Res(response: request.response);
      if (listenedRequest != null) {
        final Req req =
            await Req.fromHttpRequest(request, params: listenedRequest.params);
        try {
          // listenedRequest.callback(req, res);
          _addMiddleware(listenedRequest.middlewares ?? [], req, res,
              listenedRequest.callback, 0);

          return;
        } catch (e) {
          print(e);
          return res
              .status(HttpStatus.internalServerError)
              .send({"message": "inavlid request", "data": e});
        }
      }
      return res.status(HttpStatus.notFound).send({"message": "url Not found"});
    });
  }

  void _addMiddleware(List<DECallBackWithNext> middlewares, Req req, Res res,
      DECallBack callback, int i) {
    if (i == middlewares.length) {
      callback(req, res);
      return;
    }
    middlewares[i](req, res, () {
      _addMiddleware(middlewares, req, res, callback, i + 1);
    });
  }

  use(String path, List<DECallBackWithNext> middlewares) {
    _middlewareManager.addMiddleware(path, middlewares);
  }

  get(String path, DECallBack callback,
      {List<DECallBackWithNext>? middlewares}) {
    _requestManager.addRequest(path, Method.get, hanldeException(callback),
        middlewares: middlewares);
  }

  post(String path, DECallBack callback) {
    _requestManager.addRequest(path, Method.post, hanldeException(callback));
  }

  end() {
    _requests.close();
  }
}

void setCorsHeaders(HttpResponse response) {
  response.headers.add('Access-Control-Allow-Origin', '*');
  response.headers
      .add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
}

Function hanldeException(Function callback) {
  return (
    Req req,
    Res res,
  ) async {
    try {
      await callback(req, res);
    } catch (e) {
      // print({
      //   "message": "inavlid ${req.type} request",
      //   "error": e,
      //   "headers": req.toMap()
      // });
      print(e);
      return res.status(HttpStatus.internalServerError).send({
        "message": "inavlid ${req.type} request",
        "error": e.toString(),
        "request": req.toMap(),
      });
    }
  };
}
