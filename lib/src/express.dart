import 'dart:io';
import 'package:flutter_express/src/constants/function_types.dart';
import 'package:flutter_express/src/support/functions.dart';
import 'package:flutter_express/src/support/route_tree.dart';
import 'package:flutter_express/src/constants/route_methods.dart';

import 'models/req_model.dart';
import 'models/res_model.dart';

class FlutterExpress {
  late HttpServer _requests;
  final RequestManager _requestManager = RequestManager();
  final MiddlewareManager _middlewareManager = MiddlewareManager();

  /// * Start the server listening on the specified port.
  /// * [port] the port to run the server.
  /// * [callback] the function hits affter the server starts.
  Future<void> listen(int port, Function callback) async {
    _requests = await HttpServer.bind(InternetAddress.anyIPv4, port);
    callback();

    await _requests.forEach((request) async {
      final RouteTreeNode? listenedRequest =
          _requestManager.getRequest(request.uri.path, request.method);

      final Res res = Res(response: request.response);

      List commonMiddlewares = [];
      _middlewareManager
          .getMiddleware(request.uri.path)
          .forEach((e) => commonMiddlewares.addAll(e.middlewares ?? []));
      if (listenedRequest != null || commonMiddlewares.isNotEmpty) {
        final Req req = await Req.fromHttpRequest(request,
            params: listenedRequest?.params ?? {});
        try {
          List middlewares = listenedRequest?.middlewares ?? [];
          _addMiddleware(
              [...commonMiddlewares, ...middlewares],
              req,
              res,
              listenedRequest?.callback ??
                  (req, res) => {
                        res.status(HttpStatus.notFound).json({
                          "message": "url Not found",
                          "request": req.toMap()
                        })
                      },
              0);

          return;
        } catch (e) {
          return res
              .status(HttpStatus.internalServerError)
              .json({"message": "inavlid request", "data": e});
        }
      }
      return res.status(HttpStatus.notFound).json({"message": "url Not found"});
    });
  }

  void _addMiddleware(List<FECallBackWithNext> middlewares, Req req, Res res,
      FECallBack callback, int i) {
    if (i == middlewares.length) {
      callback(req, res);
      return;
    }
    // taking each middlewares from the middleware list and adding to the callback 'next'
    middlewares[i](req, res, () {
      _addMiddleware(middlewares, req, res, callback, i + 1);
    });
  }

  /// Add a middleware to the server
  /// * [path] path of the route
  /// * [middlewares] is a list of FECallBackWithNext.
  /// * [FECallBackWithNext] is void Function(Req req, Res res, Function next). It is a function that takes in a Req, Res object and a void that can be called to execute the next middleware or the callback
  use(String path, List<FECallBackWithNext> middlewares) {
    _middlewareManager.addMiddleware(path, middlewares);
  }

  /// Add a GET request to the server
  /// * The callback must be a function that takes in a Req, Res object. note: if the [middlewares] are passed this will executed after the middlewares are executed
  /// * Optionally, you can pass in a list of middlewares to be executed before the callback
  /// * For middleware the callback must be a function that takes in a Req, Res object and a void that can be called to execute the next middleware or the callback
  void get(String path, FECallBack callback,
      {List<FECallBackWithNext>? middlewares}) {
    _requestManager.addRequest(path, Method.get, _hanldeException(callback),
        middlewares: middlewares);
  }

  /// Add a POST request to the server
  /// * The callback must be a function that takes in a Req, Res object. note: if the [middlewares] are passed this will executed after the middlewares are executed
  /// * Optionally, you can pass in a list of middlewares to be executed before the callback
  /// * For middleware the callback must be a function that takes in a Req, Res object and a void that can be called to execute the next middleware or the callback

  void post(String path, FECallBack callback,
      {List<FECallBackWithNext>? middlewares}) {
    _requestManager.addRequest(path, Method.post, _hanldeException(callback),
        middlewares: middlewares);
  }

  void patch(String path, FECallBack callback,
      {List<FECallBackWithNext>? middlewares}) {
    _requestManager.addRequest(path, Method.patch, _hanldeException(callback),
        middlewares: middlewares);
  }

  void put(String path, FECallBack callback,
      {List<FECallBackWithNext>? middlewares}) {
    _requestManager.addRequest(path, Method.put, _hanldeException(callback),
        middlewares: middlewares);
  }

  void delete(String path, FECallBack callback,
      {List<FECallBackWithNext>? middlewares}) {
    _requestManager.addRequest(path, Method.delete, _hanldeException(callback),
        middlewares: middlewares);
  }

  /// To close the requestxxw
  void end() {
    _requests.close();
  }

  /// to clear all the routes and middlewares
  void clear() {
    _requestManager.dispose();
    _middlewareManager.dispose();
  }
}

Function _hanldeException(Function callback) {
  return (
    Req req,
    Res res,
  ) async {
    try {
      await callback(req, res);
    } catch (e) {
      return res.status(HttpStatus.internalServerError).json({
        "message": "inavlid ${req.type} request",
        "error": e.toString(),
        "request": req.toMap(),
      });
    }
  };
}
