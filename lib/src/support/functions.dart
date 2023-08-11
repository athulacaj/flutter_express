// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_express/src/support/route_tree.dart';
import 'package:dart_express/src/support/types.dart';

class RequestManager {
  static final RouteTree _getRequestTree = RouteTree();
  static final RouteTree _postRequestTree = RouteTree();
  static final RouteTree _patchRequestTree = RouteTree();
  static final RouteTree _deleteRequestTree = RouteTree();
  static final RouteTree _putRequestTree = RouteTree();

  static addRequest(String path, String method, Function callback) {
    switch (method) {
      case Method.get:
        _getRequestTree.addRoute(path, callback);
        break;
      case Method.post:
        _postRequestTree.addRoute(path, callback);
        break;
      case Method.put:
        _putRequestTree.addRoute(path, callback);
        break;
      case Method.delete:
        _deleteRequestTree.addRoute(path, callback);
        break;
      case Method.patch:
        _patchRequestTree.addRoute(path, callback);
        break;
      default:
        break;
    }
  }

  static RouteTreeNode? getRequest(String method, String path) {
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
}
