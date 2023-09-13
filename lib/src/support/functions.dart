// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_express/src/constants/function_types.dart';
import 'package:dart_express/src/support/route_tree.dart';
import 'package:dart_express/src/constants/route_methods.dart';

class RequestManager {
  final RouteTree _getRequestTree = RouteTree();
  final RouteTree _postRequestTree = RouteTree();
  final RouteTree _patchRequestTree = RouteTree();
  final RouteTree _deleteRequestTree = RouteTree();
  final RouteTree _putRequestTree = RouteTree();

  get getRequestTree => _getRequestTree;

  void addRequest(String path, String method, callback,
      {List<DECallBackWithNext>? middlewares}) {
    switch (method) {
      case Method.get:
        _getRequestTree.addRoute(path, callback, middlewares);
        break;
      case Method.post:
        _postRequestTree.addRoute(path, callback, middlewares);
        break;
      case Method.put:
        _putRequestTree.addRoute(path, callback, middlewares);
        break;
      case Method.delete:
        _deleteRequestTree.addRoute(path, callback, middlewares);
        break;
      case Method.patch:
        _patchRequestTree.addRoute(path, callback, middlewares);
        break;
      default:
        break;
    }
  }

  RouteTreeNode? getRequest(String path, String method) {
    switch (method) {
      case Method.get:
        return _getRequestTree.getRoute(path);
      case Method.post:
        return _postRequestTree.getRoute(path);
      case Method.put:
        return _putRequestTree.getRoute(path);
      case Method.delete:
        return _deleteRequestTree.getRoute(path);
      case Method.patch:
        return _patchRequestTree.getRoute(path);
      default:
        return null;
    }
  }

  void dispose() {
    _getRequestTree.dispose();
    _postRequestTree.dispose();
    _putRequestTree.dispose();
    _deleteRequestTree.dispose();
    _patchRequestTree.dispose();
  }
}

class MiddlewareManager {
  final RouteTree middlewareTree = RouteTree();
  int _order = 0;

  void addMiddleware(String path, List<DECallBackWithNext> middlewares) {
    middlewareTree.addRoute(path, () => {}, middlewares, _order);
    _order++;
  }

  List<RouteTreeNode> getMiddleware(String path) {
    List<RouteTreeNode> middlewares = middlewareTree.getMiddleware(path);
    middlewares.sort((a, b) => a.order.compareTo(b.order));
    return middlewares;
  }

  void dispose() {
    middlewareTree.dispose();
  }
}

Map<String, String> extractRouteParameters(String pattern, String url) {
  List<String> patternParts = pattern.split('/');
  List<String> urlParts = url.split('/');

  Map<String, String> params = {};
  int i = 0;
  String? lastKey;
  int paramCount = 0;
  for (i = 0; i < patternParts.length; i++) {
    String patternPart = patternParts[i];
    String urlPart = urlParts[i];

    if (patternPart.startsWith(':')) {
      String paramName = patternPart.substring(1); // Remove the ':' prefix
      lastKey = paramName;
      params[paramName] = urlPart;
    } else if (patternPart == "*") {
      lastKey = paramCount.toString();
      params[paramCount.toString()] = urlPart;
      paramCount++;
    }
  }

  if (lastKey != null && urlParts.length > i) {
    String v = params[lastKey]!;
    params[lastKey] = "$v/${urlParts.sublist(i).toList().join('/')}";
  }

  return params;
}
