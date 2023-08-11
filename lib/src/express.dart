import 'dart:io';
import 'package:dart_express/src/support/functions.dart';
import 'package:dart_express/src/support/route_tree.dart';
import 'package:dart_express/src/support/types.dart';

import 'models/req_model.dart';
import 'models/res_model.dart';

class DartExpress {
  // HttpRequest request;
  // Map listendedRequests = {};
  late HttpServer requests;

  Future<void> listen(int port, Function callback) async {
    // close all connections the server is listening to port 8888

    requests = await HttpServer.bind(InternetAddress.anyIPv4, port);
    callback();

    await requests.forEach((request) async {
      if (request.method == 'OPTIONS') {
        // Handle CORS preflight request
        setCorsHeaders(request.response);
        request.response.statusCode = HttpStatus.ok;
        request.response.close();
        return;
      }

      final RouteTreeNode? listenedRequest =
          RequestManager.getRequest(request.method, request.uri.path);

      final Res res = Res(response: request.response);
      if (listenedRequest != null) {
        final Req req =
            await Req.fromHttpRequest(request, params: listenedRequest.params);
        try {
          listenedRequest.callback(req, res);
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

  get(String path, void Function(Req req, Res res) callback) {
    RequestManager.addRequest(path, Method.get, hanldeException(callback));
  }

  post(String path, void Function(Req req, Res res) callback) {
    RequestManager.addRequest(path, Method.post, hanldeException(callback));
  }

  use(String path, void Function(Req req, Res res) callback) {
    RequestManager.addRequest(path, Method.get, hanldeException(callback));
  }

  end() {
    requests.close();
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
