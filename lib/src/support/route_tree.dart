// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dart_express/src/constants/types.dart';
import 'package:dart_express/src/support/functions.dart';

class RouteTreeNode {
  final String path;
  final String pathPart;
  Function? _callback;
  List<DECallBackWithNext>? _middlewares;
  final Map<String, RouteTreeNode> children = {};
  final String? paramKey;
  bool _end = false;
  int _order = 0;

  Map<String, String> _params = {};

  RouteTreeNode(this.path, this.pathPart, {this.paramKey});

  setCallback(Function? callback) {
    _callback = callback;
  }

  setMiddlewares(List<DECallBackWithNext> middlewares) {
    _middlewares = middlewares;
  }

  get callback => _callback;
  get end => _end;
  get middlewares => _middlewares;
  get params => _params;
  get order => _order;

  setEnd(bool value) {
    _end = value;
  }

  setParam(Map<String, String> params) {
    _params = params;
  }

  setOrder(int order) {
    _order = order;
  }

  @override
  String toString() => toJson();

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> childrenMap = [];
    children.forEach((key, RouteTreeNode value) {
      childrenMap.add(value.toMap());
    });
    return <String, dynamic>{
      'path': path,
      'pathPart': pathPart,
      '_callback': _callback.toString(),
      '_middlewares': _middlewares.toString(),
      'paramKey': paramKey,
      'children': childrenMap,
      "params": _params.toString(),
      "order": order,
    };
  }

  String toJson() => json.encode(toMap());
}

class RouteTree {
  final RouteTreeNode root = RouteTreeNode("", "");

  addRoute(String path, Function? callback,
      [List<DECallBackWithNext>? middlewares, int? order]) {
    if (path == "/") {
      root.setCallback(callback);
      root.setMiddlewares(middlewares ?? []);
      root.setEnd(true);
      return;
    }

    List<String> pathParts = path.split("/");
    RouteTreeNode currentNode = root;
    String currentPath = '';
    for (int i = 0; i < pathParts.length; i++) {
      String pathPart = pathParts[i];
      if (pathPart == "") {
        continue;
      }
      currentPath += "/$pathPart";
      // already exists
      if (currentNode.children.containsKey(pathPart)) {
        currentNode = currentNode.children[pathPart]!;
      } else {
        String? paramKey;
        // replace : with * for param matching
        if (pathPart.contains(":")) {
          paramKey = pathPart.replaceAll(":", "");
          pathPart = "*";
        }
        RouteTreeNode newNode =
            RouteTreeNode(currentPath, pathPart, paramKey: paramKey);
        currentNode.children[pathPart] = newNode;
        currentNode = newNode;
      }
      currentNode.setCallback(callback);
      currentNode.setMiddlewares(middlewares ?? []);
      currentNode.setEnd(i == pathParts.length - 1);
    }
    currentNode.setOrder(order ?? 0);
  }

  RouteTreeNode? getRoute(String path) {
    List<String> pathParts = path.split("/");
    RouteTreeNode currentNode = root;

    for (String pathPart in pathParts) {
      if (pathPart == "") {
        continue;
      }
      if (currentNode.children.containsKey(pathPart)) {
        currentNode = currentNode.children[pathPart]!;
      } else if (currentNode.children.containsKey("*")) {
        currentNode = currentNode.children["*"]!;
      }
    }
    if (currentNode.end) {
      final params = extractRouteParameters(currentNode.path, path);
      currentNode.setParam(params);
      currentNode.setParam(params);
      return currentNode;
    }
    return null;
  }

  List<RouteTreeNode> getMiddleware(path) {
    List<String> pathParts = path.split("/");

    final List<RouteTreeNode> middlewareList = [];
    String previousPathPart = "";
    void backtrack(RouteTreeNode currentNode, int i, String previousPathPart) {
      // if (i == pathParts.length) {
      //   if (currentNode.end) {
      //     currentNode.setParam(params);
      //     middlewareList.add(currentNode);
      //   }
      //   return;
      // }

      if (i == pathParts.length) {
        return;
      }
      if (currentNode.end) {
        final params = extractRouteParameters(currentNode.path, path);
        currentNode.setParam(params);
        middlewareList.add(currentNode);
      }
      String pathPart = pathParts[i];

      if (pathPart == "") {
        backtrack(currentNode, i + 1, previousPathPart);
        return;
      }
      if (pathPart != "" && currentNode.children.containsKey(pathPart)) {
        backtrack(currentNode.children[pathPart]!, i + 1, pathPart);
      }
      if (currentNode.children.containsKey("*")) {
        RouteTreeNode tempNode = currentNode.children["*"]!;
        backtrack(tempNode, i + 1, "*");
      }
    }

    RouteTreeNode currentNode = root;

    backtrack(currentNode, 0, previousPathPart);

    return middlewareList;
  }

  void traverse(RouteTreeNode node) {
    node.children.forEach((key, RouteTreeNode value) {
      print(value);
      traverse(value);
    });
  }

  @override
  String toString() {
    return root.toString();
    // traverse(root);
    // return '';
  }
}

void main() {
  final RouteTree _middlewareTree = RouteTree();
  // _middlewareTree.addRoute("/users/1", () => print("users"));
  _middlewareTree.addRoute(
      "/users/:id", null, [(Req, Res, next) => print("users/:id")], 3);
  _middlewareTree.addRoute(
      "/*/:id", null, [(Req, Res, next) => print("users/:id")], 2);
  // _middlewareTree.addRoute("/users/*", () => print("users/:id"));
  // _middlewareTree.addRoute("/:name/1/*", () => print("users/:id"));
  // _middlewareTree.addRoute("/", () => print("users/:id"));
  // _middlewareTree.addRoute("/users/1/2/*", () => print("users/:id"));
  // _middlewareTree.addRoute("*", () => print("users/:id"));

  // print(_middlewareTree);

  List<RouteTreeNode> middle = _middlewareTree.getMiddleware("/users/1/2/3");
  print("middle: $middle");
  // RouteTreeNode? routes = _middlewareTree.getRoute("/users/1/2/3");
  // print("routes: $routes");
}
