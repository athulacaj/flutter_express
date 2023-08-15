// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dart_express/src/constants/types.dart';

class RouteTreeNode {
  final String path;
  final String pathPart;
  Function? _callback;
  List<DECallBackWithNext>? _middlewares;
  final Map<String, RouteTreeNode> children = {};
  final String? paramKey;
  bool _end = false;
  int _order = 0;

  Map<dynamic, String> _params = {};

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

  setParam(Map<dynamic, String> params) {
    _params = params;
  }

  setOrder(int order) {
    _order = order;
    print(this);
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
      currentNode.setOrder(order ?? 0);
    }
  }

  RouteTreeNode? getRoute(String path) {
    List<String> pathParts = path.split("/");
    RouteTreeNode currentNode = root;
    String previousPathPart = "";
    int paramCount = 0;
    Map<dynamic, String> params = {};
    for (String pathPart in pathParts) {
      if (pathPart == "") {
        continue;
      }
      if (currentNode.children.containsKey(pathPart)) {
        currentNode = currentNode.children[pathPart]!;
        previousPathPart = pathPart;
      } else if (currentNode.children.containsKey("*")) {
        currentNode = currentNode.children["*"]!;

        if (currentNode.paramKey != null) {
          params[currentNode.paramKey] = pathPart;
        } else {
          previousPathPart = "*";
          params[paramCount] = pathPart;
          paramCount++;
        }
      } else {
        if (previousPathPart != "*" || !currentNode.end) {
          return null;
        } else if (paramCount != 0) {
          final String existingParams = params[paramCount - 1] ?? '';
          params[paramCount - 1] = "$existingParams/$pathPart";
        }
      }
    }
    currentNode.setParam(params);
    return currentNode;
  }

  // need to write a backtracking algorithm
  int count = 0;
  void recursive(
      {required List<String> pathParts,
      required List<RouteTreeNode> middlewareNodes,
      required Map<dynamic, String> params,
      required int paramCount,
      required String previousPathPart,
      required RouteTreeNode currentNode,
      required bool skipFistMatch,
      required int i}) {
    bool isValid = true;
    bool skipExactMatch = skipFistMatch;
    for (int i = 0; i < pathParts.length; i++) {
      count++;
      String pathPart = pathParts[i];
      if (pathPart == "") {
        continue;
      }
      if (pathPart == "1") {
        print("pathPart: $pathPart");
      }
      if (currentNode.children.containsKey(pathPart) && !skipExactMatch) {
        // other possible matches
        if (currentNode.children["*"] != null) {
          recursive(
              pathParts: pathParts,
              middlewareNodes: middlewareNodes,
              params: params,
              paramCount: paramCount,
              previousPathPart: previousPathPart,
              currentNode: currentNode,
              skipFistMatch: true,
              i: i + 1);
        }
        currentNode = currentNode.children[pathPart]!;
        previousPathPart = pathPart;
      } else if (currentNode.children.containsKey("*")) {
        currentNode = currentNode.children["*"]!;
        if (currentNode.paramKey != null) {
          params[currentNode.paramKey] = pathPart;
        } else {
          previousPathPart = "*";
          params[paramCount] = pathPart;
          paramCount++;
        }
        if (currentNode.end) {
          final String existingParams = params[paramCount - 1] ?? '';
          params[paramCount - 1] = "$existingParams/$pathPart";
        }
      } else {
        if (previousPathPart != "*" || !currentNode.end) {
          isValid = false;
          return;
        } else if (paramCount != 0) {
          final String existingParams = params[paramCount - 1] ?? '';
          params[paramCount - 1] = "$existingParams/$pathPart";
        }
      }
      skipExactMatch = false;
    }
    currentNode.setParam(params);
    middlewareNodes.add(currentNode);
    return;
  }

  List<RouteTreeNode> getMiddleware(path) {
    List<String> pathParts = path.split("/");

    final List<RouteTreeNode> middlewareList = [];
    String previousPathPart = "";
    void backtrack(RouteTreeNode currentNode, int i, String previousPathPart,
        Map params, int paramCount) {
      if (i == pathParts.length) {
        if (currentNode.end) {
          middlewareList.add(currentNode);
        }
        return;
      }

      if (currentNode.end) {
        middlewareList.add(currentNode);
      }

      String pathPart = pathParts[i];

      if (pathPart == "") {
        backtrack(currentNode, i + 1, previousPathPart, params, paramCount);
        return;
      }
      if (pathPart != "" && currentNode.children.containsKey(pathPart)) {
        backtrack(currentNode.children[pathPart]!, i + 1, pathPart, params,
            paramCount);
      }
      if (currentNode.children.containsKey("*")) {
        RouteTreeNode tempNode = currentNode.children["*"]!;
        Map tempParams = {...params};

        if (tempNode.paramKey != null) {
          tempParams[tempNode.paramKey] = pathPart;
        } else {
          previousPathPart = "*";
          tempParams[paramCount] = pathPart;
        }
        backtrack(tempNode, i + 1, "*", tempParams, paramCount++);
      }
    }

    RouteTreeNode currentNode = root;

    backtrack(currentNode, 0, previousPathPart, {}, 0);
    print("middlewareList: $middlewareList");

    return middlewareList;
  }

  // List<RouteTreeNode> getMiddleware(String path) {
  //   List<String> pathParts = path.split("/");
  //   RouteTreeNode currentNode = root;
  //   String previousPathPart = "";
  //   int paramCount = 0;
  //   Map<dynamic, String> params = {};
  //   List<RouteTreeNode> nodes = [];
  //   currentNode.setParam(params);
  //   return nodes;
  // }

  // List<RouteTreeNode> getMiddleware(String path) {
  //   List<String> pathParts = path.split("/");
  //   RouteTreeNode currentNode = root;
  //   String previousPathPart = "";
  //   int paramCount = 0;
  //   Map<dynamic, String> params = {};
  //   List<RouteTreeNode> middlewareNodes = [];

  //   recursive(
  //       pathParts: pathParts,
  //       middlewareNodes: middlewareNodes,
  //       params: params,
  //       paramCount: paramCount,
  //       previousPathPart: previousPathPart,
  //       currentNode: currentNode,
  //       skipFistMatch: false,
  //       i: 0);

  //   // backTrack(
  //   //     pathParts: pathParts,
  //   //     i: 0,
  //   //     middlewareNodes: middlewareNodes,
  //   //     params: params,
  //   //     paramCount: paramCount,
  //   //     previousPathPart: previousPathPart,
  //   //     currentNode: currentNode,
  //   //     skipFistMatch: false);

  //   // recursive(
  //   //     pathParts: pathParts,
  //   //     middlewareNodes: middlewareNodes,
  //   //     params: params,
  //   //     paramCount: paramCount,
  //   //     previousPathPart: previousPathPart,
  //   //     currentNode: currentNode,
  //   //     skipFistMatch: true);

  //   print("recursive count: $count");

  //   return middlewareNodes;
  // }

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
  // _middlewareTree.addRoute("/users/*", () => print("users/:id"));
  // _middlewareTree.addRoute("/:name/1/*", () => print("users/:id"));
  // _middlewareTree.addRoute("/", () => print("users/:id"));
  // _middlewareTree.addRoute("/users/1/2/*", () => print("users/:id"));
  // _middlewareTree.addRoute("*", () => print("users/:id"));

  // print(_middlewareTree);

  List<RouteTreeNode> routes = _middlewareTree.getMiddleware("/users/1/2/3");
  print("routes: ${routes}");
}
